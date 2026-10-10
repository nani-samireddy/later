import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:later/main.dart' as app;
import 'package:later/core/database/app_database.dart';
import 'package:later/features/camera/presentation/camera_capture_dialog.dart';
import 'package:later/features/things/data/things_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  testWidgets(
    'Android camera review saves a durable task and cancellation saves nothing',
    (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      final database = AppDatabase();
      final title = 'Camera QA ${DateTime.now().millisecondsSinceEpoch}';
      int? id;
      try {
        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Take photo'));
        await tester.pump(const Duration(milliseconds: 500));
        // The host driver operates the real Android camera activity.
        // ignore: avoid_print
        print('QA_CAMERA_CAPTURE');
        await waitFor(
          tester,
          () => find.text('Add another photo').evaluate().isNotEmpty,
        );
        final dialog = find.byType(CameraCaptureDialog);
        expect(
          find.descendant(of: dialog, matching: find.byType(Image)),
          findsOneWidget,
        );
        await tester.enterText(
          find.descendant(of: dialog, matching: find.byType(TextField)).first,
          title,
        );
        await tester.enterText(
          find.descendant(of: dialog, matching: find.byType(TextField)).at(1),
          'Real system camera photo',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save task'));
        await waitFor(tester, () => dialog.evaluate().isEmpty);
        await tester.pumpAndSettle();
        final entry = (await database.allThings()).singleWhere(
          (item) => item.title == title,
        );
        id = entry.id;
        final attachments = await database.attachmentsFor(id);
        expect(attachments, hasLength(1));
        final photo = File(attachments.single.path);
        expect(await photo.exists(), isTrue);
        expect(await photo.length(), greaterThan(100));
        final reopened = AppDatabase();
        expect(
          (await reopened.thingById(id))!.description,
          'Real system camera photo',
        );
        await reopened.close();

        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Take photo'));
        await tester.pump(const Duration(milliseconds: 500));
        // ignore: avoid_print
        print('QA_CAMERA_CANCEL');
        await waitFor(tester, () {
          final buttons = find.descendant(
            of: find.byType(CameraCaptureDialog),
            matching: find.byType(TextButton),
          );
          return buttons.evaluate().any(
            (element) => (element.widget as TextButton).onPressed != null,
          );
        });
        await tester.tap(
          find.descendant(
            of: find.byType(CameraCaptureDialog),
            matching: find.text('Cancel'),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          (await database.allThings()).where((item) => item.title == title),
          hasLength(1),
        );
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        await ThingsRepository(database).delete(id);
        id = null;
        expect(await photo.exists(), isFalse);
      } finally {
        if (id != null) await ThingsRepository(database).delete(id);
        await database.close();
      }
    },
  );
}

Future<void> waitFor(WidgetTester tester, bool Function() condition) async {
  for (var attempt = 0; attempt < 240; attempt++) {
    await tester.pump(const Duration(milliseconds: 250));
    if (condition()) return;
  }
  fail('Camera did not return to review within 60 seconds');
}
