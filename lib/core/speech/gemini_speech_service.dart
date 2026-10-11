import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'sherpa_speech_service.dart';
import 'speech_model_store.dart';

class CloudSpeechFailure implements Exception {
  const CloudSpeechFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

/// One microphone stream and one socket for the entire capture, including pauses.
class GeminiSpeechService implements SpeechSession {
  GeminiSpeechService({
    SpeechMicrophone? microphone,
    this.tokenProvider,
    this.connect,
  }) : _microphone = microphone ?? RecordSpeechMicrophone();
  final SpeechMicrophone _microphone;
  final Future<String> Function()? tokenProvider;
  final Future<WebSocket> Function(String token)? connect;
  static const endpoint = String.fromEnvironment('VOICE_TOKEN_URL');
  static const model = 'gemini-3.5-transcribe-live';
  static Uri socketUri(String token) => Uri(
    scheme: 'wss',
    host: 'generativelanguage.googleapis.com',
    path: '/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContentConstrained',
    queryParameters: {'access_token': token},
  );
  bool consent = false;
  WebSocket? _socket;
  StreamSubscription<dynamic>? _messages;
  StreamSubscription<Uint8List>? _audio;
  Timer? _limit;
  Completer<void>? _ready;
  Completer<void>? _final;
  int _generation = 0;
  bool _active = false;
  bool _disposed = false;
  String _committed = '';
  String _partial = '';
  SpeechTextCallback? _onText;
  void Function(Object)? _onError;
  Future<void>? _stopping;
  int? _pendingByte;

