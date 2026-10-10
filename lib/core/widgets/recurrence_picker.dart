import 'package:flutter/material.dart';

import '../reminders/recurrence.dart';

/// Place next to ReminderPicker; parent persists the value with its entry.
class RecurrencePicker extends StatelessWidget {
  const RecurrencePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });
  final ReminderRecurrence value;
  final ValueChanged<ReminderRecurrence> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) =>
      DropdownButtonFormField<ReminderRecurrence>(
        key: ValueKey(value),
        initialValue: value,
        decoration: const InputDecoration(labelText: 'Repeat reminder'),
        items: ReminderRecurrence.values
            .map(
              (item) => DropdownMenuItem(value: item, child: Text(item.label)),
            )
            .toList(),
        onChanged: enabled
            ? (item) {
                if (item != null) onChanged(item);
              }
            : null,
      );
}

class SnoozeActions extends StatelessWidget {
  const SnoozeActions({super.key, required this.onSnooze, this.enabled = true});
  final ValueChanged<DateTime> onSnooze;
  final bool enabled;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    children: [
      TextButton.icon(
        icon: const Icon(Icons.snooze),
        label: const Text('Snooze 1 hour'),
        onPressed: enabled
            ? () => onSnooze(DateTime.now().add(const Duration(hours: 1)))
            : null,
      ),
      TextButton(
        onPressed: enabled
            ? () => onSnooze(snoozeTomorrow(DateTime.now()))
            : null,
        child: const Text('Tomorrow at 9 AM'),
      ),
    ],
  );
}
