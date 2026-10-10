import 'package:flutter/material.dart';

import '../notifications/notification_service.dart';
import '../database/app_database.dart';
import '../../features/settings/data/settings_preferences.dart';
import '../utils/date_format.dart';

Future<DateTime?> pickReminder(
  BuildContext context,
  DateTime? current, {
  AppDatabase? database,
}) async {
  final defaultTime = database == null
      ? SettingsPreferences.defaultReminderTime
      : await SettingsPreferences(database).reminderTime();
  if (!context.mounted) return null;
  final now = DateTime.now();
  final first = DateTime(now.year, now.month, now.day);
  final date = await showDatePicker(
    context: context,
    firstDate: first,
    lastDate: DateTime(2100),
    initialDate: current != null && !current.isBefore(first) ? current : first,
  );
  if (date == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: current == null
        ? defaultTime
        : TimeOfDay.fromDateTime(current),
  );
  if (time == null) return null;
  final result = DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
  if (!result.isAfter(DateTime.now())) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a future reminder time.')),
      );
    }
    return null;
  }
  await NotificationService.requestExactTiming();
  return result;
}

class ReminderPicker extends StatelessWidget {
  final AppDatabase? database;
  final bool showHelp;
  final bool enabled;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  const ReminderPicker({
    super.key,
    this.database,
    this.showHelp = true,
    this.enabled = true,
    required this.value,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.notifications_none_rounded),
    title: Text(
      value == null
          ? 'Add reminder'
          : '${formatDate(value!)} at ${TimeOfDay.fromDateTime(value!).format(context)}',
    ),
    subtitle: showHelp
        ? const Text(
            'Device local time. Exact timing needs Android alarm permission.',
          )
        : null,
    trailing: value == null
        ? null
        : IconButton(
            tooltip: 'Remove reminder',
            icon: const Icon(Icons.close),
            onPressed: enabled ? () => onChanged(null) : null,
          ),
    onTap: !enabled
        ? null
        : () async {
            final date = await pickReminder(context, value, database: database);
            if (date != null) onChanged(date);
          },
  );
}
