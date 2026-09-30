import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

typedef SpeechTextCallback = void Function(String text);

class SherpaSpeechService {
  static const _modelRepository =
      'https://huggingface.co/csukuangfj/sherpa-onnx-streaming-zipformer-en-20M-2023-02-17/resolve/main';
  static const _files = [
    'encoder-epoch-99-avg-1.int8.onnx',
    'decoder-epoch-99-avg-1.int8.onnx',
    'joiner-epoch-99-avg-1.int8.onnx',
    'tokens.txt',
  ];

  final AudioRecorder _recorder = AudioRecorder();
  sherpa.OnlineRecognizer? _recognizer;
  sherpa.OnlineStream? _stream;
  StreamSubscription<Uint8List>? _audioSubscription;
  bool _running = false;

  Future<void> start(SpeechTextCallback onText) async {
    if (_running) return;
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) throw StateError('Microphone permission is required.');
    final modelDirectory = await _ensureModel();
    sherpa.initBindings();
    _recognizer = sherpa.OnlineRecognizer(
      sherpa.OnlineRecognizerConfig(
        model: sherpa.OnlineModelConfig(
          transducer: sherpa.OnlineTransducerModelConfig(
            encoder: path.join(modelDirectory, _files[0]),
            decoder: path.join(modelDirectory, _files[1]),
            joiner: path.join(modelDirectory, _files[2]),
          ),
          tokens: path.join(modelDirectory, _files[3]),
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
      final samples = _pcm16ToFloat32(bytes);
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

  Future<String> _ensureModel() async {
    final root = await getApplicationSupportDirectory();
    final directory = Directory(path.join(root.path, 'speech', 'zipformer-en'));
    await directory.create(recursive: true);
    final client = HttpClient();
    try {
      for (final fileName in _files) {
        final target = File(path.join(directory.path, fileName));
        if (await target.exists() && await target.length() > 0) continue;
        final request = await client.getUrl(
          Uri.parse('$_modelRepository/$fileName?download=true'),
        );
        final response = await request.close();
        if (response.statusCode != HttpStatus.ok) {
          throw HttpException(
            'Unable to download speech model file: $fileName',
            uri: request.uri,
          );
        }
        final sink = target.openWrite();
        await response.pipe(sink);
        await sink.close();
      }
    } finally {
      client.close(force: true);
    }
    return directory.path;
  }

  Float32List _pcm16ToFloat32(Uint8List bytes) {
    final result = Float32List(bytes.length ~/ 2);
    final data = ByteData.sublistView(bytes);
    for (var i = 0; i < result.length; i++) {
      result[i] = data.getInt16(i * 2, Endian.little) / 32768.0;
    }
    return result;
  }

  Future<void> dispose() async {
    await stop();
    await _recorder.dispose();
  }
}
