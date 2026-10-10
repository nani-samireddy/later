import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/speech/sherpa_speech_service.dart';
import 'package:later/core/speech/speech_model_store.dart';

class FakeMicrophone implements SpeechMicrophone {
  bool permission = true;
  int starts = 0, stops = 0, disposals = 0;
  Completer<bool>? permissionGate;
  Completer<Stream<Uint8List>>? startGate;
  Object? stopError;
  final audio = StreamController<Uint8List>();
  @override
  Future<bool> hasPermission() async =>
      permissionGate == null ? permission : await permissionGate!.future;
  @override
  Future<Stream<Uint8List>> start() async {
    starts++;
    return startGate == null ? audio.stream : await startGate!.future;
  }

  @override
  Future<void> stop() async {
    stops++;
    if (stopError != null) throw stopError!;
  }

  @override
  Future<void> dispose() async {
    disposals++;
    unawaited(audio.close());
  }
}

class FakeDecoder implements SpeechDecoder {
  int accepts = 0, resets = 0, disposals = 0, finishes = 0;
  final samples = <double>[];
  String current = '';
  Object? finishError;
  @override
  String accept(Float32List input) {
    samples.addAll(input);
    accepts++;
    current = accepts == 1 ? 'call Maya' : 'tomorrow';
    return current;
  }

  @override
  bool get isEndpoint => accepts == 1 && resets == 0;
  @override
  void reset() {
    resets++;
    current = '';
  }

  @override
  String finish() {
    finishes++;
    if (finishError != null) throw finishError!;
    return current;
  }

  @override
  void dispose() {
    disposals++;
  }
}

void main() {
  late FakeMicrophone mic;
  late FakeDecoder decoder;
  late SherpaSpeechService service;
  late Future<String> Function(
    SpeechCancellation,
    void Function(SpeechDownloadProgress)?,
  )
  prepare;
  var prepares = 0;
  setUp(() {
    prepares = 0;
    mic = FakeMicrophone();
    decoder = FakeDecoder();
    prepare = (_, _) async {
      prepares++;
      return '/model';
    };
    service = SherpaSpeechService(
      microphone: mic,
      prepareModel: (token, progress) => prepare(token, progress),
      decoderFactory: (_) => decoder,
    );
  });
  tearDown(() async {
    mic.stopError = null;
    decoder.finishError = null;
    try {
      await service.dispose();
    } catch (_) {}
  });

  test(
    'permission denial does not download, initialize decoder or record',
    () async {
      mic.permission = false;
      await expectLater(
        service.start((_) {}),
        throwsA(isA<MicrophonePermissionDenied>()),
      );
      expect(prepares, 0);
      expect(mic.starts, 0);
      expect(decoder.disposals, 0);
      mic.permission = true;
      await service.start((_) {});
      expect(mic.starts, 1);
    },
  );

  test('stop while waiting for permission prevents late recording', () async {
    mic.permissionGate = Completer<bool>();
    final starting = service.start((_) {});
    final result = expectLater(starting, throwsA(isA<SpeechCancelled>()));
    final stopping = service.stop();
    mic.permissionGate!.complete(true);
    await result;
    await stopping;
    expect(mic.starts, 0);
    expect(prepares, 0);
  });

  test('dispose cancels model preparation and rejects future starts', () async {
    final entered = Completer<void>();
    prepare = (token, _) async {
      final aborted = Completer<void>();
      token.onCancel(() => aborted.complete());
      entered.complete();
      await aborted.future;
      token.check();
      return '/model';
    };
    final result = expectLater(
      service.start((_) {}),
      throwsA(isA<SpeechCancelled>()),
    );
    await entered.future;
    await service.dispose();
    await result;
    expect(mic.starts, 0);
    expect(mic.disposals, 1);
    await service.dispose();
    expect(mic.disposals, 1);
    await expectLater(service.start((_) {}), throwsStateError);
  });

  test(
    'stop during recorder startup stops recorder and frees decoder once',
    () async {
      mic.startGate = Completer<Stream<Uint8List>>();
      final result = expectLater(
        service.start((_) {}),
        throwsA(isA<SpeechCancelled>()),
      );
      await Future<void>.delayed(Duration.zero);
      expect(mic.starts, 1);
      final stopping = service.stop();
      mic.startGate!.complete(mic.audio.stream);
      await stopping;
      await result;
      expect(mic.stops, 1);
      expect(decoder.disposals, 1);
      await service.stop();
      expect(mic.stops, 1);
    },
  );

  test('preserves endpoint phrases, flushes final text and handles split PCM samples', () async {
    final texts = <String>[];
    final levels = <double>[];
    var listening = false;
    await service.start(
      texts.add,
      onListening: () => listening = true,
      onLevel: levels.add,
    );
    expect(listening, true);
    mic.audio.add(Uint8List.fromList([0, 64, 0]));
    await Future<void>.delayed(Duration.zero);
    mic.audio.add(Uint8List.fromList([128]));
    await Future<void>.delayed(Duration.zero);
    await service.stop();
    expect(texts.last, 'call Maya tomorrow');
    expect(decoder.samples, [0.5, -1.0]);
    expect(levels, [0.5, 1.0]);
    expect(decoder.finishes, 1);
    expect(decoder.disposals, 1);
    expect(mic.stops, 1);
    mic.audio.add(Uint8List.fromList([0, 64]));
    await Future<void>.delayed(Duration.zero);
    expect(decoder.accepts, 2);
  });

  test(
    'native finish failure still releases subscription, recorder and decoder',
    () async {
      await service.start((_) {});
      decoder.finishError = StateError('native finish failed');
      await expectLater(service.stop(), throwsStateError);
      expect(mic.stops, 1);
      expect(decoder.disposals, 1);
    },
  );

  test(
    'recorder stop failure still frees decoder and disposes recorder',
    () async {
      await service.start((_) {});
      mic.stopError = StateError('recorder failed');
      await expectLater(service.dispose(), throwsStateError);
      expect(decoder.disposals, 1);
      expect(mic.disposals, 1);
      // Idempotent disposal returns the same failed operation without releasing twice.
      mic.stopError = null;
      await expectLater(service.dispose(), throwsStateError);
    },
  );

  test(
    'unexpected microphone stream failure reports error and cleans up',
    () async {
      final errors = <Object>[];
      await service.start((_) {}, onError: errors.add);
      mic.audio.addError(StateError('lost microphone'));
      await Future<void>.delayed(Duration.zero);
      await service.stop();
      expect(errors, hasLength(1));
      expect(mic.stops, 1);
      expect(decoder.disposals, 1);
    },
  );
}
