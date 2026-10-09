import 'dart:async';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

import 'speech_model_store.dart';
import 'pcm_audio.dart';

typedef SpeechTextCallback = void Function(String text);

class SherpaSpeechService {
  final AudioRecorder _recorder = AudioRecorder();
  sherpa.OnlineRecognizer? _recognizer;
  sherpa.OnlineStream? _stream;
  StreamSubscription<Uint8List>? _audioSubscription;
  bool _running = false;

  Future<void> start(SpeechTextCallback onText) async {
    if (_running) return;
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) throw StateError('Microphone permission is required.');
    final modelDirectory = await SpeechModelStore.ensureModel();
    sherpa.initBindings();
    _recognizer = sherpa.OnlineRecognizer(
      sherpa.OnlineRecognizerConfig(
        model: sherpa.OnlineModelConfig(
          transducer: sherpa.OnlineTransducerModelConfig(
            encoder: path.join(modelDirectory, SpeechModelStore.files[0]),
            decoder: path.join(modelDirectory, SpeechModelStore.files[1]),
            joiner: path.join(modelDirectory, SpeechModelStore.files[2]),
          ),
          tokens: path.join(modelDirectory, SpeechModelStore.files[3]),
          modelType: 'zipformer2',
          numThreads: 2,
          debug: false,
        ),
        enableEndpoint: true,
        rule1MinTrailingSilence: 2.4,
        rule2MinTrailingSilence: 1.2,
      ),
    );
    _stream = _recognizer!.createStream();
    _running = true;
    final audio = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
        noiseSuppress: true,
        echoCancel: true,
        streamBufferSize: 3200,
      ),
    );
    _audioSubscription = audio.listen((bytes) {
      final samples = pcm16ToFloat32(bytes);
      final recognizer = _recognizer;
      final stream = _stream;
      if (!_running || recognizer == null || stream == null) return;
      stream.acceptWaveform(samples: samples, sampleRate: 16000);
      while (recognizer.isReady(stream)) {
        recognizer.decode(stream);
      }
      final text = recognizer.getResult(stream).text.trim();
      if (text.isNotEmpty) onText(text);
      if (recognizer.isEndpoint(stream)) recognizer.reset(stream);
    });
  }

  Future<void> stop() async {
    if (!_running) return;
    _running = false;
    await _recorder.stop();
    await _audioSubscription?.cancel();
    _audioSubscription = null;
    _stream?.free();
    _stream = null;
    _recognizer?.free();
    _recognizer = null;
  }

  Future<void> dispose() async {
    await stop();
    await _recorder.dispose();
  }
}
