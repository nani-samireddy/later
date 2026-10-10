import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart';

import 'pcm_audio.dart';
import 'sherpa_speech_decoder.dart';

import 'speech_model_store.dart';

export 'sherpa_speech_decoder.dart' show SpeechDecoder;

typedef SpeechTextCallback = void Function(String text);

class MicrophonePermissionDenied implements Exception {
  const MicrophonePermissionDenied();
  @override
  String toString() =>
      'Microphone access was denied. Allow access in device settings or type your entry.';
}

abstract interface class SpeechSession {
  Future<void> start(
    SpeechTextCallback onText, {
    void Function(SpeechDownloadProgress)? onProgress,
    void Function()? onListening,
    void Function(double level)? onLevel,
    void Function(Object error)? onError,
  });
  Future<void> stop();
  Future<void> dispose();
}

abstract interface class SpeechMicrophone {
  Future<bool> hasPermission();
  Future<Stream<Uint8List>> start();
  Future<void> stop();
  Future<void> dispose();
}

class _RecordMicrophone implements SpeechMicrophone {
  final _recorder = AudioRecorder();
  @override
  Future<bool> hasPermission() => _recorder.hasPermission();
  @override
  Future<Stream<Uint8List>> start() => _recorder.startStream(
    const RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 16000,
      numChannels: 1,
      noiseSuppress: true,
      echoCancel: true,
      streamBufferSize: 3200,
    ),
  );
  @override
  Future<void> stop() async {
    await _recorder.stop();
  }

  @override
  Future<void> dispose() => _recorder.dispose();
}

class SherpaSpeechService implements SpeechSession {
  SherpaSpeechService({
    SpeechMicrophone? microphone,
    Future<String> Function(
      SpeechCancellation,
      void Function(SpeechDownloadProgress)?,
    )?
    prepareModel,
    SpeechDecoder Function(String)? decoderFactory,
  }) : _microphone = microphone ?? _RecordMicrophone(),
       _prepareModel =
           prepareModel ??
           ((token, progress) => SpeechModelStore.ensureModel(
             cancellation: token,
             onProgress: progress,
           )),
       _decoderFactory = decoderFactory ?? SherpaSpeechDecoder.new;

  final SpeechMicrophone _microphone;
  final Future<String> Function(
    SpeechCancellation,
    void Function(SpeechDownloadProgress)?,
  )
  _prepareModel;
  final SpeechDecoder Function(String) _decoderFactory;
  SpeechDecoder? _decoder;
  StreamSubscription<Uint8List>? _audioSubscription;
  SpeechCancellation? _cancellation;
  Future<void>? _starting;
  Future<void>? _stopping;
  Future<void>? _disposing;
  bool _running = false;
  bool _microphoneStarted = false;
  bool _disposed = false;
  SpeechTextCallback? _onText;
  String _completed = '';
  String _partial = '';
  int? _pendingByte;

  @override
  Future<void> start(
    SpeechTextCallback onText, {
    void Function(SpeechDownloadProgress)? onProgress,
    void Function()? onListening,
    void Function(double)? onLevel,
    void Function(Object)? onError,
  }) async {
    if (_disposed) throw StateError('Speech service has been disposed.');
    if (_stopping != null) await _stopping;
    if (_disposed) throw StateError('Speech service has been disposed.');
    if (_running || _starting != null) {
      throw StateError('Speech capture is already active.');
    }
    final token = SpeechCancellation();
    _cancellation = token;
    _onText = onText;
    _completed = '';
    _partial = '';
    _pendingByte = null;
    final operation = _start(token, onProgress, onListening, onLevel, onError);
    _starting = operation;
    try {
      await operation;
    } finally {
      _starting = null;
    }
  }

  Future<void> _start(
    SpeechCancellation token,
    void Function(SpeechDownloadProgress)? onProgress,
    void Function()? onListening,
    void Function(double)? onLevel,
    void Function(Object)? onError,
  ) async {
    try {
      if (!await _microphone.hasPermission()) {
        throw const MicrophonePermissionDenied();
      }
      token.check();
      final directory = await _prepareModel(token, onProgress);
      token.check();
      _decoder = _decoderFactory(directory);
      token.check();
      _microphoneStarted = true;
      final audio = await _microphone.start();
      token.check();
      _running = true;
      _audioSubscription = audio.listen(
        (bytes) {
          if (!_running) return;
          try {
            // PCM stream chunks need not end on a sample boundary.
            final joined = _pendingByte == null
                ? bytes
                : (Uint8List(bytes.length + 1)
                    ..[0] = _pendingByte!
                    ..setRange(1, bytes.length + 1, bytes));
            _pendingByte = joined.length.isOdd ? joined.last : null;
            final samples = pcm16ToFloat32(joined);
            var peak = 0.0;
            for (final sample in samples) {
              if (sample.abs() > peak) peak = sample.abs();
            }
            onLevel?.call(peak);
            _partial = _decoder!.accept(samples);
            _publish();
            if (_decoder!.isEndpoint) {
              _completed = _text;
              _partial = '';
              _decoder!.reset();
            }
          } catch (error) {
            _streamFailed(error, onError);
          }
        },
        onError: (Object error) => _streamFailed(error, onError),
        onDone: () {
          if (_running) {
            _streamFailed(
              StateError('Microphone stream ended. Please retry.'),
              onError,
            );
          }
        },
      );
      onListening?.call();
    } catch (_) {
      await _release();
      token.check();
      rethrow;
    }
  }

  String get _text =>
      [_completed, _partial].where((text) => text.isNotEmpty).join(' ');
  void _publish() => _onText?.call(_text);
  void _streamFailed(Object error, void Function(Object)? onError) {
    if (!_running) return;
    _running = false;
    onError?.call(error);
    unawaited(
      stop().catchError((Object error) {
        onError?.call(error);
      }),
    );
  }

  @override
  Future<void> stop() {
    if (_stopping != null) return _stopping!;
    _cancellation?.cancel();
    final operation = _stop();
    _stopping = operation;
    return operation.whenComplete(() {
      _stopping = null;
    });
  }

  Future<void> _stop() async {
    try {
      await _starting;
    } catch (_) {
      /* Startup already reports its error. */
    }
    _running = false;
    try {
      if (_decoder != null && _microphoneStarted) {
        _partial = _decoder!.finish();
        _publish();
      }
    } finally {
      await _release();
    }
  }

  Future<void> _release() async {
    _running = false;
    try {
      await _audioSubscription?.cancel();
    } finally {
      _audioSubscription = null;
      try {
        if (_microphoneStarted) await _microphone.stop();
      } finally {
        _microphoneStarted = false;
        final decoder = _decoder;
        _decoder = null;
        _pendingByte = null;
        decoder?.dispose();
      }
    }
  }

  @override
  Future<void> dispose() => _disposing ??= _dispose();
  Future<void> _dispose() async {
    _disposed = true;
    try {
      await stop();
    } finally {
      await _microphone.dispose();
    }
  }
}
