import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/speech/sherpa_speech_service.dart';
import 'package:later/core/speech/speech_model_store.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

/// Opt-in check of production decoder + model using publisher-supplied audio.
/// SPEECH_NATIVE_MODEL_DIR must contain all manifest files and test_wavs/0.wav
/// (or 0.wav). No microphone is opened and nothing is downloaded by this test.
class _WaveMicrophone implements SpeechMicrophone {
  _WaveMicrophone(this.wave);
  final sherpa.WaveData wave;
  final audio = StreamController<Uint8List>();
  @override
  Future<bool> hasPermission() async => true;
  @override
  Future<Stream<Uint8List>> start() async => audio.stream;
  Future<void> feed() async {
    for (var offset = 0; offset < wave.samples.length; offset += 1600) {
      final count = min(1600, wave.samples.length - offset);
      final bytes = ByteData(count * 2);
      for (var index = 0; index < count; index++) {
        bytes.setInt16(
          index * 2,
          (wave.samples[offset + index] * 32767).round().clamp(-32768, 32767),
          Endian.little,
        );
      }
      audio.add(bytes.buffer.asUint8List());
      await Future<void>.delayed(Duration.zero);
    }
  }

  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {
    unawaited(audio.close());
  }
}

void main() {
  final directory = Platform.environment['SPEECH_NATIVE_MODEL_DIR'];
  test(
    'production model checksum and native streaming decoder recognize publisher WAV',
    () async {
      sherpa.initBindings(Platform.environment['SPEECH_NATIVE_LIBRARY_ROOT']);
      final model = Directory(directory!);
      final wavePath = File('${model.path}/0.wav').existsSync()
          ? '${model.path}/0.wav'
          : '${model.path}/test_wavs/0.wav';
      final wave = sherpa.readWave(wavePath);
      expect(wave.sampleRate, 16000);
      final mic = _WaveMicrophone(wave);
      final store = SpeechModelStore(directory: () async => model);
      final service = SherpaSpeechService(
        microphone: mic,
        prepareModel: (token, progress) =>
            store.prepare(cancellation: token, onProgress: progress),
      );
      final transcripts = <String>[];
      final errors = <Object>[];
      try {
        await service.start(transcripts.add, onError: errors.add);
        await mic.feed();
        // Require real changing hypotheses while PCM is arriving, before the
        // final flush. A decoder that only returns text on stop must fail here.
        final liveHypotheses = transcripts
            .where((text) => text.trim().isNotEmpty)
            .toSet();
        expect(liveHypotheses.length, greaterThan(1));
        expect(
          liveHypotheses.any(
            (text) => text.toLowerCase().contains('the yellow lamps'),
          ),
          isTrue,
        );
        await service.stop();
        expect(errors, isEmpty);
        expect(
          transcripts.last.toLowerCase(),
          contains('the yellow lamps would light up'),
        );
        expect(transcripts.last.toLowerCase(), contains('squalid quarter'));
      } finally {
        await service.dispose();
      }
    },
    skip: directory == null
        ? 'Set SPEECH_NATIVE_MODEL_DIR to run real native decoding with the pinned model.'
        : false,
  );
}
