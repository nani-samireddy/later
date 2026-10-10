import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:later/main.dart' as app;
import 'package:later/core/database/app_database.dart';
import 'package:later/features/backup/backup_screen.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  testWidgets(
    'Android backup export and import preview preserve data when canceled',
    (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      final db = AppDatabase();
      var restored = false;
      try {
        final things = await db.allThings();
        final money = await db.allMoney();
        await tester.pumpWidget(
          MaterialApp(
            home: BackupScreen(database: db, onChanged: () => restored = true),
          ),
        );
        await tester.pumpAndSettle();
        // Host drives the real DocumentsUI picker using a unique QA filename.
        // ignore: avoid_print
        print('QA_BACKUP_EXPORT');
        await tester.tap(find.text('Export backup'));
        await waitFor(
          tester,
          () => find.textContaining('Backup saved.').evaluate().isNotEmpty,
        );
        // ignore: avoid_print
        print('QA_BACKUP_IMPORT');
        await tester.tap(find.text('Import backup'));
        await waitFor(
          tester,
          () => find.text('Replace all local data?').evaluate().isNotEmpty,
        );
        expect(find.text('Things: ${things.length}'), findsOneWidget);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(restored, isFalse);
        expect(await db.allThings(), things);
        expect(await db.allMoney(), money);
      } finally {
        await tester.pumpWidget(const SizedBox());
        await db.close();
      }
    },
  );
}

Future<void> waitFor(WidgetTester tester, bool Function() condition) async {
  for (var attempt = 0; attempt < 240; attempt++) {
    await tester.pump(const Duration(milliseconds: 250));
    if (condition()) return;
  }
  fail('Native backup picker did not return within 60 seconds');
}
