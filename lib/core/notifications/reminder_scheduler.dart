abstract interface class ReminderScheduler {
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime date,
    required String payload,
  });
  Future<void> cancel(int id);
}

int reminderId(String type, int recordId) =>
    recordId * 2 + (type == 'money' ? 1 : 0);

/// Optional native calendar repeats; monthly repeats are scheduled individually
/// because native day-of-month repeats skip short months.
abstract interface class CalendarReminderScheduler
    implements ReminderScheduler {
  Future<void> scheduleCalendar({
    required int id,
    required String title,
    required String body,
    required DateTime date,
    required String payload,
    required bool weekly,
  });
}

int monthlyReminderId(String type, int recordId, int occurrence) =>
    -(reminderId(type, recordId) * 16 + occurrence + 1);
