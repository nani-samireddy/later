import 'dart:async';

import 'package:later/core/speech/sherpa_speech_service.dart';
import 'package:later/core/speech/speech_model_store.dart';

class FakeVoiceSession implements SpeechSession {
  bool denyPermission = false;
  bool download = false;
  int starts = 0, stops = 0, disposals = 0;
  SpeechTextCallback? text;
  void Function(double)? level;
  void Function(Object)? error;
  void Function()? listening;
  void Function(SpeechDownloadProgress)? progress;
  Completer<void>? preparing;
  @override
  Future<void> start(
    SpeechTextCallback onText, {
    void Function(SpeechDownloadProgress)? onProgress,
    void Function()? onListening,
    void Function(double)? onLevel,
    void Function(Object)? onError,
  }) async {
    starts++;
    text = onText;
    level = onLevel;
    error = onError;
    listening = onListening;
    progress = onProgress;
    if (denyPermission) throw const MicrophonePermissionDenied();
    if (download) {
      preparing = Completer<void>();
      onProgress?.call(const SpeechDownloadProgress('model', 10, 100));
      await preparing!.future;
    } else {
      onListening?.call();
    }
  }

  @override
  Future<void> stop() async {
    stops++;
    if (preparing != null && !preparing!.isCompleted) {
      preparing!.completeError(const SpeechCancelled());
    }
  }

  @override
  Future<void> dispose() async {
    disposals++;
    await stop();
  }
}
