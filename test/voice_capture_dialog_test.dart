import 'package:later/core/speech/voice_capture_controller.dart';
import 'package:later/core/speech/gemini_speech_service.dart';
import 'package:flutter/services.dart';
import 'package:later/core/speech/native_speech_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/features/capture/presentation/voice_capture_dialog.dart';

import 'voice_fake_session.dart';

class FinalResultSession extends FakeVoiceSession {
  @override
  Future<void> stop() async {
    text?.call('Final sentence');
    await super.stop();
  }
}

void main() {
  testWidgets('cloud capture requires consent and fits narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var tokenRequests = 0;
    final service = GeminiSpeechService(
      tokenProvider: () async {
        tokenRequests++;
        return 'never';
      },
    );
    final controller = VoiceCaptureController(session: service);
    await tester.pumpWidget(
      MaterialApp(home: VoiceCaptureDialog(controller: controller)),
    );
    await tester.pump();
    expect(controller.phase, VoiceCapturePhase.ready);
    expect(tokenRequests, 0);
    expect(find.text('Gemini Live'), findsOneWidget);
    expect(find.text('Tester voice access code'), findsNothing);
    expect(find.byType(CheckboxListTile), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'native missing-pack controls fit a narrow screen and report installed packs',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const channel = MethodChannel('later/speech');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'start') {
              throw PlatformException(
                code: 'language',
                message: 'Language pack unavailable',
              );
            }
            if (call.method == 'languageSupport') {
              return {
                'status': 'checked',
                'installed': ['en-US'],
                'supported': ['en-IN'],
                'pending': [],
              };
            }
            return null;
          });
      final controller = VoiceCaptureController(
        session: NativeSpeechService(
          channel: channel,
          permission: () async => true,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(home: VoiceCaptureDialog(controller: controller)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Check language packs'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Installed: en-US'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    },
  );

  Future<void> open(
    WidgetTester tester,
    FakeVoiceSession session,
    List<String> applied,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showVoiceCaptureDialog(
                context,
                onApply: applied.add,
                sessionFactory: () => session,
              ),
              child: const Text('Open voice'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open voice'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets(
    'Done stops capture and returns draft without an extra review step',
    (tester) async {
      final session = FakeVoiceSession();
      final applied = <String>[];
      await open(tester, session, applied);
      session.text!('spent maybe 200 for books');
      session.level!(0.3);
      await tester.pump();
      expect(
        find.text('Listening — microphone sound detected'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Done'))
            .onPressed,
        isNotNull,
      );
      expect(applied, isEmpty);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(applied, ['spent maybe 200 for books']);
      expect(find.text('Use text'), findsNothing);
      expect(session.disposals, 1);
    },
  );

  testWidgets('Done forwards the final result received while stopping', (
    tester,
  ) async {
    final session = FinalResultSession();
    final applied = <String>[];
    await open(tester, session, applied);
    session.text!('Partial');
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(applied, ['Final sentence']);
    expect(session.disposals, 1);
    expect(find.text('Use text'), findsNothing);
  });

  testWidgets('live revisions and pause resume retain words without applying', (
    tester,
  ) async {
    final session = FakeVoiceSession();
    final applied = <String>[];
    await open(tester, session, applied);
    session.text!('Call');
    await tester.pump();
    expect(find.text('Call'), findsOneWidget);
    session.text!('Call Maya');
    await tester.pump();
    expect(find.text('Call Maya'), findsOneWidget);
    await tester.tap(find.byTooltip('Pause microphone'));
    await tester.pump();
    await tester.tap(find.byTooltip('Resume microphone'));
    await tester.pump();
    session.text!('tomorrow');
    await tester.pump();
    expect(find.text('Call Maya tomorrow'), findsOneWidget);
    expect(applied, isEmpty);
    await tester.tap(find.byTooltip('Cancel'));
    await tester.pumpAndSettle();
    expect(applied, isEmpty);
    expect(session.disposals, 1);
  });

  testWidgets('compact viewport and keyboard keep manual fallback scrollable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    final session = FakeVoiceSession()..denyPermission = true;
    await open(tester, session, []);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Manual draft');
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(session.disposals, 1);
  });

  testWidgets('denial is clear and manual input remains usable', (
    tester,
  ) async {
    final session = FakeVoiceSession()..denyPermission = true;
    final applied = <String>[];
    await open(tester, session, applied);
    expect(find.textContaining('Microphone access was denied'), findsOneWidget);
    expect(find.byTooltip('Retry voice capture'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Call Maya');
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(applied, ['Call Maya']);
    expect(session.disposals, 1);
  });

  testWidgets('download cancel and dismissal dispose without applying', (
    tester,
  ) async {
    final session = FakeVoiceSession()..download = true;
    final applied = <String>[];
    await open(tester, session, applied);
    expect(find.text('Downloading English voice model…'), findsOneWidget);
    expect(find.textContaining('10%'), findsOneWidget);
    await tester.tap(find.byTooltip('Cancel preparation'));
    await tester.pumpAndSettle();
    expect(
      find.text('No speech captured. Try again or type below.'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Cancel'));
    await tester.pumpAndSettle();
    expect(applied, isEmpty);
    expect(session.disposals, 1);
  });

  testWidgets('back dismissal while listening releases session', (
    tester,
  ) async {
    final session = FakeVoiceSession();
    final applied = <String>[];
    await open(tester, session, applied);
    session.text!('do not apply');
    await tester.pump();
    final context = tester.element(find.byType(VoiceCaptureDialog));
    Navigator.of(context).pop();
    await tester.pumpAndSettle();
    expect(session.disposals, 1);
    expect(applied, isEmpty);
  });

  testWidgets('backgrounding stops listening and permits manual review', (
    tester,
  ) async {
    final session = FakeVoiceSession();
    final applied = <String>[];
    await open(tester, session, applied);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(session.stops, 1);
    expect(
      find.text('No speech captured. Try again or type below.'),
      findsOneWidget,
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.tap(find.byTooltip('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  });
}
