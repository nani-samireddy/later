import 'dart:async';
import 'dart:convert';

import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/ai/local_ai_service.dart';
import 'package:later/core/ai/local_ai_runtime.dart';

String entry({
  String kind = 'thing',
  String amount = '',
  String person = '',
  String description = 'Buy milk',
}) => jsonEncode({
  'kind': kind,
  'person': person,
  'amount': amount,
  'description': description,
});

class FakeRuntime implements LocalAiRuntime {
  @override
  bool supported = true;
  bool installed = false;
  int installs = 0, generations = 0;
  bool failInstall = false;
  String output = entry();
  Completer<void>? installGate;
  Completer<String>? generateGate;
  @override
  Future<bool> isInstalled() async => installed;
  @override
  Future<void> remove() async {
    installed = false;
  }

  @override
  Future<void> install(CancelToken token, void Function(int) progress) async {
    installs++;
    progress(40);
    if (installGate != null) await installGate!.future;
    token.throwIfCancelled();
    if (failInstall) throw StateError('No space');
    installed = true;
    progress(100);
  }

  @override
  Future<String> generate(String prompt, CancelToken token) async {
    generations++;
    return generateGate == null ? output : generateGate!.future;
  }
}

void main() {
  test('maps every app kind and legacy debt direction without guessing', () {
    for (final kind in ['thing', 'owedToMe', 'iOwe', 'spending']) {
      expect(LocalAiService.parseOutput(entry(kind: kind))!.kind, kind);
    }
    expect(LocalAiService.parseOutput(entry(kind: 'owedByMe'))!.kind, 'iOwe');
    expect(LocalAiService.parseOutput(entry(kind: 'debt')), isNull);
    expect(
      LocalAiService.parseOutput(entry(amount: '500.25', person: 'Ravi'))!
          .amount,
      '500.25',
    );
  });

  test(
    'rejects malformed, coerced, partial, oversized and ambiguous output',
    () {
      final invalid = [
        '',
        '<think>reasoning</think>${entry()}',
        'not JSON',
        '[]',
        '{}',
        '${entry()}${entry()}',
        'Here is ${entry()}',
        entry(amount: 'INR 500'),
        entry(amount: '1,500'),
        entry(amount: '-500'),
        entry(amount: '0'),
        entry(amount: '1.234'),
        entry(amount: '1e4'),
        entry(person: 'a' * 121),
        entry(description: 'a' * 1001),
        entry(description: '\u0000'),
        entry(description: ''),
        jsonEncode({
          'kind': 'thing',
          'person': 123,
          'amount': '',
          'description': 'hi',
        }),
        jsonEncode({
          'kind': 'thing',
          'person': '',
          'amount': '',
          'description': 'hi',
          'extra': '',
        }),
      ];
      for (final text in invalid) {
        expect(LocalAiService.parseOutput(text), isNull, reason: text);
      }
      expect(LocalAiService.parseOutput('```json\n${entry()}\n```'), isNotNull);
      expect(
        LocalAiService.parseOutput('<think>\n\n</think>\n\n${entry()}'),
        isNotNull,
      );
    },
  );

  test(
    'missing, unsupported and long input preserve fallback without downloads',
    () async {
      final runtime = FakeRuntime();
      final service = LocalAiService(runtime: runtime);
      expect(await service.extract('Paid 500 to Ravi'), isNull);
      expect(service.status, LocalAiStatus.missing);
      expect(await service.extract('x' * 1801), isNull);
      expect(await service.extract('  '), isNull);
      runtime.supported = false;
      await service.install();
      expect(service.status, LocalAiStatus.unsupported);
      expect(runtime.installs, 0);
      expect(runtime.generations, 0);
      service.dispose();
    },
  );

  test('installation reports progress, tests execution and removal restores fallback', () async {
    final runtime = FakeRuntime();
    final service = LocalAiService(runtime: runtime);
    await service.install();
    expect(service.progress, 100);
    expect(service.status, LocalAiStatus.ready);
    expect(runtime.generations, 1);
    await service.remove();
    expect(service.status, LocalAiStatus.missing);
    expect(await service.extract('Buy milk'), isNull);
    service.dispose();
  });

  test(
    'failed install can retry and malformed extraction returns fallback',
    () async {
      final runtime = FakeRuntime()..failInstall = true;
      final service = LocalAiService(runtime: runtime);
      await service.install();
      expect(service.status, LocalAiStatus.failed);
      runtime.failInstall = false;
      await service.install();
      expect(service.status, LocalAiStatus.ready);
      runtime.output = 'bad output';
      expect(await service.extract('Buy milk'), isNull);
      expect(service.status, LocalAiStatus.failed);
      runtime.output = entry(kind: 'iOwe', person: 'Ravi', amount: '500');
      expect((await service.extract('I owe Ravi 500'))!.kind, 'iOwe');
      service.dispose();
    },
  );

  test(
    'cancel returns promptly but retains lock until native work settles',
    () async {
      final runtime = FakeRuntime()..installGate = Completer<void>();
      final service = LocalAiService(runtime: runtime);
      final pending = service.install();
      await Future<void>.delayed(Duration.zero);
      expect(service.progress, 40);
      service.cancel();
      await pending;
      expect(service.status, LocalAiStatus.cancelled);
      expect(service.working, isTrue);
      await service.install();
      expect(runtime.installs, 1);
      runtime.installGate!.complete();
      await Future<void>.delayed(Duration.zero);
      expect(service.working, isFalse);
      runtime.installGate = null;
      await service.install();
      expect(service.status, LocalAiStatus.ready);
      service.dispose();
    },
  );

  test(
    'bounded extraction ignores late output and prevents concurrent sessions',
    () async {
      final runtime = FakeRuntime()
        ..installed = true
        ..generateGate = Completer<String>();
      final service = LocalAiService(
        runtime: runtime,
        inferenceTimeout: const Duration(milliseconds: 10),
      );
      expect(await service.extract('Buy milk'), isNull);
      expect(service.status, LocalAiStatus.failed);
      expect(service.working, isTrue);
      expect(await service.extract('other'), isNull);
      expect(runtime.generations, 1);
      runtime.generateGate!.complete('bad output');
      await Future<void>.delayed(Duration.zero);
      expect(service.working, isFalse);
      expect(service.status, LocalAiStatus.failed);
      runtime.generateGate = null;
      expect(await service.extract('Buy milk'), isNotNull);
      service.dispose();
    },
  );

  test('disposal cancels without notifying a disposed controller', () async {
    final runtime = FakeRuntime()
      ..installed = true
      ..generateGate = Completer<String>();
    final service = LocalAiService(runtime: runtime);
    final pending = service.extract('Buy milk');
    await Future<void>.delayed(Duration.zero);
    service.dispose();
    expect(await pending, isNull);
    runtime.generateGate!.complete(entry());
    await Future<void>.delayed(Duration.zero);
  });
}
