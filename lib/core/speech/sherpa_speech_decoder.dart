import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

/// Keeps native recognition behind an injectable boundary for lifecycle tests.
abstract interface class SpeechDecoder {
  String accept(Float32List samples);
  bool get isEndpoint;
  void reset();
  String finish();
  void dispose();
}

class SherpaSpeechDecoder implements SpeechDecoder {
  SherpaSpeechDecoder(String directory) {
    sherpa.initBindings();
    _recognizer = sherpa.OnlineRecognizer(
      sherpa.OnlineRecognizerConfig(
        model: sherpa.OnlineModelConfig(
          transducer: sherpa.OnlineTransducerModelConfig(
            encoder: path.join(directory, 'encoder-epoch-99-avg-1.int8.onnx'),
            decoder: path.join(directory, 'decoder-epoch-99-avg-1.int8.onnx'),
            joiner: path.join(directory, 'joiner-epoch-99-avg-1.int8.onnx'),
          ),
          tokens: path.join(directory, 'tokens.txt'),
          // This February 2023 model uses the original Zipformer architecture.
          // Let sherpa read its metadata instead of forcing Zipformer2.
          modelType: '',
          numThreads: 2,
          debug: false,
        ),
        enableEndpoint: true,
        rule1MinTrailingSilence: 2.4,
        rule2MinTrailingSilence: 1.2,
      ),
    );
    try {
      _stream = _recognizer.createStream();
    } catch (_) {
      _recognizer.free();
      rethrow;
    }
  }
  late final sherpa.OnlineRecognizer _recognizer;
  late final sherpa.OnlineStream _stream;
  String _decode() {
    while (_recognizer.isReady(_stream)) {
      _recognizer.decode(_stream);
    }
    return _recognizer.getResult(_stream).text.trim();
  }

  @override
  String accept(Float32List samples) {
    _stream.acceptWaveform(samples: samples, sampleRate: 16000);
    return _decode();
  }

  @override
  bool get isEndpoint => _recognizer.isEndpoint(_stream);
  @override
  void reset() => _recognizer.reset(_stream);
  @override
  String finish() {
    _stream.acceptWaveform(samples: Float32List(8000), sampleRate: 16000);
    _stream.inputFinished();
    return _decode();
  }

  @override
  void dispose() {
    try {
      _stream.free();
    } finally {
      _recognizer.free();
    }
  }
}
