import 'package:flutter/material.dart';

import '../database/app_database.dart';
import '../notifications/reminder_coordinator.dart';
import '../reminders/reminder_preferences.dart';
import '../utils/date_format.dart';
import 'recurrence_picker.dart';

class EntryReminderControls extends StatefulWidget {
  final AppDatabase database;
  final String type;
  final int recordId;
  final DateTime date;
  final bool enabled;
  const EntryReminderControls({
    super.key,
    required this.database,
    required this.type,
    required this.recordId,
    required this.date,
    this.enabled = true,
  });
  @override
  State<EntryReminderControls> createState() => _EntryReminderControlsState();
}

class _EntryReminderControlsState extends State<EntryReminderControls> {
  ReminderPreferences? policy;
  bool busy = false;
  String? error;
  ReminderCoordinator get reminders => ReminderCoordinator(widget.database);
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant EntryReminderControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date ||
        oldWidget.enabled != widget.enabled ||
        oldWidget.recordId != widget.recordId) {
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final value = await reminders.preferences.read(
        widget.type,
        widget.recordId,
      );
      if (mounted) {
        setState(() {
          policy = value;
          error = null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => error = 'Could not load reminder options.');
    }
  }

  Future<void> _update(Future<void> Function() action) async {
    if (busy || !widget.enabled) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await action();
      await _load();
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Could not update the reminder. Try again.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = policy;
    if (value == null) {
      return error == null
          ? const LinearProgressIndicator()
          : TextButton(onPressed: _load, child: Text(error!));
    }
    final snooze = value.snoozedUntil;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RecurrencePicker(
          value: value.recurrence,
          enabled: widget.enabled && !busy,
          onChanged: (repeat) => _update(
            () => reminders.configure(widget.type, widget.recordId, repeat),
          ),
        ),
        if (widget.enabled)
          SnoozeActions(
            enabled: !busy,
            onSnooze: (until) => _update(
              () => reminders.snooze(widget.type, widget.recordId, until),
            ),
          ),
        if (snooze != null && snooze.isAfter(DateTime.now()))
          Row(
            children: [
              Expanded(
                child: Text(
                  'Snoozed until ${formatDate(snooze)} at ${TimeOfDay.fromDateTime(snooze).format(context)}',
                ),
              ),
              TextButton(
                onPressed: widget.enabled && !busy
                    ? () => _update(
                        () => reminders.configure(
                          widget.type,
                          widget.recordId,
                          value.recurrence,
                        ),
                      )
                    : null,
                child: const Text('Undo snooze'),
              ),
            ],
          ),
        if (error != null)
          Text(
            error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        if (busy) const LinearProgressIndicator(),
      ],
    );
  }
}
