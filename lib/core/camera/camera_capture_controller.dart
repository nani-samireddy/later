import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract interface class PhotoCamera {
  /// Returns a plugin-owned temporary file, or null when the user cancels.
  Future<String?> takePhoto();
}

class CameraCaptureException implements Exception {
  const CameraCaptureException(this.message);
  final String message;
}

class CameraTaskDraft {
  const CameraTaskDraft({
    required this.title,
    required this.description,
    required this.attachments,
    this.reminder,
  });
  final String title;
  final String description;
  final DateTime? reminder;
  final List<PlatformFile> attachments;
}

/// Owns temporary captures only. The save callback must await durable private
/// copies before returning true; paths in a draft expire when this session closes.
class CameraCaptureController extends ChangeNotifier {
  CameraCaptureController({
    required this.camera,
    Future<Directory> Function()? temporaryDirectory,
  }) : temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;
  final PhotoCamera camera;
  final Future<Directory> Function() temporaryDirectory;
  final List<PlatformFile> _photos = [];
  List<PlatformFile> get photos => List.unmodifiable(_photos);
  Directory? _session;
  Future<void>? _pending;
  bool busy = false;
  bool _closed = false;
  String? error;

  Future<void> capture() => _runCapture();

  /// Stages interrupted native captures for explicit review.
  Future<void> recover(Iterable<String> paths) async {
    for (final path in paths) {
      if (_closed) return;
      await _runCapture(path);
    }
  }

  Future<void> _runCapture([String? recoveredPath]) async {
    if (busy || _closed) return;
    busy = true;
    error = null;
    notifyListeners();
    final operation = _capture(recoveredPath);
    _pending = operation;
    await operation;
    _pending = null;
    busy = false;
    if (!_closed) notifyListeners();
  }

  Future<void> _capture(String? recoveredPath) async {
    String? source;
    Directory? root;
    try {
      source = recoveredPath ?? await camera.takePhoto();
      if (source == null) return;
      root = await temporaryDirectory();
      if (_closed) return;
      final staging = await Directory(p.join(root.path, 'later-camera'))
          .create(recursive: true);
      _session ??= await staging.createTemp('review-');
      final extension = p.extension(source).toLowerCase();
      final name =
          'photo_${DateTime.now().microsecondsSinceEpoch}${extension.isEmpty ? '.jpg' : extension}';
      final copy = await File(source).copy(p.join(_session!.path, name));
      if (!_closed) {
        _photos.add(
          PlatformFile(name: name, path: copy.path, size: await copy.length()),
        );
      }
    } on CameraCaptureException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Could not take this photo. Please try again.';
    } finally {
      // Never delete arbitrary injected paths or saved private attachments.
      if (source != null && root != null && p.isWithin(root.path, source)) {
        try {
          final file = File(source);
          if (await file.exists()) await file.delete();
        } on FileSystemException {
          /* Cache cleanup can be retried by the OS. */
        }
      }
    }
  }

  Future<void> remove(int index) async {
    if (busy || _closed) return;
    final photo = _photos.removeAt(index);
    notifyListeners();
    final file = File(photo.path!);
    if (await file.exists()) await file.delete();
  }

  Future<void> close() async {
    _closed = true;
    await _pending;
    final folder = _session;
    if (folder != null && await folder.exists()) {
      await folder.delete(recursive: true);
    }
    _photos.clear();
  }
}
