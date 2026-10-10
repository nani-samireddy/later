import 'dart:async';
import 'dart:io';

// crypto is already resolved in pubspec.lock; declare it directly when wiring UI.
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class SpeechCancelled implements Exception {
  const SpeechCancelled();
}

class SpeechCancellation {
  bool _cancelled = false;
  final _listeners = <void Function()>[];
  bool get isCancelled => _cancelled;
  void check() {
    if (_cancelled) throw const SpeechCancelled();
  }

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    for (final listener in List.of(_listeners)) {
      listener();
    }
  }

  void Function() onCancel(void Function() listener) {
    if (_cancelled) {
      listener();
    } else {
      _listeners.add(listener);
    }
    return () => _listeners.remove(listener);
  }
}

class SpeechDownloadProgress {
  const SpeechDownloadProgress(
    this.fileName,
    this.receivedBytes,
    this.totalBytes,
  );
  final String fileName;
  final int receivedBytes;
  final int totalBytes;
  double get fraction => totalBytes == 0 ? 0 : receivedBytes / totalBytes;
}

class SpeechModelFile {
  const SpeechModelFile(this.name, this.size, this.sha256);
  final String name;
  final int size;
  final String sha256;
}

/// Downloads to a temporary sibling, validates publisher checksums, then renames.
/// Existing files are validated too (including files from older app versions).
class SpeechModelStore {
  SpeechModelStore({
    Future<Directory> Function()? directory,
    HttpClient Function()? clientFactory,
    this.repository = _modelRepository,
    this.manifest = modelManifest,
    this.timeout = const Duration(seconds: 30),
  }) : _directory = directory ?? _defaultDirectory,
       _clientFactory = clientFactory ?? HttpClient.new;

  static const _modelRepository =
      'https://huggingface.co/csukuangfj/sherpa-onnx-streaming-zipformer-en-20M-2023-02-17/resolve/d42f2d9f7ca24806fb667456a18a9f1b60f70d16';
  static const modelManifest = [
    SpeechModelFile(
      'encoder-epoch-99-avg-1.int8.onnx',
      42845182,
      '3810755ce7c3ab26b42a8bcf39d191308fa27fb0f53358823ba46141d03b7eb3',
    ),
    SpeechModelFile(
      'decoder-epoch-99-avg-1.int8.onnx',
      539499,
      '21e2a2acd961b3ac72f55be2f10f1a285e1b0b0ba010d7c0b6eab141411b163c',
    ),
    SpeechModelFile(
      'joiner-epoch-99-avg-1.int8.onnx',
      259572,
      'e085d73b593cf9b0707f370dbd656d58327d3fe36d80d849202ef81df02cb01e',
    ),
    SpeechModelFile(
      'tokens.txt',
      5048,
      '49e3c2646595fd907228b3c6787069658f67b17377c60aeb8619c4551b2316fb',
    ),
  ];
  static const files = [
    'encoder-epoch-99-avg-1.int8.onnx',
    'decoder-epoch-99-avg-1.int8.onnx',
    'joiner-epoch-99-avg-1.int8.onnx',
    'tokens.txt',
  ];
  static final _default = SpeechModelStore();
  final Future<Directory> Function() _directory;
  final HttpClient Function() _clientFactory;
  final String repository;
  final List<SpeechModelFile> manifest;
  final Duration timeout;
  bool _busy = false;

  static Future<Directory> _defaultDirectory() async {
    final root = await getApplicationSupportDirectory();
    return Directory(path.join(root.path, 'speech', 'zipformer-en'));
  }

  static Future<String> ensureModel({
    SpeechCancellation? cancellation,
    void Function(SpeechDownloadProgress)? onProgress,
  }) => _default.prepare(cancellation: cancellation, onProgress: onProgress);

  Future<bool> _valid(File file, SpeechModelFile spec) async =>
      await file.exists() &&
      await file.length() == spec.size &&
      (await sha256.bind(file.openRead()).first).toString() == spec.sha256;

  Future<String> prepare({
    SpeechCancellation? cancellation,
    void Function(SpeechDownloadProgress)? onProgress,
  }) async {
    if (_busy) {
      throw StateError('Speech model preparation is already in progress.');
    }
    _busy = true;
    final token = cancellation ?? SpeechCancellation();
    HttpClient? client;
    void Function()? removeCancel;
    try {
      token.check();
      final directory = await _directory();
      token.check();
      await directory.create(recursive: true);
      client = _clientFactory()..connectionTimeout = timeout;
      removeCancel = token.onCancel(() => client?.close(force: true));
      final total = manifest.fold<int>(0, (sum, spec) => sum + spec.size);
      var completed = 0;
      for (final spec in manifest) {
        token.check();
        final target = File(path.join(directory.path, spec.name));
        final partial = File('${target.path}.part');
        if (await partial.exists()) await partial.delete();
        if (await _valid(target, spec)) {
          token.check();
          completed += spec.size;
          onProgress?.call(SpeechDownloadProgress(spec.name, completed, total));
          continue;
        }
        if (await target.exists()) await target.delete();
        IOSink? sink;
        try {
          final request = await client
              .getUrl(Uri.parse('$repository/${spec.name}?download=true'))
              .timeout(timeout);
          token.check();
          final response = await request.close().timeout(timeout);
          if (response.statusCode != HttpStatus.ok) {
            throw HttpException(
              'Speech model download failed (${response.statusCode}).',
            );
          }
          if (response.contentLength >= 0 &&
              response.contentLength != spec.size) {
            throw const FormatException('Speech model size does not match.');
          }
          sink = partial.openWrite();
          var received = 0;
          await for (final bytes in response.timeout(timeout)) {
            token.check();
            received += bytes.length;
            if (received > spec.size) {
              throw const FormatException('Speech model is too large.');
            }
            sink.add(bytes);
            onProgress?.call(
              SpeechDownloadProgress(spec.name, completed + received, total),
            );
          }
          await sink.flush();
          await sink.close();
          sink = null;
          token.check();
          if (!await _valid(partial, spec)) {
            throw const FormatException(
              'Speech model checksum verification failed. Please retry.',
            );
          }
          token.check();
          await partial.rename(target.path);
          completed += spec.size;
        } finally {
          try {
            await sink?.close();
          } finally {
            if (await partial.exists()) await partial.delete();
          }
        }
      }
      token.check();
      return directory.path;
    } catch (_) {
      token.check();
      rethrow;
    } finally {
      removeCancel?.call();
      client?.close(force: true);
      _busy = false;
    }
  }
}
