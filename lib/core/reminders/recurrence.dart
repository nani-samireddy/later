/// Calendar recurrence in device-local wall time. Monthly repeats always use
/// the original day, so January 31 → February 28 → March 31.
enum ReminderRecurrence {
  none('Does not repeat'),
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly');

  const ReminderRecurrence(this.label);
  final String label;

  static ReminderRecurrence parse(String? value) =>
      values.firstWhere((item) => item.name == value, orElse: () => none);
}

DateTime? nextReminderOccurrence({
  required DateTime anchor,
  required ReminderRecurrence recurrence,
  required DateTime after,
}) {
  final local = anchor.toLocal();
  final cutoff = after.toLocal();
  if (local.isAfter(cutoff)) return local;
  if (recurrence == ReminderRecurrence.none) return null;
  DateTime occurrence(int step) {
    if (recurrence == ReminderRecurrence.monthly) {
      final month = DateTime(local.year, local.month + step);
      final lastDay = DateTime(month.year, month.month + 1, 0).day;
      return DateTime(
        month.year,
        month.month,
        local.day > lastDay ? lastDay : local.day,
        local.hour,
        local.minute,
        local.second,
        local.millisecond,
        local.microsecond,
      );
    }
    return DateTime(
      local.year,
      local.month,
      local.day + step * (recurrence == ReminderRecurrence.weekly ? 7 : 1),
      local.hour,
      local.minute,
      local.second,
      local.millisecond,
      local.microsecond,
    );
  }

  // Estimate using calendar days, then adjust for local daylight saving time.
  var step = recurrence == ReminderRecurrence.monthly
      ? (cutoff.year - local.year) * 12 + cutoff.month - local.month
      : DateTime.utc(cutoff.year, cutoff.month, cutoff.day)
                .difference(DateTime.utc(local.year, local.month, local.day))
                .inDays ~/
            (recurrence == ReminderRecurrence.weekly ? 7 : 1);
  if (step < 0) step = 0;
  while (!occurrence(step).isAfter(cutoff)) {
    step++;
  }
  return occurrence(step);
}

DateTime snoozeTomorrow(DateTime now) {
  final local = now.toLocal();
  return DateTime(local.year, local.month, local.day + 1, 9);
}
