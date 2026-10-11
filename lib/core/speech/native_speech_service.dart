import 'dart:async';

import 'package:flutter/services.dart';
import 'package:record/record.dart';

import 'sherpa_speech_service.dart';
import 'speech_model_store.dart';

class NativeSpeechFailure implements Exception {
  final String message;
  const NativeSpeechFailure(this.message);
  @override
  String toString() => message;
}

/// Android owns audio capture; this recorder only requests microphone permission.
class NativeSpeechService implements SpeechSession {
  NativeSpeechService({
    MethodChannel? channel,
    Future<bool> Function()? permission,
  }) : _channel = channel ?? const MethodChannel('later/speech'),
       _permission = permission,
       _permissionRecorder = permission == null ? AudioRecorder() : null;
  final MethodChannel _channel;
  final Future<bool> Function()? _permission;
  final AudioRecorder? _permissionRecorder;
  String language = 'en-IN';
  bool allowOnline = false;
  bool usingOnDevice = true;
  String _committed = '';
  String _partial = '';
  int _generation = 0;
  bool _disposed = false;
  bool _running = false;
  SpeechTextCallback? _onText;
  void Function()? _onListening;
  void Function(double)? _onLevel;
  void Function(Object)? _onError;

  Future<Map<String, dynamic>> languageSupport({bool download = false}) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      download ? 'downloadLanguage' : 'languageSupport',
      {'language': language},
    );
    return result ?? {'status': 'unknown'};
  }

  void _emit() => _onText?.call(
    [_committed, _partial].where((value) => value.isNotEmpty).join(' '),
  );

  Future<void> _event(MethodCall call) async {
    if (_disposed || !_running || call.method != 'event') return;
    final event = Map<String, dynamic>.from(call.arguments as Map);
    if (event['generation'] != _generation) return;
    switch (event['type']) {
      case 'ready':
        usingOnDevice = event['onDevice'] == true;
        _onListening?.call();
      case 'partial':
        _partial = (event['text'] as String? ?? '').trim();
        _emit();
      case 'final':
        final finalText = (event['text'] as String? ?? '').trim();
        final text = finalText.isEmpty ? _partial : finalText;
        if (text.isNotEmpty) {
          _committed = [_committed, text].where((v) => v.isNotEmpty).join(' ');
        }
        _partial = '';
        _emit();
      case 'level':
        _onLevel?.call((event['level'] as num).toDouble());
      case 'error':
        _running = false;
        _onError?.call(NativeSpeechFailure(event['message'] as String));
    }
  }

  @override
  Future<void> start(
    SpeechTextCallback onText, {
    void Function(SpeechDownloadProgress)? onProgress,
    void Function()? onListening,
    void Function(double)? onLevel,
    void Function(Object)? onError,
  }) async {
    if (_disposed || _running) throw StateError('Voice capture is unavailable');
    final generation = ++_generation;
    final permitted =
        await (_permission?.call() ?? _permissionRecorder!.hasPermission());
    if (_disposed || generation != _generation) throw const SpeechCancelled();
    if (!permitted) throw const MicrophonePermissionDenied();
    _committed = '';
    _partial = '';
    _onText = onText;
    _onListening = onListening;
    _onLevel = onLevel;
    _onError = onError;
    _running = true;
    _channel.setMethodCallHandler(_event);
    try {
      await _channel.invokeMethod<void>('start', {
        'generation': generation,
        'language': language,
        'allowOnline': allowOnline,
      });
    } on PlatformException catch (error) {
      _running = false;
      throw NativeSpeechFailure(
        error.message ?? 'Speech recognition is unavailable.',
      );
    } catch (_) {
      _running = false;
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    // Invalidate pending permission requests even before native capture starts.
    if (!_running) {
      _generation++;
      return;
    }
    try {
      await _channel.invokeMethod<void>('stop');
      // Keep the last hypothesis if the recognizer times out without a final.
      _emit();
    } finally {
      _running = false;
      _generation++;
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _generation++;
    _running = false;
    _channel.setMethodCallHandler(null);
    try {
      await _channel.invokeMethod<void>('cancel');
    } finally {
      await _permissionRecorder?.dispose();
    }
  }
}
