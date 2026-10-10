import 'dart:io';

import 'package:later/core/attachments/attachment_store.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/database/app_database.dart';
import 'package:later/core/notifications/reminder_coordinator.dart';
import 'package:later/core/notifications/reminder_scheduler.dart';
import 'package:later/features/money/data/money_repository.dart';
import 'package:later/features/things/data/things_repository.dart';

import 'support/fake_reminders.dart';

void main() {
  test('Reminders preserve midnight, separate record IDs and cancel stale schedules', () async {
    final db = AppDatabase.withExecutor(NativeDatabase.memory());
    final directory = await Directory.systemTemp.createTemp('later-reminders-');
    addTearDown(() => directory.delete(recursive: true));
    final store = AttachmentStore(directory: () async => directory);
    final scheduler = FakeReminders();
    final reminders = ReminderCoordinator(
      db,
      scheduler: scheduler,
      now: () => DateTime(2026),
    );
    try {
      final midnight = DateTime(2090, 2, 1, 0, 15);
      final thing = await db.addThing(
        ThingsCompanion.insert(
          title: 'Passport',
          category: 'Document',
          iconCodePoint: Icons.bookmark.codePoint,
          reminderDate: Value(midnight),
        ),
      );
      final money = await db.addMoney(
        MoneyEntriesCompanion.insert(
          person: 'Ravi',
          amount: 50,
          currency: 'INR',
          owedToMe: true,
          dueDate: Value(midnight),
        ),
      );
      await reminders.syncAll();
      expect(scheduler.pending.length, 2);
      expect(scheduler.pending[reminderId('thing', thing)]!.date, midnight);
      expect(
        scheduler.pending[reminderId('money', money)]!.payload,
        'money:$money',
      );
      final repo = MoneyRepository(db, scheduler: scheduler, store: store);
      final entry = await repo.find(money);
      await repo.edit(
        entry,
        person: 'Ravi',
        amount: 60,
        reason: '',
        owedToMe: true,
        moneyKind: 'owedToMe',
        dueDate: DateTime(2090, 2, 1),
        reminderTime: const TimeOfDay(hour: 14, minute: 35),
      );
      expect(
        scheduler.pending[reminderId('money', money)]!.date,
        DateTime(2090, 2, 1, 14, 35),
      );
      await repo.setSettled(money, true);
      expect(
        scheduler.pending.containsKey(reminderId('money', money)),
        isFalse,
      );
      await repo.setSettled(money, false);
      expect(scheduler.pending.containsKey(reminderId('money', money)), isTrue);
      await repo.delete(money);
      expect(
        scheduler.pending.containsKey(reminderId('money', money)),
        isFalse,
      );
      await ThingsRepository(
        db,
        scheduler: scheduler,
        store: store,
      ).delete(thing);
      expect(scheduler.pending, isEmpty);
    } finally {
      await db.close();
    }
  });
  test(
    'Past dates and removed reminders cancel rather than reschedule',
    () async {
      final db = AppDatabase.withExecutor(NativeDatabase.memory());
      final scheduler = FakeReminders();
      final coordinator = ReminderCoordinator(
        db,
        scheduler: scheduler,
        now: () => DateTime(2026),
      );
      try {
        final id = await db.addThing(
          ThingsCompanion.insert(
            title: 'Item',
            category: 'General',
            iconCodePoint: Icons.bookmark.codePoint,
            reminderDate: Value(DateTime(2027)),
          ),
        );
        await coordinator.syncThing(id);
        await db.updateThing(
          id,
          ThingsCompanion(reminderDate: Value(DateTime(2025))),
        );
        await coordinator.syncThing(id);
        expect(scheduler.pending, isEmpty);
        await db.updateThing(
          id,
          const ThingsCompanion(reminderDate: Value(null)),
        );
        await coordinator.syncThing(id);
        expect(scheduler.pending, isEmpty);
      } finally {
        await db.close();
      }
    },
  );
}
