import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../data/money_repository.dart';
import '../../../../core/utils/date_format.dart';

Future<bool?> showEditMoneyDialog(
  BuildContext context, {
  required MoneyEntry entry,
  required AppDatabase database,
}) async {
  final person = TextEditingController(text: entry.person);
  final amount = TextEditingController(text: entry.amount.toString());
  final reason = TextEditingController(text: entry.reason);
  var owedToMe = entry.owedToMe;
  var moneyKind = entry.kind == 'spending'
      ? 'spending'
      : (entry.owedToMe ? 'owedToMe' : 'iOwe');
  DateTime? dueDate = entry.dueDate;
  TimeOfDay reminderTime = entry.dueDate == null
      ? const TimeOfDay(hour: 9, minute: 0)
      : TimeOfDay(hour: entry.dueDate!.hour, minute: entry.dueDate!.minute);
  final saved = await showDialog<bool>(
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
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                ),
              ),
              TextField(
                controller: reason,
                decoration: const InputDecoration(labelText: 'Reason'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_none_rounded),
                title: Text(
                  dueDate == null
                      ? 'Add reminder'
                      : 'Reminder: ${formatDate(dueDate!)}',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                    initialDate:
                        dueDate ?? DateTime.now().add(const Duration(days: 7)),
                  );
                  if (picked != null) setDialogState(() => dueDate = picked);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule_rounded),
                title: Text('Time: ${reminderTime.format(context)}'),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: reminderTime,
                  );
                  if (picked != null) {
                    setDialogState(() => reminderTime = picked);
                  }
                },
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
            onPressed: () async {
              final parsedAmount = double.tryParse(amount.text.trim());
              if (person.text.trim().isEmpty ||
                  parsedAmount == null ||
                  parsedAmount <= 0) {
                return;
              }
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
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
  person.dispose();
  amount.dispose();
  reason.dispose();
  return saved;
}
