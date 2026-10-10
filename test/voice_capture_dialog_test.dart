import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/features/capture/presentation/voice_capture_dialog.dart';

import 'voice_fake_session.dart';

void main() {
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
    await tester.pumpAndSettle();
  }

  testWidgets(
    'no auto apply; stop, edit, explicitly apply raw Thing/Money draft',
    (tester) async {
      final session = FakeVoiceSession();
      final applied = <String>[];
      await open(tester, session, applied);
      await tester.tap(find.text('Start listening'));
      await tester.pump();
      session.text!('spent maybe 200 for books');
      session.level!(0.3);
      await tester.pump();
      expect(
        find.text('Listening — microphone sound detected'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Use text'))
            .onPressed,
        isNull,
      );
      expect(applied, isEmpty);
      await tester.tap(find.text('Stop and review'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Spent 200 for books');
      await tester.pump();
      await tester.tap(find.text('Use text'));
      await tester.pumpAndSettle();
      expect(applied, ['Spent 200 for books']);
      expect(session.disposals, 1);
    },
  );

  testWidgets('denial is clear and manual input remains usable', (
    tester,
  ) async {
    final session = FakeVoiceSession()..denyPermission = true;
    final applied = <String>[];
    await open(tester, session, applied);
    await tester.tap(find.text('Start listening'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Microphone access was denied'), findsOneWidget);
    expect(find.text('Retry voice capture'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Call Maya');
    await tester.pump();
    await tester.tap(find.text('Use text'));
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
    await tester.tap(find.text('Start listening'));
    await tester.pump();
    expect(find.text('Downloading English voice model…'), findsOneWidget);
    expect(find.textContaining('10%'), findsOneWidget);
    await tester.tap(find.text('Cancel preparation'));
    await tester.pumpAndSettle();
    expect(
      find.text('No speech captured. Try again or type below.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
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
    await tester.tap(find.text('Start listening'));
    await tester.pump();
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
    await tester.tap(find.text('Start listening'));
    await tester.pump();
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
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });
}
