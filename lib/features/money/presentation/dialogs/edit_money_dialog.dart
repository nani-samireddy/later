import '../../../../core/widgets/reminder_picker.dart';
import '../../domain/amount.dart';

import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../data/money_repository.dart';

Future<bool?> showEditMoneyDialog(
  BuildContext context, {
  required MoneyEntry entry,
  required AppDatabase database,
}) async {
  final person = TextEditingController(text: entry.person);
  final amount = TextEditingController(text: entry.amount.toString());
  final reason = TextEditingController(text: entry.reason);
  String? error;
  var saving = false;
  var owedToMe = entry.owedToMe;
  var moneyKind = entry.kind == 'spending'
      ? 'spending'
      : (entry.owedToMe ? 'owedToMe' : 'iOwe');
  DateTime? dueDate = entry.dueDate;
  TimeOfDay reminderTime = entry.dueDate == null
      ? const TimeOfDay(hour: 9, minute: 0)
      : TimeOfDay(hour: entry.dueDate!.hour, minute: entry.dueDate!.minute);
  final route = DialogRoute<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('Edit money item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'owedToMe', label: Text('Owed to me')),
                  ButtonSegment(value: 'iOwe', label: Text('I owe')),
                  ButtonSegment(value: 'spending', label: Text('Spending')),
                ],
                selected: {moneyKind},
                onSelectionChanged: (value) => setDialogState(() {
                  moneyKind = value.first;
                  owedToMe = moneyKind == 'owedToMe';
                }),
              ),
              TextField(
                controller: person,
                decoration: const InputDecoration(labelText: 'Person'),
              ),
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '${entry.currency} ',
                ),
              ),
              TextField(
                controller: reason,
                decoration: const InputDecoration(labelText: 'Reason'),
              ),
              if (error != null)
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ReminderPicker(
                database: database,
                value: dueDate == null
                    ? null
                    : DateTime(
                        dueDate!.year,
                        dueDate!.month,
                        dueDate!.day,
                        reminderTime.hour,
                        reminderTime.minute,
                      ),
                onChanged: (date) => setDialogState(() {
                  dueDate = date;
                  if (date != null) reminderTime = TimeOfDay.fromDateTime(date);
                }),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: saving
                ? null
                : () async {
                    final parsedAmount = parseAmount(amount.text);
                    if ((moneyKind != 'spending' &&
                            person.text.trim().isEmpty) ||
                        parsedAmount == null ||
                        !parsedAmount.isFinite) {
                      setDialogState(
                        () => error = 'Enter a name and a positive amount with up to two decimal places.',
                      );
                      return;
                    }
                    setDialogState(() => saving = true);
                    try {
                      await MoneyRepository(database).edit(
                        entry,
                        person: person.text.trim(),
                        amount: parsedAmount,
                        reason: reason.text.trim(),
                        owedToMe: owedToMe,
                        moneyKind: moneyKind,
                        dueDate: dueDate,
                        reminderTime: reminderTime,
                      );
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext, true);
                      }
                    } on ArgumentError catch (e) {
                      if (dialogContext.mounted) {
                        setDialogState(() {
                          saving = false;
                          error = e.message.toString();
                        });
                      }
                    } catch (_) {
                      if (dialogContext.mounted) {
                        setDialogState(() {
                          saving = false;
                          error = 'Could not save changes. Try again.';
                        });
                      }
                    }
                  },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
  final saved = await Navigator.of(context).push(route);
  await route.completed;
  person.dispose();
  amount.dispose();
  reason.dispose();
  return saved;
}
