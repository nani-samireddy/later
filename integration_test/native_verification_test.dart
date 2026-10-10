import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:later/main.dart' as app;
import 'package:later/core/database/app_database.dart';
import 'package:later/core/attachments/attachment_repository.dart';
import 'package:later/core/attachments/stored_attachment.dart';
import 'package:later/core/notifications/notification_service.dart';
import 'package:later/core/notifications/reminder_coordinator.dart';
import 'package:later/core/notifications/reminder_scheduler.dart';
import 'package:later/features/money/data/money_repository.dart';
import 'package:later/features/money/domain/money_totals.dart';
import 'package:later/features/money/presentation/money_detail_screen.dart';
import 'package:later/features/things/data/things_repository.dart';
import 'package:later/features/things/presentation/thing_detail_screen.dart';

import 'fixtures/pdf_fixture.dart';

// ADB automation taps the posted notification at QA_NOTIFICATION_READY, then
// returns from the external PDF viewer at QA_PDF_READY. No native APIs are mocked.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // The inspector below uses its own SQLite executor, alongside the app's DB.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  testWidgets('Money UI, delivered reminder navigation, private PDF opening', (
    tester,
  ) async {
    await app.main();
    await tester.pumpAndSettle();
    final db = AppDatabase();
    final name = 'Native QA ${DateTime.now().millisecondsSinceEpoch}';
    int? moneyId;
    int? thingId;
    File? source;
    AppLifecycleListener? lifecycle;
    try {
      final before = summarizeMoney(await db.allMoney());
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Money').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('I spent money'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Someone owes me').last);
      await tester.pumpAndSettle();
      await fill(tester, 'Title', name);
      await fill(tester, 'Amount', '-1');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Create entry'));
      await tester.tap(find.text('Create entry'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Enter an amount greater than zero, with up to two decimal places.',
        ),
        findsOneWidget,
      );
      expect((await db.allMoney()).where((r) => r.person == name), isEmpty);
      await fill(tester, 'Amount', '45.50');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Create entry'));
      await tester.tap(find.text('Create entry'));
      await waitFor(tester, () => find.text('Create entry').evaluate().isEmpty);
      await tester.pumpAndSettle();
      var record = (await db.allMoney()).singleWhere((r) => r.person == name);
      moneyId = record.id;
      expect(record.amount, 45.50);
      final startingTotal = before[record.currency]?.owedToYou ?? 0;
      expect(
        summarizeMoney(await db.allMoney())[record.currency]!.owedToYou,
        closeTo(startingTotal + 45.50, 0.001),
      );
      await tester.tap(find.text('Money').last);
      await waitFor(tester, () => find.text(name).evaluate().isNotEmpty);
      await tester.pumpAndSettle();
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
      expect(find.byType(MoneyDetailScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
      await fill(tester, 'Amount', '60.25');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await waitFor(tester, () => find.text('Save').evaluate().isEmpty);
      await tester.pumpAndSettle();
      // Both the original amount and remaining balance display this value
      // until the first repayment. Persistence is asserted separately below.
      expect(find.text('${record.currency} 60.25'), findsWidgets);
      record = await MoneyRepository(db).find(moneyId);
      expect(record.amount, 60.25);
      await tester.tap(find.text('Mark as settled'));
      await waitFor(
        tester,
        () => find.text('Mark as open').evaluate().isNotEmpty,
      );
      expect((await MoneyRepository(db).find(moneyId)).settled, isTrue);
      expect(
        summarizeMoney(await db.allMoney())[record.currency]!.owedToYou,
        closeTo(startingTotal, 0.001),
      );
      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await waitFor(
        tester,
        () => find.byType(MoneyDetailScreen).evaluate().isEmpty,
      );
      await tester.pumpAndSettle();
      expect((await db.allMoney()).any((r) => r.id == moneyId), isFalse);
      moneyId = null;

      thingId = await db.addThing(
        ThingsCompanion.insert(
          title: name,
          category: 'Documents',
          iconCodePoint: Icons.description_outlined.codePoint,
        ),
      );
      source = File('${(await getTemporaryDirectory()).path}/native-qa.pdf');
      await source.writeAsBytes(base64Decode(pdfFixtureBase64));
      final files = AttachmentRepository(db);
      final pdf = await files.add(
        AttachmentOwner.thing,
        thingId,
        PlatformFile(
          name: 'native-qa.pdf',
          size: await source.length(),
          path: source.path,
        ),
      );
      await source.delete();
      expect(await File(pdf.path).exists(), isTrue);
      // Fresh app UI loads the externally inserted record and attachment.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Things').last);
      await waitFor(tester, () => find.text(name).evaluate().isNotEmpty);
      await tester.pumpAndSettle();
      expect(find.byType(ThingDetailScreen), findsNothing);
      await db.updateThing(
        thingId,
        ThingsCompanion(
          reminderDate: Value(DateTime.now().add(const Duration(seconds: 5))),
        ),
      );
      await ReminderCoordinator(db).syncThing(thingId);
      final notificationId = reminderId('thing', thingId);
      final deadline = DateTime.now().add(const Duration(seconds: 60));
      var delivered = false;
      while (!delivered && DateTime.now().isBefore(deadline)) {
        final active = await NotificationService.plugin
            .getActiveNotifications();
        delivered = active.any((n) => n.id == notificationId && n.body == name);
        if (!delivered) await tester.pump(const Duration(milliseconds: 300));
      }
      expect(
        delivered,
        isTrue,
        reason: 'Android did not deliver the scheduled notification',
      );
      // ignore: avoid_print
      print('QA_NOTIFICATION_READY $name');
      await waitFor(
        tester,
        () => find.byType(ThingDetailScreen).evaluate().isNotEmpty,
      );
      await tester.pumpAndSettle();
      expect(find.text(name), findsOneWidget);
      await waitFor(
        tester,
        () => find.text('native-qa.pdf').evaluate().isNotEmpty,
      );
      final resumed = Completer<void>();
      lifecycle = AppLifecycleListener(
        onResume: () {
          if (!resumed.isCompleted) resumed.complete();
        },
      );
      await tester.tap(find.text('native-qa.pdf'));
      // ignore: avoid_print
      print('QA_PDF_READY');
      await resumed.future.timeout(const Duration(seconds: 90));
      lifecycle.dispose();
      lifecycle = null;
      await tester.pumpAndSettle();
      expect(find.text('native-qa.pdf'), findsOneWidget);
      // Missing-file feedback is verified after the successfully opened copy is removed.
      await File(pdf.path).delete();
      await tester.tap(find.text('native-qa.pdf'));
      await tester.pumpAndSettle();
      expect(
        find.text('This file is missing. Remove it and attach a new copy.'),
        findsOneWidget,
      );
      await files.remove(AttachmentOwner.thing, pdf);
      expect(await db.attachmentsFor(thingId), isEmpty);
      await ThingsRepository(db).delete(thingId);
      expect(await db.thingById(thingId), isNull);
      expect(
        (await NotificationService.plugin.getActiveNotifications()).any(
          (n) => n.id == notificationId,
        ),
        isFalse,
      );
      thingId = null;
    } finally {
      lifecycle?.dispose();
      if (moneyId != null) await MoneyRepository(db).delete(moneyId);
      if (thingId != null) await ThingsRepository(db).delete(thingId);
      if (source != null && await source.exists()) await source.delete();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await db.close();
    }
  }, timeout: const Timeout(Duration(minutes: 5)));
}

Future<void> fill(WidgetTester tester, String label, String text) async {
  final field = find.byWidgetPredicate(
    (w) => w is TextField && w.decoration?.labelText == label,
  );
  await tester.ensureVisible(field);
  // Refill the form without racing Android's real IME client reconnection.
  // The same controller is read by the actual Create/Save button handlers.
  tester.widget<TextField>(field).controller!.text = text;
  await tester.pump();
  expect(tester.widget<TextField>(field).controller!.text, text);
}

Future<void> waitFor(WidgetTester tester, bool Function() ready) async {
  final deadline = DateTime.now().add(const Duration(seconds: 90));
  while (!ready() && DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(
    ready(),
    isTrue,
    reason: 'Native verification UI step did not complete',
  );
}
