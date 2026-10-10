import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:later/main.dart' as app;
import 'package:later/core/database/app_database.dart';
import 'package:later/core/attachments/attachment_repository.dart';
import 'package:later/core/attachments/stored_attachment.dart';
import 'package:later/core/notifications/notification_service.dart';
import 'package:later/core/notifications/reminder_coordinator.dart';
import 'package:later/core/notifications/reminder_scheduler.dart';
import 'package:later/features/things/presentation/thing_detail_screen.dart';
import 'package:later/features/things/data/things_repository.dart';
import 'package:later/features/money/data/money_repository.dart';
import 'package:later/features/money/domain/money_totals.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // The inspector uses a separate SQLite executor alongside the app-owned DB.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  testWidgets(
    'Milestone: form creation, edits, attachments, reminders, restart, settlement and deletion',
    (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      final db = AppDatabase();
      final title = 'Milestone QA ${DateTime.now().millisecondsSinceEpoch}';
      int? thingId;
      int? moneyId;
      File? source;
      try {
        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).first, title);
        await tester.enterText(
          find.byType(TextField).at(1),
          'Optional details survive restart',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Create entry'));
        await waitUntil(
          tester,
          () => find.text('Create entry').evaluate().isEmpty,
        );
        await tester.pumpAndSettle();
        final thing = (await db.allThings()).singleWhere(
          (thing) => thing.title == title,
        );
        expect(thing.description, 'Optional details survive restart');
        thingId = thing.id;
        await tester.tap(find.text('Things').last);
        await tester.pumpAndSettle();
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
        expect(find.byType(ThingDetailScreen), findsOneWidget);
        await tester.tap(find.byTooltip('Edit'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextFormField).first,
          '$title edited',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save'));
        await waitUntil(tester, () => find.text('Save').evaluate().isEmpty);
        await tester.pumpAndSettle();
        expect(find.text('$title edited'), findsOneWidget);
        expect((await db.thingById(thingId))!.title, '$title edited');

        // Copy an image into app storage; remove its source before reopening the UI.
        source = File(
          '${(await getTemporaryDirectory()).path}/milestone-qa.png',
        );
        await source.writeAsBytes(
          base64Decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
          ),
        );
        final files = AttachmentRepository(db);
        final saved = await files.add(
          AttachmentOwner.thing,
          thingId,
          PlatformFile(
            name: 'milestone-qa.png',
            size: await source.length(),
            path: source.path,
          ),
        );
        await source.delete();
        expect(await File(saved.path).exists(), isTrue);
        await tester.pageBack();
        await tester.pumpAndSettle();
        await tester.tap(find.text('$title edited'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('milestone-qa.png'));
        await tester.pumpAndSettle();
        expect(find.byType(Image), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();

        // Schedule a real OS reminder and verify its registered ID and payload.
        final date = DateTime.now().add(const Duration(hours: 1));
        await db.updateThing(
          thingId,
          ThingsCompanion(reminderDate: Value(date)),
        );
        await ReminderCoordinator(db).syncThing(thingId);
        var pending = await NotificationService.plugin
            .pendingNotificationRequests();
        expect(
          pending.any(
            (n) =>
                n.id == reminderId('thing', thingId!) &&
                n.payload == 'thing:$thingId',
          ),
          isTrue,
        );

        // Money reminder settlement and cancellation use the native plugin too.
        moneyId = await db.addMoney(
          MoneyEntriesCompanion.insert(
            person: title,
            amount: 45.50,
            currency: 'USD',
            owedToMe: true,
            dueDate: Value(date),
          ),
        );
        final money = MoneyRepository(db);
        await ReminderCoordinator(db).syncMoney(moneyId);
        await money.setSettled(moneyId, true);
        pending = await NotificationService.plugin
            .pendingNotificationRequests();
        expect(
          pending.any((n) => n.id == reminderId('money', moneyId!)),
          isFalse,
        );
        expect(summarizeMoney(await db.allMoney())['USD']!.owedToYou, 0);

        // Restart the widget tree with a fresh app-owned database connection.
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        await app.main();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Things').last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('$title edited'));
        await tester.pumpAndSettle();
        expect(find.text('milestone-qa.png'), findsOneWidget);
        await tester.tap(find.byTooltip('Delete'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await waitUntil(
          tester,
          () => find.byType(ThingDetailScreen).evaluate().isEmpty,
        );
        await tester.pumpAndSettle();
        expect(find.text('$title edited'), findsNothing);
        expect(await db.thingById(thingId), isNull);
        expect(await File(saved.path).exists(), isFalse);
        pending = await NotificationService.plugin
            .pendingNotificationRequests();
        expect(
          pending.any((n) => n.id == reminderId('thing', thingId!)),
          isFalse,
        );
        thingId = null;
        await money.delete(moneyId);
        moneyId = null;
      } finally {
        if (thingId != null) {
          await ThingsRepository(db).delete(thingId);
        }
        if (moneyId != null) await MoneyRepository(db).delete(moneyId);
        if (source != null && await source.exists()) await source.delete();
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        await db.close();
      }
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}

Future<void> waitUntil(WidgetTester tester, bool Function() ready) async {
  final deadline = DateTime.now().add(const Duration(seconds: 60));
  while (!ready() && DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(ready(), isTrue, reason: 'Async UI operation did not complete');
}
