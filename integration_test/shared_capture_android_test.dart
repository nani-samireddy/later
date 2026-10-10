import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:later/main.dart' as app;
import 'package:later/core/database/app_database.dart';
import 'package:later/features/money/data/money_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'real Android share reviews OCR and saves only after confirmation',
    (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      final db = AppDatabase();
      final title = 'Shared QA ${DateTime.now().millisecondsSinceEpoch}';
      int? id;
      try {
        final before = (await db.allMoney()).length;
        // The native guard must reject a missing/unreadable URI without killing
        // the Activity or blocking the next valid screenshot.
        // ignore: avoid_print
        print('QA_UNREADABLE_SHARE');
        await tester.pump(const Duration(seconds: 3));
        expect(find.text('Add'), findsWidgets);
        // Host sends a real MediaStore content URI, with a read grant.
        // ignore: avoid_print
        print('QA_SHARED_SCREENSHOT');
        for (var attempt = 0; attempt < 240; attempt++) {
          await tester.pump(const Duration(milliseconds: 250));
          if (find
              .text('I have checked the payment type')
              .evaluate()
              .isNotEmpty) {
            break;
          }
        }
        expect(find.text('I have checked the payment type'), findsOneWidget);
        final fields = tester.widgetList<TextField>(find.byType(TextField));
        expect(
          fields
              .firstWhere((f) => f.decoration?.labelText == 'Title')
              .controller!
              .text,
          'Asha Rao',
        );
        expect(
          fields
              .firstWhere((f) => f.decoration?.labelText == 'Amount')
              .controller!
              .text,
          '1250.50',
        );
        expect(
          tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
          isFalse,
        );
        expect((await db.allMoney()).length, before);
        final titleField = find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == 'Title',
        );
        await tester.enterText(titleField, title);
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byType(CheckboxListTile));
        await tester.tap(find.byType(CheckboxListTile));
        await tester.ensureVisible(find.text('Create entry'));
        await tester.tap(find.text('Create entry'));
        for (var attempt = 0; attempt < 120; attempt++) {
          await tester.pump(const Duration(milliseconds: 250));
          if (find.text('Create entry').evaluate().isEmpty) break;
        }
        await tester.pumpAndSettle();
        final saved = (await db.allMoney()).singleWhere(
          (r) => r.person == title,
        );
        id = saved.id;
        expect(saved.kind, 'spending');
        expect(saved.amount, 1250.50);
        final attachments = await db.moneyAttachmentsFor(id);
        expect(attachments, hasLength(1));
        final privateImage = File(attachments.single.path);
        expect(await privateImage.exists(), isTrue);
        await MoneyRepository(db).delete(id);
        id = null;
        expect(await privateImage.exists(), isFalse);
        expect((await db.allMoney()).length, before);
      } finally {
        if (id != null) await MoneyRepository(db).delete(id);
        await db.close();
      }
    },
  );
}
