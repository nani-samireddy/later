import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/speech/gemini_speech_service.dart';
import 'package:later/core/speech/sherpa_speech_service.dart';

class Microphone implements SpeechMicrophone {
  final audio = StreamController<Uint8List>.broadcast();
  int starts = 0;
  int stops = 0;
  @override
  Future<bool> hasPermission() async => true;
  @override
  Future<Stream<Uint8List>> start() async {
    starts++;
    return audio.stream;
  }

  @override
  Future<void> stop() async {
    stops++;
  }

  @override
  Future<void> dispose() => audio.close();
}

Future<void> tick() => Future<void>.delayed(const Duration(milliseconds: 30));
void main() {
  test('production URL uses secure WebSocket and encodes ephemeral token', () {
    final uri = GeminiSpeechService.socketUri('auth_tokens/a+b/c');
    expect(uri.scheme, 'wss');
    expect(uri.host, 'generativelanguage.googleapis.com');
    expect(uri.path, endsWith('BidiGenerateContentConstrained'));
    expect(uri.queryParameters['access_token'], 'auth_tokens/a+b/c');
  });

  test('continuous stream survives finalized sentences and replaces interim text', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    WebSocket? peer;
    final incoming = <Map>[];
    server.listen((request) async {
      peer = await WebSocketTransformer.upgrade(request);
      peer!.listen((event) {
        final data = jsonDecode(event as String) as Map;
        incoming.add(data);
        if (data.containsKey('setup')) {
          peer!.add(jsonEncode({'setupComplete': {}}));
        }
        if ((data['realtimeInput'] as Map?)?['audioStreamEnd'] == true) {
          peer!.add(
            jsonEncode({
              'serverContent': {
                'inputTranscription': {'text': 'tomorrow'},
                'turnComplete': true,
              },
            }),
          );
        }
      });
    });
    final mic = Microphone();
    final text = <String>[];
    final service = GeminiSpeechService(
      microphone: mic,
      tokenProvider: () async => 'temporary',
      connect: (_) => WebSocket.connect('ws://127.0.0.1:${server.port}'),
    )..consent = true;
    try {
      await service.start(text.add);
      void send(Map content) =>
          peer!.add(jsonEncode({'serverContent': content}));
      send({
        'interimInputTranscription': {'text': 'buy'},
      });
      send({
        'interimInputTranscription': {'text': 'buy milk'},
      });
      send({
        'inputTranscription': {'text': 'Buy milk.'},
        'turnComplete': true,
      });
      await tick();
      expect(text.last, 'Buy milk.');
      expect(mic.starts, 1);
      expect(mic.stops, 0);
      // Audio still flows after an utterance ends; odd PCM boundaries retained.
      mic.audio.add(Uint8List.fromList([1]));
      mic.audio.add(Uint8List.fromList([2, 3, 4]));
      await tick();
      final audio = incoming
          .where((m) => (m['realtimeInput'] as Map?)?['audio'] != null)
          .single;
      expect(base64Decode(audio['realtimeInput']['audio']['data'] as String), [
        1,
        2,
        3,
        4,
      ]);
      send({
        'interimInputTranscription': {'text': 'tom'},
      });
      await tick();
      expect(text.last, 'Buy milk. tom');
      await service.stop();
      expect(text.last, 'Buy milk. tomorrow');
      expect(mic.starts, 1);
    } finally {
      await service.dispose();
      await peer?.close();
      await server.close(force: true);
    }
  });
  test('connection loss retains partial and releases microphone', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    WebSocket? peer;
    server.listen((request) async {
      peer = await WebSocketTransformer.upgrade(request);
      peer!.listen((event) {
        if ((jsonDecode(event as String) as Map).containsKey('setup')) {
          peer!.add(jsonEncode({'setupComplete': {}}));
        }
      });
    });
    final mic = Microphone();
    final values = <String>[];
    final failure = Completer<Object>();
    final service = GeminiSpeechService(
      microphone: mic,
      tokenProvider: () async => 'temporary',
      connect: (_) => WebSocket.connect('ws://127.0.0.1:${server.port}'),
    )..consent = true;
    try {
      await service.start(values.add, onError: failure.complete);
      peer!.add(
        jsonEncode({
          'serverContent': {
            'interimInputTranscription': {'text': 'remember this'},
          },
        }),
      );
      await tick();
      await peer!.close();
      expect(
        await failure.future.timeout(const Duration(seconds: 2)),
        isA<CloudSpeechFailure>(),
      );
      await tick();
      expect(values.last, 'remember this');
      expect(mic.stops, greaterThan(0));
      expect(mic.starts, 1);
    } finally {
      await service.dispose();
      await server.close(force: true);
    }
  });
  test('requires cloud consent before microphone or token access', () async {
    final mic = Microphone();
    var tokens = 0;
    final service = GeminiSpeechService(
      microphone: mic,
      tokenProvider: () async {
        tokens++;
        return '';
      },
    );
    await expectLater(
      service.start((_) {}),
      throwsA(isA<CloudSpeechFailure>()),
    );
    expect(tokens, 0);
    expect(mic.starts, 0);
    await service.dispose();
  });
  test(
    'cancel during token request never opens microphone or socket',
    () async {
      final token = Completer<String>();
      final mic = Microphone();
      var connections = 0;
      final service = GeminiSpeechService(
        microphone: mic,
        tokenProvider: () => token.future,
        connect: (_) async {
          connections++;
          throw StateError('unexpected');
        },
      )..consent = true;
      final starting = service.start((_) {});
      await tick();
      await service.dispose();
      token.complete('temporary');
      await starting;
      expect(connections, 0);
      expect(mic.starts, 0);
    },
  );
}
