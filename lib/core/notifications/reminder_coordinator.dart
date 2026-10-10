import '../database/app_database.dart';
import '../reminders/recurrence.dart';
import '../reminders/reminder_preferences.dart';
import 'notification_service.dart';
import 'reminder_scheduler.dart';

class ReminderCoordinator {
  final AppDatabase database;
  final ReminderScheduler scheduler;
  final DateTime Function() now;
  late final preferences = ReminderPreferencesStore(database);
  ReminderCoordinator(
    this.database, {
    ReminderScheduler? scheduler,
    DateTime Function()? now,
  }) : scheduler = scheduler ?? const NotificationService(),
       now = now ?? DateTime.now;

  static final _queues = Expando<Map<String, Future<void>>>();
  Future<void> _serial(String type, int id, Future<void> Function() action) {
    final queue = _queues[database] ??= {};
    final key = '$type:$id';
    final previous = queue[key] ?? Future<void>.value();
    final operation = previous.then((_) => action());
    final tail = operation.then<void>((_) {}, onError: (Object _) {});
    queue[key] = tail;
    tail.then((_) {
      if (identical(queue[key], tail)) queue.remove(key);
    });
    return operation;
  }

  Future<void> cancel(String type, int id) =>
      _serial(type, id, () => _cancel(type, id));

  /// Use for actual record deletion; cancel alone also supports backup rebuilds.
  Future<void> forget(String type, int id) => _serial(type, id, () async {
    await _cancel(type, id);
    await preferences.remove(type, id);
  });

  Future<void> _cancel(String type, int id) async {
    await scheduler.cancel(reminderId(type, id));
    for (var i = 0; i < 12; i++) {
      await scheduler.cancel(monthlyReminderId(type, id, i));
    }
  }

  /// Save explicit controls after the entry's date has been persisted.
  Future<void> configure(String type, int id, ReminderRecurrence recurrence) =>
      _serial(type, id, () => _configure(type, id, recurrence));

  Future<void> _configure(
    String type,
    int id,
    ReminderRecurrence recurrence,
  ) async {
    final anchor = await _anchor(type, id);
    if (anchor == null && recurrence != ReminderRecurrence.none) {
      throw ArgumentError('Choose a reminder date before enabling repeat');
    }
    await preferences.write(
      type,
      id,
      ReminderPreferences(anchor: anchor, recurrence: recurrence),
    );
    await (type == 'thing' ? _syncThing(id) : _syncMoney(id));
  }

  Future<void> snooze(String type, int id, DateTime until) =>
      _serial(type, id, () => _snooze(type, id, until));

  Future<void> _snooze(String type, int id, DateTime until) async {
    if (!until.isAfter(now())) {
      throw ArgumentError('Choose a future snooze time');
    }
    final anchor = await _anchor(type, id);
    if (anchor == null) throw ArgumentError('This entry has no reminder');
    final policy = await preferences.read(type, id);
    await preferences.write(
      type,
      id,
      ReminderPreferences(
        anchor: anchor,
        recurrence: policy.recurrence,
        snoozedUntil: until.toLocal(),
      ),
    );
    await (type == 'thing' ? _syncThing(id) : _syncMoney(id));
  }

  Future<DateTime?> _anchor(String type, int id) async {
    if (type == 'thing') {
      final entry = await database.thingById(id);
      return entry?.status == 'active' ? entry?.reminderDate : null;
    }
    if (type != 'money') throw ArgumentError('Unknown reminder type');
    final entry = await (database.select(
      database.moneyEntries,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
    return entry != null && !entry.settled ? entry.dueDate : null;
  }

  Future<void> sync(String type, int id) =>
      type == 'thing' ? syncThing(id) : syncMoney(id);

  Future<void> _schedule(
    String type,
    int id,
    DateTime anchor,
    String title,
    String body,
  ) async {
    var policy = await preferences.read(type, id);
    // Editing the date keeps the explicit repeat choice but resets snoozes and
    // the monthly anchor. Clearing/completing the entry resets both below.
    if (policy.anchor != anchor) {
      policy = ReminderPreferences(
        anchor: anchor,
        recurrence: policy.recurrence,
      );
      await preferences.write(type, id, policy);
    }
    final clock = now();
    final date = policy.effectiveDate(anchor, clock);
    if (date == null) return;
    final payload = '$type:$id';
    final native = scheduler;
    final snoozed = policy.snoozedUntil?.isAfter(clock) == true;
    if (!snoozed &&
        native is CalendarReminderScheduler &&
        (policy.recurrence == ReminderRecurrence.daily ||
            policy.recurrence == ReminderRecurrence.weekly)) {
      await native.scheduleCalendar(
        id: reminderId(type, id),
        title: title,
        body: body,
        date: date,
        payload: payload,
        weekly: policy.recurrence == ReminderRecurrence.weekly,
      );
      return;
    }
    await scheduler.schedule(
      id: reminderId(type, id),
      title: title,
      body: body,
      date: date,
      payload: payload,
    );
    if (policy.recurrence == ReminderRecurrence.none) return;
    // A separate calendar series retains the original wall time after snooze.
    // Monthly schedules cover a rolling year, refreshed whenever the app opens.
    var cutoff = date;
    for (var i = 0; i < 12; i++) {
      final next = nextReminderOccurrence(
        anchor: anchor,
        recurrence: policy.recurrence,
        after: cutoff,
      )!;
      if (native is CalendarReminderScheduler &&
          policy.recurrence != ReminderRecurrence.monthly) {
        await native.scheduleCalendar(
          id: monthlyReminderId(type, id, 0),
          title: title,
          body: body,
          date: next,
          payload: payload,
          weekly: policy.recurrence == ReminderRecurrence.weekly,
        );
        break;
      }
      await scheduler.schedule(
        id: monthlyReminderId(type, id, i),
        title: title,
        body: body,
        date: next,
        payload: payload,
      );
      cutoff = next;
    }
  }

  Future<void> _clear(String type, int id) =>
      preferences.write(type, id, const ReminderPreferences());

  Future<void> syncThing(int id) => _serial('thing', id, () => _syncThing(id));
  Future<void> _syncThing(int id) async {
    await _cancel('thing', id);
    final thing = await database.thingById(id);
    if (thing == null || thing.reminderDate == null) {
      await _clear('thing', id);
      return;
    }
    if (thing.status != 'active') return;
    await _schedule(
      'thing',
      id,
      thing.reminderDate!,
      'Thing reminder',
      thing.title,
    );
  }

  Future<void> syncMoney(int id) => _serial('money', id, () => _syncMoney(id));
  Future<void> _syncMoney(int id) async {
    await _cancel('money', id);
    final entry = await (database.select(
      database.moneyEntries,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
    if (entry == null || entry.dueDate == null) {
      await _clear('money', id);
      return;
    }
    if (entry.settled) return;
    final outstanding = entry.kind == 'debt'
        ? (entry.amount - entry.paidAmount).clamp(0, entry.amount)
        : entry.amount;
    if (entry.kind == 'debt' && outstanding <= 0) return;
    final amount = '${entry.currency} ${outstanding.toStringAsFixed(2)}';
    await _schedule(
      'money',
      id,
      entry.dueDate!,
      'Money reminder',
      entry.kind == 'spending'
          ? '${entry.person}: $amount'
          : entry.owedToMe
          ? '${entry.person} owes you $amount'
          : 'You owe ${entry.person} $amount',
    );
  }

  Future<void> syncAll() async {
    for (final thing in await database.allThings()) {
      await syncThing(thing.id);
    }
    for (final entry in await database.allMoney()) {
      await syncMoney(entry.id);
    }
  }
}