  Future<String> _token() async {
    final uri = Uri.tryParse(endpoint);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw const CloudSpeechFailure(
        'Cloud voice is not configured in this build. Set VOICE_TOKEN_URL to the deployed Worker URL.',
      );
    }
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client
          .postUrl(uri)
          .timeout(const Duration(seconds: 15));
      final response = await request.close().timeout(
        const Duration(seconds: 20),
      );
      if (response.statusCode != 200) {
        throw CloudSpeechFailure(switch (response.statusCode) {
          429 => 'Voice request limit reached. Please try again later.',
          _ => 'Cloud voice is unavailable. Your draft is retained. Please retry later.',
        });
      }
      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 10));
      final token = (jsonDecode(body) as Map)['token'];
      if (token is! String || token.isEmpty) throw const FormatException();
      return token;
    } finally {
      client.close(force: true);
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
    if (_stopping != null) await _stopping;
    if (_disposed || _active) throw StateError('Voice session unavailable.');
    if (!consent) {
      throw const CloudSpeechFailure(
        'Allow audio to be sent to Google for live transcription, then tap the microphone.',
      );
    }
    final generation = ++_generation;
    bool current() => !_disposed && generation == _generation;
    _active = true;
    _committed = '';
    _partial = '';
    _pendingByte = null;
    _onText = onText;
    _onError = onError;
    try {
      if (!await _microphone.hasPermission()) {
        throw const MicrophonePermissionDenied();
      }
      if (!current()) return;
      final token = await (tokenProvider?.call() ?? _token());
      if (!current()) return;
      final socket =
          await (connect?.call(token) ??
                  WebSocket.connect(socketUri(token).toString()))
              .timeout(const Duration(seconds: 15));
      if (!current()) {
        await socket.close();
        return;
      }
      _socket = socket;
      _ready = Completer<void>();
      _messages = socket.listen(
        (event) {
          if (!current()) return;
          try {
            final data = jsonDecode(
              event is String ? event : utf8.decode(event as List<int>),
            ) as Map;
            if (data.containsKey('setupComplete')) {
              if (!_ready!.isCompleted) _ready!.complete();
            }
            if (data.containsKey('error')) {
              _fail(
                const CloudSpeechFailure(
                  'Google could not start transcription. Check the backend model access and billing.',
                ),
              );
              return;
            }
            if (data.containsKey('goAway')) {
              _fail(
                const CloudSpeechFailure(
                  'The voice session has ended. Your draft is retained; resume to continue.',
                ),
              );
              return;
            }
            final content = data['serverContent'] as Map?;
            if (content == null) return;
            final interim = content['interimInputTranscription'] as Map?;
            final finalized = content['inputTranscription'] as Map?;
            if (interim?['text'] is String) {
              _partial = interim!['text'] as String;
            }
            if (finalized?['text'] is String) {
              final text = (finalized!['text'] as String).trim();
              if (text.isNotEmpty) {
                _committed = [
                  _committed,
                  text,
                ].where((s) => s.isNotEmpty).join(' ');
              }
              _partial = '';
            }
            _publish();
            if (content['turnComplete'] == true &&
                _final != null &&
                !_final!.isCompleted) {
              _final!.complete();
            }
          } catch (_) {
            _fail(
              const CloudSpeechFailure(
                'Unexpected transcription response. Your draft is retained.',
              ),
            );
          }
        },
        onError: (Object _) {
          if (current()) {
            _fail(
              const CloudSpeechFailure(
                'Voice connection was interrupted. Your draft is retained; resume to continue.',
              ),
            );
          }
        },
        onDone: () {
          if (current()) {
            _fail(
              const CloudSpeechFailure(
                'Voice connection closed. Your draft is retained; resume to continue.',
              ),
            );
          }
        },
      );
      socket.add(
        jsonEncode({
          'setup': {
            'model': 'models/$model',
            'generationConfig': {
              'responseModalities': ['TEXT'],
            },
            'inputAudioTranscription': {'languageCodes': <String>[]},
          },
        }),
      );
      await _ready!.future.timeout(const Duration(seconds: 15));
      if (!current()) return;
      final stream = await _microphone.start();
      if (!current()) {
        await _microphone.stop();
        return;
      }
      _audio = stream.listen(
        (bytes) {
          if (!current() || !_active) return;
          // Normalize odd byte boundaries and cap each outgoing message at 100 ms.
          final joined = _pendingByte == null
              ? bytes
              : (Uint8List(bytes.length + 1)
                  ..[0] = _pendingByte!
                  ..setRange(1, bytes.length + 1, bytes));
          _pendingByte = joined.length.isOdd ? joined.last : null;
          final length = joined.length - (joined.length % 2);
          double peak = 0;
          for (var i = 0; i < length; i += 2) {
            var sample = joined[i] | joined[i + 1] << 8;
            if (sample >= 32768) sample -= 65536;
            final level = sample.abs() / 32768;
            if (level > peak) peak = level;
          }
          onLevel?.call(peak);
          for (var offset = 0; offset < length; offset += 3200) {
            final end = (offset + 3200).clamp(0, length);
            socket.add(
              jsonEncode({
                'realtimeInput': {
                  'audio': {
                    'data': base64Encode(
                      Uint8List.sublistView(joined, offset, end),
                    ),
                    'mimeType': 'audio/pcm;rate=16000',
                  },
                },
              }),
            );
          }
        },
        onError: (Object _) => _fail(
          const CloudSpeechFailure(
            'Microphone stream failed. Your draft is retained.',
          ),
        ),
        onDone: () {
          if (current() && _active) {
            _fail(
              const CloudSpeechFailure(
                'Microphone stopped. Resume to continue.',
              ),
            );
          }
        },
      );
      // Notes are bounded to five minutes, avoiding provider session rotation.
      _limit = Timer(
        const Duration(minutes: 5),
        () => _fail(
          const CloudSpeechFailure(
            'Five-minute voice limit reached. Review your draft or resume to continue.',
          ),
        ),
      );
      onListening?.call();
    } catch (error) {
      if (!current()) return;
      await _cleanup();
      _active = false;
      _generation++;
      if (error is MicrophonePermissionDenied || error is CloudSpeechFailure) {
        rethrow;
      }
      throw const CloudSpeechFailure(
        'Could not connect to cloud voice. Check your internet and retry.',
      );
    }
  }

  void _publish() => _onText?.call(
    [_committed, _partial.trim()].where((s) => s.isNotEmpty).join(' '),
  );
  void _fail(Object error) {
    if (!_active) return;
    _active = false;
    _publish();
    _generation++;
    if (_ready != null && !_ready!.isCompleted) _ready!.complete();
    if (_final != null && !_final!.isCompleted) _final!.complete();
    _onError?.call(error);
    _stopping = _cleanup().whenComplete(() => _stopping = null);
  }

  Future<void> _cleanup() async {
    _limit?.cancel();
    await _audio?.cancel();
    _audio = null;
    try {
      await _microphone.stop();
    } finally {
      await _messages?.cancel();
      _messages = null;
      await _socket?.close().timeout(
        const Duration(seconds: 2),
        onTimeout: () {},
      );
      _socket = null;
    }
  }

  @override
  Future<void> stop() =>
      _stopping ??= _stop().whenComplete(() => _stopping = null);
  Future<void> _stop() async {
    if (!_active) return;
    _active = false;
    _limit?.cancel();
    await _audio?.cancel();
    _audio = null;
    await _microphone.stop();
    if (_socket != null && _ready?.isCompleted == true) {
      _final = Completer<void>();
      _socket!.add(
        jsonEncode({
          'realtimeInput': {'audioStreamEnd': true},
        }),
      );
      await _final!.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () {},
      );
    }
    _publish();
    _generation++;
    await _cleanup();
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _generation++;
    _active = false;
    if (_ready != null && !_ready!.isCompleted) _ready!.complete();
    if (_final != null && !_final!.isCompleted) _final!.complete();
    if (_stopping != null) await _stopping;
    await _cleanup();
    await _microphone.dispose();
  }
}
