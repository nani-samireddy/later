import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/speech/native_speech_service.dart';
import 'package:later/core/speech/speech_model_store.dart';
import 'package:later/core/speech/sherpa_speech_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('later/speech');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  var generation = 0;
  late NativeSpeechService service;
  Future<void> event(
    String type, [
    Map<String, Object> values = const {},
  ]) async {
    final complete = Completer<void>();
    messenger.handlePlatformMessage(
      'later/speech',
      const StandardMethodCodec().encodeMethodCall(
        MethodCall('event', {
          'type': type,
          'generation': generation,
          ...values,
        }),
      ),
      (_) => complete.complete(),
    );
    await complete.future;
  }

  setUp(() {
    service = NativeSpeechService(
      channel: channel,
      permission: () async => true,
    );
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'start') {
        generation = (call.arguments as Map)['generation'] as int;
      }
      if (call.method == 'stop') await event('final', {'text': 'last words'});
      return null;
    });
  });
  tearDown(() async {
    await service.dispose();
    messenger.setMockMethodCallHandler(channel, null);
  });
  test('pack checks preserve installed languages and do not imply download completion', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'cancel') return null;
      expect((call.arguments as Map)['language'], 'en-IN');
      if (call.method == 'languageSupport') {
        return {
          'status': 'checked',
          'installed': ['en-US'],
          'supported': ['en-IN'],
          'pending': [],
        };
      }
      if (call.method == 'downloadLanguage') return {'status': 'scheduled'};
      return null;
    });
    final support = await service.languageSupport();
    expect(support['installed'], ['en-US']);
    expect(support['supported'], ['en-IN']);
    expect(
      (await service.languageSupport(download: true))['status'],
      'scheduled',
    );
  });
  test(
    'partial replacements and final sentences do not duplicate words',
    () async {
      final results = <String>[];
      await service.start(results.add);
      await event('partial', {'text': 'buy'});
      await event('partial', {'text': 'buy milk'});
      await event('final', {'text': 'buy milk'});
      await event('partial', {'text': 'tomorrow'});
      expect(results, ['buy', 'buy milk', 'buy milk', 'buy milk tomorrow']);
      await service.stop();
      expect(results.last, 'buy milk last words');
      await event('partial', {'text': 'stale'});
      expect(results.last, 'buy milk last words');
    },
  );
  test(
    'native failures retain the existing transcript and expose useful errors',
    () async {
      String text = '';
      Object? failure;
      await service.start(
        (value) => text = value,
        onError: (value) => failure = value,
      );
      await event('partial', {'text': 'remember passport'});
      await event('error', {'message': 'Language pack unavailable'});
      expect(text, 'remember passport');
      expect(failure.toString(), 'Language pack unavailable');
    },
  );
  test(
    'on-device is default and online mode requires explicit selection',
    () async {
      Map? config;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'start') config = call.arguments as Map;
        return null;
      });
      await service.start((_) {});
      expect(config!['allowOnline'], false);
      expect(config!['language'], 'en-IN');
      await service.stop();
      service.allowOnline = true;
      service.language = 'te-IN';
      await service.start((_) {});
      expect(config!['allowOnline'], true);
      expect(config!['language'], 'te-IN');
    },
  );
  test('permission denial never starts native recognition', () async {
    final denied = NativeSpeechService(
      channel: channel,
      permission: () async => false,
    );
    var starts = 0;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'start') starts++;
      return null;
    });
    await expectLater(
      denied.start((_) {}),
      throwsA(isA<MicrophonePermissionDenied>()),
    );
    expect(starts, 0);
    await denied.dispose();
  });
  test(
    'empty final keeps the last partial and stale sessions cannot overwrite it',
    () async {
      final results = <String>[];
      await service.start(results.add);
      await event('partial', {'text': 'buy milk'});
      await event('final', {'text': ''});
      expect(results.last, 'buy milk');
      await service.stop();
      final old = generation;
      await service.start(results.add);
      final current = generation;
      generation = old;
      await event('partial', {'text': 'stale'});
      generation = current;
      await event('partial', {'text': 'fresh'});
      expect(results.last, 'fresh');
    },
  );
  test(
    'stopping during permission does not start a stale recognizer',
    () async {
      final permission = Completer<bool>();
      final delayed = NativeSpeechService(
        channel: channel,
        permission: () => permission.future,
      );
      var starts = 0;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'start') starts++;
        return null;
      });
      final start = delayed.start((_) {});
      final expectation = expectLater(start, throwsA(isA<SpeechCancelled>()));
      await delayed.stop();
      permission.complete(true);
      await expectation;
      expect(starts, 0);
      await delayed.dispose();
    },
  );
}
