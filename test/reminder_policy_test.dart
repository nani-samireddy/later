import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/database/app_database.dart';
import 'package:later/core/notifications/reminder_coordinator.dart';
import 'package:later/core/notifications/reminder_scheduler.dart';
import 'package:later/core/reminders/recurrence.dart';

import 'support/fake_reminders.dart';

void main() {
  late AppDatabase db;
  late FakeReminders scheduler;
  late ReminderCoordinator coordinator;
  final clock = DateTime(2026, 2, 1);
  setUp(() {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    scheduler = FakeReminders();
    coordinator = ReminderCoordinator(
      db,
      scheduler: scheduler,
      now: () => clock,
    );
  });
  tearDown(() => db.close());
  Future<int> add() => db.addThing(
    ThingsCompanion.insert(
      title: 'Repeat',
      category: 'General',
      iconCodePoint: 0,
      reminderDate: Value(DateTime(2026, 1, 31, 9)),
    ),
  );
  test(
    'Snooze persists through coordinator recreation and edit resets it',
    () async {
      final id = await add();
      await coordinator.configure('thing', id, ReminderRecurrence.monthly);
      expect(
        scheduler.pending[reminderId('thing', id)]!.date,
        DateTime(2026, 2, 28, 9),
      );
      await coordinator.snooze('thing', id, DateTime(2026, 2, 2, 11));
      final restarted = ReminderCoordinator(
        db,
        scheduler: scheduler,
        now: () => clock,
      );
      await restarted.syncAll();
      expect(
        scheduler.pending[reminderId('thing', id)]!.date,
        DateTime(2026, 2, 2, 11),
      );
      await db.updateThing(
        id,
        ThingsCompanion(reminderDate: Value(DateTime(2026, 2, 15, 10))),
      );
      await restarted.syncThing(id);
      expect(
        scheduler.pending[reminderId('thing', id)]!.date,
        DateTime(2026, 2, 15, 10),
      );
      final policy = await restarted.preferences.read('thing', id);
      expect(policy.snoozedUntil, isNull);
      expect(policy.recurrence, ReminderRecurrence.monthly);
    },
  );
  test(
    'Complete/archive cancel but retain repeat; removal and deletion clear it',
    () async {
      final id = await add();
      await coordinator.configure('thing', id, ReminderRecurrence.daily);
      for (final status in ['completed', 'archived']) {
        await db.updateThing(id, ThingsCompanion(status: Value(status)));
        await coordinator.syncThing(id);
        expect(scheduler.pending, isEmpty);
        expect(
          (await coordinator.preferences.read('thing', id)).recurrence,
          ReminderRecurrence.daily,
        );
        await db.updateThing(
          id,
          const ThingsCompanion(status: Value('active')),
        );
        await coordinator.syncThing(id);
        expect(scheduler.pending, isNotEmpty);
      }
      await db.updateThing(
        id,
        const ThingsCompanion(reminderDate: Value(null)),
      );
      await coordinator.syncThing(id);
      expect(
        (await coordinator.preferences.read('thing', id)).recurrence,
        ReminderRecurrence.none,
      );
      expect(scheduler.pending, isEmpty);
      await db.deleteThing(id);
      await coordinator.syncThing(id);
      expect(scheduler.pending, isEmpty);
    },
  );
  test('Settled debts retain policy and reopen future repeats', () async {
    final id = await db.addMoney(
      MoneyEntriesCompanion.insert(
        person: 'Ravi',
        amount: 100,
        currency: 'INR',
        owedToMe: true,
        paidAmount: const Value(40),
        dueDate: Value(DateTime(2026, 1, 31, 9)),
      ),
    );
    await coordinator.configure('money', id, ReminderRecurrence.weekly);
    expect(scheduler.pending, isNotEmpty);
    await db.updateMoney(id, const MoneyEntriesCompanion(settled: Value(true)));
    await coordinator.syncMoney(id);
    expect(scheduler.pending, isEmpty);
    expect(
      (await coordinator.preferences.read('money', id)).recurrence,
      ReminderRecurrence.weekly,
    );
    await db.updateMoney(
      id,
      const MoneyEntriesCompanion(settled: Value(false)),
    );
    await coordinator.syncMoney(id);
    expect(
      scheduler.pending[reminderId('money', id)]!.date,
      DateTime(2026, 2, 7, 9),
    );
  });
  test('Past snooze rejected without overwriting saved recurrence', () async {
    final id = await add();
    await coordinator.configure('thing', id, ReminderRecurrence.monthly);
    await expectLater(
      coordinator.snooze('thing', id, clock),
      throwsArgumentError,
    );
    expect(
      (await coordinator.preferences.read('thing', id)).recurrence,
      ReminderRecurrence.monthly,
    );
  });
}
