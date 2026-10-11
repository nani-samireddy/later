import 'package:flutter/foundation.dart';

import 'gemini_speech_service.dart';

import 'sherpa_speech_service.dart';
import 'speech_model_store.dart';
import 'native_speech_service.dart';

enum VoiceCapturePhase {
  ready,
  requestingPermission,
  downloading,
  listening,
  stopping,
  review,
  error,
}

/// Holds a reviewable draft only. Entry creation belongs to the caller.
class VoiceCaptureController extends ChangeNotifier {
  VoiceCaptureController({SpeechSession? session, String initialText = ''})
    : _session = session ?? GeminiSpeechService(),
      _text = initialText;
  final SpeechSession _session;
  GeminiSpeechService? get cloudSession =>
      _session is GeminiSpeechService ? _session : null;
  NativeSpeechService? get nativeSession =>
      _session is NativeSpeechService ? _session : null;
  void configureNative({String? language, bool? allowOnline}) {
    if (active || _closed) return;
    final native = nativeSession;
    if (native == null) return;
    if (language != null) native.language = language;
    if (allowOnline != null) native.allowOnline = allowOnline;
    _changed();
  }

  VoiceCapturePhase phase = VoiceCapturePhase.ready;
  SpeechDownloadProgress? progress;
  String? error;
  double level = 0;
  bool heardSound = false;
  String _text;
  String get text => _text;
  bool _closed = false;
  Future<void>? _closing;
  int _sessionGeneration = 0;
  bool get active => switch (phase) {
    VoiceCapturePhase.requestingPermission ||
    VoiceCapturePhase.downloading ||
    VoiceCapturePhase.listening ||
    VoiceCapturePhase.stopping => true,
    _ => false,
  };
  bool get canApply => !active && _text.trim().isNotEmpty;

  void _changed() {
    if (!_closed) notifyListeners();
  }

  void edit(String value) {
    if (_closed || active) return;
    _text = value;
    _changed();
  }

  Future<void> start() async {
    if (_closed || active) return;
    final generation = ++_sessionGeneration;
    final retainedText = _text;
    bool current() => !_closed && generation == _sessionGeneration;
    error = null;
    progress = null;
    heardSound = false;
    level = 0;
    phase = VoiceCapturePhase.requestingPermission;
    _changed();
    try {
      await _session.start(
        (value) {
          if (!current()) return;
          // Recognizer results replace the current segment, while earlier
          // paused segments (and any manually edited draft) remain intact.
          _text = value.trim().isEmpty
              ? retainedText
              : retainedText.trim().isEmpty
              ? value
              : '${retainedText.trimRight()} ${value.trimLeft()}';
          _changed();
        },
        onProgress: (value) {
          if (!current() || phase == VoiceCapturePhase.stopping) return;
          progress = value;
          phase = VoiceCapturePhase.downloading;
          _changed();
        },
        onListening: () {
          if (!current() || phase == VoiceCapturePhase.stopping) return;
          phase = VoiceCapturePhase.listening;
          _changed();
        },
        onLevel: (value) {
          if (!current() || phase != VoiceCapturePhase.listening) return;
          level = value.clamp(0, 1);
          heardSound = heardSound || level > 0.01;
          _changed();
        },
        onError: (value) {
          if (!current() || phase == VoiceCapturePhase.stopping) return;
          phase = VoiceCapturePhase.error;
          error = _message(value);
          _changed();
        },
      );
    } catch (value) {
      if (!current() || phase == VoiceCapturePhase.stopping) return;
      phase = value is SpeechCancelled
          ? VoiceCapturePhase.review
          : VoiceCapturePhase.error;
      error = value is SpeechCancelled ? null : _message(value);
      _changed();
    }
  }

  Future<void> stop() async {
    if (_closed || !active || phase == VoiceCapturePhase.stopping) return;
    phase = VoiceCapturePhase.stopping;
    _changed();
    try {
      await _session.stop();
      if (_closed) return;
      phase = VoiceCapturePhase.review;
    } catch (value) {
      if (_closed) return;
      phase = VoiceCapturePhase.error;
      error = _message(value);
    }
    // stop() may emit a final result before resolving. Accept that result,
    // then reject any stale callbacks before a resume can start.
    _sessionGeneration++;
    level = 0;
    _changed();
  }

  static String _message(Object error) =>
      error is MicrophonePermissionDenied ||
          error is NativeSpeechFailure ||
          error is CloudSpeechFailure
      ? error.toString()
      : 'Voice capture could not continue. Check your connection and microphone, then retry. You can also edit the text manually.';

  Future<void> close() {
    _closed = true;
    return _closing ??= _session.dispose();
  }

  @override
  void dispose() {
    // UI teardown cannot await. close() remains available for awaited cleanup.
    close().catchError((Object _) {});
    super.dispose();
  }
}
