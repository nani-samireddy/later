import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/attachments/attachment_store.dart';
import 'package:later/core/database/app_database.dart';
import 'package:later/features/settings/data/settings_preferences.dart';
import 'package:later/features/settings/data/clear_data_service.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.withExecutor(NativeDatabase.memory()));
  tearDown(() => db.close());
  test('reminder default persists across service instances and validates stored values', () async {
    expect(
      await SettingsPreferences(db).reminderTime(),
      const TimeOfDay(hour: 9, minute: 0),
    );
    await SettingsPreferences(db)
        .saveReminderTime(const TimeOfDay(hour: 23, minute: 45));
    expect(
      await SettingsPreferences(db).reminderTime(),
      const TimeOfDay(hour: 23, minute: 45),
    );
    for (final invalid in ['-1', '1440', 'oops']) {
      await db.saveSetting(SettingsPreferences.reminderTimeKey, invalid);
      expect(
        await SettingsPreferences(db).reminderTime(),
        SettingsPreferences.defaultReminderTime,
      );
    }
  });
  test('clear removes every registered table, owned files and notifications only', () async {
    final temp = await Directory.systemTemp.createTemp('settings-clear-');
    addTearDown(() => temp.delete(recursive: true));
    final root = Directory('${temp.path}/attachments');
    await root.create();
    await File('${root.path}/receipt.pdf').writeAsString('receipt');
    final backup = File('${temp.path}/export.json');
    await backup.writeAsString('backup');
    final id = await db.addThing(
      ThingsCompanion.insert(
        title: 'Archived',
        category: 'Other',
        iconCodePoint: 1,
        status: const Value('archived'),
      ),
    );
    await db.addAttachment(
      AttachmentsCompanion.insert(thingId: id, name: 'receipt'),
    );
    final moneyId = await db.addMoney(
      MoneyEntriesCompanion.insert(
        person: 'Sam',
        amount: 50,
        currency: 'INR',
        owedToMe: true,
      ),
    );
    await db.customStatement(
      'INSERT INTO money_payments (money_id, amount, paid_at) VALUES (?, ?, ?)',
      [moneyId, 10, 1700000000],
    );
    await db.saveSetting('currency', 'USD');
    var cancelled = false;
    await ClearDataService(
      db,
      attachments: AttachmentStore(directory: () async => root),
      cancelNotifications: () async {
        cancelled = true;
      },
    ).clear();
    expect(cancelled, isTrue);
    for (final table in db.allTables) {
      expect(await db.select(table).get(), isEmpty);
    }
    expect(await root.exists(), isFalse);
    expect(await backup.exists(), isTrue);
  });
  test(
    'file cleanup failure reports records already cleared and permits retry',
    () async {
      await db.saveSetting('currency', 'USD');
      final service = ClearDataService(
        db,
        attachments: AttachmentStore(
          directory: () async => throw const FileSystemException('Unavailable'),
        ),
        cancelNotifications: () async {},
      );
      await expectLater(
        service.clear(),
        throwsA(isA<ClearDataFileCleanupException>()),
      );
      expect(await db.setting('currency'), isNull);
    },
  );
  test('notification cleanup failure preserves records and files', () async {
    await db.saveSetting('currency', 'USD');
    final service = ClearDataService(
      db,
      cancelNotifications: () async => throw StateError('Unavailable'),
    );
    await expectLater(service.clear(), throwsStateError);
    expect(await db.setting('currency'), 'USD');
  });
}
