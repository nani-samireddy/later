import '../../../core/widgets/entry_reminder_controls.dart';
import '../../../core/widgets/attachment_panel.dart';
import '../../../core/attachments/stored_attachment.dart';
import '../../../core/widgets/confirm_delete.dart';
import '../data/money_repository.dart';

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import 'dialogs/edit_money_dialog.dart';
import 'widgets/money_detail_row.dart';
import '../domain/amount.dart';

class MoneyDetailScreen extends StatefulWidget {
  final MoneyEntry entry;
  final AppDatabase database;
  const MoneyDetailScreen({
    super.key,
    required this.entry,
    required this.database,
  });

  @override
  State<MoneyDetailScreen> createState() => _MoneyDetailScreenState();
}

class _MoneyDetailScreenState extends State<MoneyDetailScreen> {
  late MoneyEntry entry;
  late final MoneyRepository _repository = MoneyRepository(widget.database);

  @override
  void initState() {
    super.initState();
    entry = widget.entry;
  }

  Future<void> _toggleSettled() async {
    if (entry.settled &&
        !await confirmDelete(context, 'all repayments (reopen this debt)')) {
      return;
    }
    await _repository.setSettled(entry.id, !entry.settled);
    final updated = await _repository.find(entry.id);
    if (mounted) setState(() => entry = updated);
  }

  Future<void> _payment([MoneyPayment? payment]) async {
    final controller = TextEditingController(
      text: payment?.amount.toStringAsFixed(2) ?? '',
    );
    String? error;
    bool saving = false;
    final route = DialogRoute<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: Text(
            payment == null ? 'Record repayment' : 'Correct repayment',
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount (${entry.currency})',
              errorText: error,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      final amount = parseAmount(controller.text);
                      if (amount == null) {
                        update(
                          () => error = 'Enter a positive amount with at most two decimals',
                        );
                        return;
                      }
                      update(() => saving = true);
                      try {
                        await _repository.savePayment(
                          entry.id,
                          amount,
                          paymentId: payment?.id,
                        );
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext, true);
                        }
                      } on ArgumentError catch (e) {
                        if (dialogContext.mounted) {
                          update(() {
                            saving = false;
                            error = e.message.toString();
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
    controller.dispose();
    if (saved == true) {
      final updated = await _repository.find(entry.id);
      if (mounted) setState(() => entry = updated);
    }
  }

  Future<void> _deletePayment(MoneyPayment payment) async {
    if (!await confirmDelete(context, 'this repayment')) return;
    await _repository.deletePayment(entry.id, payment.id);
    final updated = await _repository.find(entry.id);
    if (mounted) setState(() => entry = updated);
  }

  Future<void> _spendingDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: entry.createdAt,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (date == null) return;
    await widget.database.updateMoney(
      entry.id,
      MoneyEntriesCompanion(createdAt: Value(date)),
    );
    final updated = await _repository.find(entry.id);
    if (mounted) setState(() => entry = updated);
  }

  Future<void> _edit() async {
    final saved = await showEditMoneyDialog(
      context,
      entry: entry,
      database: widget.database,
    );
    if (saved == true && mounted) {
      final updated = await _repository.find(entry.id);
      setState(() => entry = updated);
    }
  }

  Future<void> _delete() async {
    if (!await confirmDelete(context, entry.person)) return;
    await _repository.delete(entry.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Money details'),
      actions: [
        IconButton(onPressed: _edit, icon: const Icon(Icons.edit_outlined)),
        IconButton(
          tooltip: 'Delete',
          onPressed: _delete,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.currency} ${entry.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.kind == 'spending'
                      ? 'Spending'
                      : (entry.owedToMe ? 'Owed to you' : 'You owe'),
                  style: TextStyle(
                    color: entry.owedToMe
                        ? const Color(0xFF34725F)
                        : const Color(0xFFC66A3D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Divider(height: 28),
                if (entry.kind == 'debt') ...[
                  MoneyDetailRow(
                    label: 'Repaid',
                    value:
                        '${entry.currency} ${entry.paidAmount.toStringAsFixed(2)}',
                  ),
                  MoneyDetailRow(
                    label: 'Remaining',
                    value:
                        '${entry.currency} ${(entry.settled ? 0 : (entry.amount - entry.paidAmount).clamp(0, entry.amount)).toStringAsFixed(2)}',
                  ),
                ],
                MoneyDetailRow(label: 'Person', value: entry.person),
                MoneyDetailRow(
                  label: 'Reason',
                  value: entry.reason.isEmpty ? '—' : entry.reason,
                ),
                MoneyDetailRow(
                  label: 'Status',
                  value: entry.settled ? 'Settled' : 'Open',
                ),
                if (entry.dueDate != null)
                  MoneyDetailRow(
                    label: 'Due date',
                    value:
                        '${entry.dueDate!.day}/${entry.dueDate!.month}/${entry.dueDate!.year} at ${TimeOfDay.fromDateTime(entry.dueDate!).format(context)}',
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (entry.kind == 'spending')
          OutlinedButton(
            onPressed: _spendingDate,
            child: Text(
              'Spending date: ${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year}',
            ),
          ),
        if (entry.kind == 'debt')
          FilledButton.icon(
            onPressed: _toggleSettled,
            icon: Icon(
              entry.settled ? Icons.undo_rounded : Icons.check_rounded,
            ),
            label: Text(entry.settled ? 'Mark as open' : 'Mark as settled'),
          ),
        if (entry.kind == 'debt') ...[
          if (!entry.settled)
            OutlinedButton(
              onPressed: _payment,
              child: const Text('Record partial repayment'),
            ),
          FutureBuilder<List<MoneyPayment>>(
            future: _repository.paymentsFor(entry.id),
            builder: (context, snapshot) => Column(
              children: [
                const ListTile(title: Text('Payment history')),
                for (final payment in snapshot.data ?? <MoneyPayment>[])
                  ListTile(
                    title: Text(
                      '${entry.currency} ${payment.amount.toStringAsFixed(2)}',
                    ),
                    subtitle: Text(
                      '${payment.paidAt.day}/${payment.paidAt.month}/${payment.paidAt.year}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Correct repayment',
                          onPressed: () => _payment(payment),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'Delete repayment',
                          onPressed: () => _deletePayment(payment),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        if (entry.dueDate != null)
          EntryReminderControls(
            database: widget.database,
            type: 'money',
            recordId: entry.id,
            date: entry.dueDate!,
            enabled: !entry.settled,
          ),
        AttachmentPanel(
          database: widget.database,
          owner: AttachmentOwner.money,
          recordId: entry.id,
        ),
      ],
    ),
  );
}
