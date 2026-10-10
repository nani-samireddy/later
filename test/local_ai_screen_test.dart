import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/ai/local_ai_service.dart';
import 'package:later/features/ai/presentation/local_ai_screen.dart';

import 'local_ai_service_test.dart' show FakeRuntime;

void main() {
  testWidgets(
    'management shows size, missing model, progress, cancel and retry',
    (tester) async {
      final runtime = FakeRuntime()..installGate = Completer<void>();
      final service = LocalAiService(runtime: runtime);
      await tester.pumpWidget(
        MaterialApp(home: LocalAiScreen(service: service)),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('614 MB'), findsOneWidget);
      expect(
        find.textContaining('No local AI model installed'),
        findsOneWidget,
      );
      await tester.tap(find.text('Install model'));
      await tester.pump();
      expect(find.text('40% of 614 MB'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      expect(service.status, LocalAiStatus.cancelled);
      runtime.installGate!.complete();
      await tester.pumpAndSettle();
      runtime.installGate = null;
      await tester.tap(find.text('Retry installation'));
      await tester.pumpAndSettle();
      expect(service.status, LocalAiStatus.ready);
      await tester.ensureVisible(find.text('Remove model'));
      await tester.tap(find.text('Remove model'));
      await tester.pumpAndSettle();
      expect(service.status, LocalAiStatus.missing);
      await tester.pumpWidget(const SizedBox());
      service.dispose();
    },
  );
}
