import 'dart:async';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/speech/speech_model_store.dart';

void main() {
  late Directory directory;
  late HttpServer server;
  late SpeechModelStore store;
  final bytes = List<int>.generate(64, (i) => i);
  final spec = SpeechModelFile(
    'model.onnx',
    bytes.length,
    sha256.convert(bytes).toString(),
  );
  late Future<void> Function(HttpRequest) respond;
  var requests = 0;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('speech-model-test');
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    requests = 0;
    respond = (request) async {
      request.response.contentLength = bytes.length;
      request.response.add(bytes);
      await request.response.close();
    };
    server.listen((request) {
      requests++;
      unawaited(respond(request));
    });
    store = SpeechModelStore(
      directory: () async => directory,
      repository: 'http://127.0.0.1:${server.port}',
      manifest: [spec],
      timeout: const Duration(seconds: 2),
    );
  });
  tearDown(() async {
    await server.close(force: true);
    await directory.delete(recursive: true);
  });
  File target() => File('${directory.path}/${spec.name}');
  File partial() => File('${target().path}.part');

  test(
    'validated atomic download, monotonic progress and offline reuse',
    () async {
      final progress = <SpeechDownloadProgress>[];
      expect(await store.prepare(onProgress: progress.add), directory.path);
      expect(await target().readAsBytes(), bytes);
      expect(await partial().exists(), false);
      expect(progress.last.fraction, 1);
      for (var i = 1; i < progress.length; i++) {
        expect(
          progress[i].receivedBytes,
          greaterThanOrEqualTo(progress[i - 1].receivedBytes),
        );
      }
      await store.prepare();
      expect(requests, 1);
    },
  );

  test('rejects same-size corrupt bytes then retries successfully', () async {
    respond = (request) async {
      request.response.add(List.filled(bytes.length, 0));
      await request.response.close();
    };
    await expectLater(store.prepare(), throwsFormatException);
    expect(await target().exists(), false);
    expect(await partial().exists(), false);
    respond = (request) async {
      request.response.add(bytes);
      await request.response.close();
    };
    await store.prepare();
    expect(await target().readAsBytes(), bytes);
  });

  test(
    'repairs stale partial and same-size corrupt legacy final file',
    () async {
      await partial().writeAsBytes([1, 2]);
      await target().writeAsBytes(List.filled(bytes.length, 0));
      await store.prepare();
      expect(await target().readAsBytes(), bytes);
      expect(await partial().exists(), false);
      expect(requests, 1);
    },
  );

  test('cancel during stalled response removes partial and permits retry', () async {
    final stalled = Completer<void>();
    respond = (request) async {
      request.response.add(bytes.take(10).toList());
      await request.response.flush();
      stalled.complete();
      // Deliberately leave response open until cancellation closes the client.
    };
    final token = SpeechCancellation();
    final operation = store.prepare(
      cancellation: token,
      onProgress: (_) => token.cancel(),
    );
    final result = expectLater(operation, throwsA(isA<SpeechCancelled>()));
    await stalled.future;
    token.cancel();
    await result;
    expect(await target().exists(), false);
    expect(await partial().exists(), false);
    respond = (request) async {
      request.response.add(bytes);
      await request.response.close();
    };
    await store.prepare();
    expect(await target().readAsBytes(), bytes);
  });

  test('truncated and oversized responses never become final files', () async {
    for (final data in [
      bytes.take(10).toList(),
      [...bytes, 1],
    ]) {
      respond = (request) async {
        request.response.add(data);
        await request.response.close();
      };
      await expectLater(store.prepare(), throwsFormatException);
      expect(await target().exists(), false);
      expect(await partial().exists(), false);
    }
  });

  test('HTTP failure and cancelled-before-start are retryable', () async {
    respond = (request) async {
      request.response.statusCode = 503;
      await request.response.close();
    };
    await expectLater(store.prepare(), throwsA(isA<HttpException>()));
    final token = SpeechCancellation()..cancel();
    await expectLater(
      store.prepare(cancellation: token),
      throwsA(isA<SpeechCancelled>()),
    );
    expect(requests, 1);
    expect(await partial().exists(), false);
  });

  test('overlapping preparation cannot race on shared partial files', () async {
    final requested = Completer<void>();
    respond = (request) async {
      requested.complete();
    };
    final token = SpeechCancellation();
    final first = store.prepare(cancellation: token);
    final result = expectLater(first, throwsA(isA<SpeechCancelled>()));
    await requested.future;
    await expectLater(store.prepare(), throwsStateError);
    token.cancel();
    await result;
  });
}
