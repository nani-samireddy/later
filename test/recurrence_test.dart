import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/reminders/recurrence.dart';

void main() {
  DateTime? next(DateTime anchor, ReminderRecurrence repeat, DateTime after) =>
      nextReminderOccurrence(anchor: anchor, recurrence: repeat, after: after);
  test('Monthly clamping preserves anchor day and wall time', () {
    final anchor = DateTime(2026, 1, 31, 9, 15);
    expect(
      next(anchor, ReminderRecurrence.monthly, anchor),
      DateTime(2026, 2, 28, 9, 15),
    );
    expect(
      next(anchor, ReminderRecurrence.monthly, DateTime(2026, 2, 28, 9, 15)),
      DateTime(2026, 3, 31, 9, 15),
    );
    expect(
      next(
        DateTime(2024, 1, 31, 9),
        ReminderRecurrence.monthly,
        DateTime(2024, 2),
      ),
      DateTime(2024, 2, 29, 9),
    );
    expect(
      next(anchor, ReminderRecurrence.monthly, DateTime(2026, 12, 31, 9, 15)),
      DateTime(2027, 1, 31, 9, 15),
    );
  });
  test('Daily and weekly skip missed dates and equality', () {
    final anchor = DateTime(2020, 1, 1, 9);
    expect(
      next(anchor, ReminderRecurrence.daily, DateTime(2026, 10, 10, 9)),
      DateTime(2026, 10, 11, 9),
    );
    expect(
      next(
        DateTime(2026, 10, 1, 9),
        ReminderRecurrence.weekly,
        DateTime(2026, 10, 8, 9),
      ),
      DateTime(2026, 10, 15, 9),
    );
  });
  test(
    'One-off past dates remain unscheduled and tomorrow defaults to 9 AM',
    () {
      final anchor = DateTime(2026, 1, 1);
      expect(next(anchor, ReminderRecurrence.none, anchor), isNull);
      expect(next(anchor, ReminderRecurrence.none, DateTime(2025)), anchor);
      expect(
        snoozeTomorrow(DateTime(2026, 12, 31, 23)),
        DateTime(2027, 1, 1, 9),
      );
    },
  );
}
