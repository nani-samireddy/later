import 'package:flutter/foundation.dart';

import 'sherpa_speech_service.dart';
import 'speech_model_store.dart';

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
    : _session = session ?? SherpaSpeechService(),
      _text = initialText;
  final SpeechSession _session;
  VoiceCapturePhase phase = VoiceCapturePhase.ready;
  SpeechDownloadProgress? progress;
  String? error;
  double level = 0;
  bool heardSound = false;
  String _text;
  String get text => _text;
  bool _closed = false;
  Future<void>? _closing;
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
    error = null;
    progress = null;
    heardSound = false;
    level = 0;
    phase = VoiceCapturePhase.requestingPermission;
    _changed();
    try {
      await _session.start(
        (value) {
          if (_closed) return;
          _text = value;
          _changed();
        },
        onProgress: (value) {
          if (_closed || phase == VoiceCapturePhase.stopping) return;
          progress = value;
          phase = VoiceCapturePhase.downloading;
          _changed();
        },
        onListening: () {
          if (_closed || phase == VoiceCapturePhase.stopping) return;
          _text = '';
          phase = VoiceCapturePhase.listening;
          _changed();
        },
        onLevel: (value) {
          if (_closed || phase != VoiceCapturePhase.listening) return;
          level = value.clamp(0, 1);
          heardSound = heardSound || level > 0.01;
          _changed();
        },
        onError: (value) {
          if (_closed || phase == VoiceCapturePhase.stopping) return;
          phase = VoiceCapturePhase.error;
          error = _message(value);
          _changed();
        },
      );
    } catch (value) {
      if (_closed || phase == VoiceCapturePhase.stopping) return;
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
    level = 0;
    _changed();
  }

  static String _message(Object error) => error is MicrophonePermissionDenied
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
