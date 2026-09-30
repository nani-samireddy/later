import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/notifications/notification_service.dart';

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
  List<MoneyAttachment> attachments = [];

  @override
  void initState() {
    super.initState();
    entry = widget.entry;
    _loadAttachments();
  }

  Future<void> _loadAttachments() async {
    final loaded = await widget.database.moneyAttachmentsFor(entry.id);
    if (mounted) setState(() => attachments = loaded);
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp', 'heic'],
    );
    final file = result?.files.single;
    if (file == null || file.path == null) return;
    await widget.database.addMoneyAttachment(
      MoneyAttachmentsCompanion.insert(
        moneyId: entry.id,
        name: file.name,
        path: file.path!,
        kind: file.extension?.toLowerCase() == 'pdf' ? 'document' : 'image',
      ),
    );
    await _loadAttachments();
  }

  Future<void> _toggleSettled() async {
    await widget.database.updateMoney(
      entry.id,
      MoneyEntriesCompanion(settled: Value(!entry.settled)),
    );
    setState(() => entry = entry.copyWith(settled: !entry.settled));
  }

  Future<void> _edit() async {
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
                        : 'Reminder: ${_date(dueDate!)}',
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      initialDate:
                          dueDate ??
                          DateTime.now().add(const Duration(days: 7)),
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
                await widget.database.updateMoney(
                  entry.id,
                  MoneyEntriesCompanion(
                    person: Value(person.text.trim()),
                    amount: Value(parsedAmount),
                    reason: Value(reason.text.trim()),
                    owedToMe: Value(owedToMe),
                    kind: Value(moneyKind == 'spending' ? 'spending' : 'debt'),
                    dueDate: Value(
                      dueDate == null
                          ? null
                          : DateTime(
                              dueDate!.year,
                              dueDate!.month,
                              dueDate!.day,
                              reminderTime.hour,
                              reminderTime.minute,
                            ),
                    ),
                  ),
                );
                await NotificationService.cancel(entry.id);
                if (dueDate != null && !entry.settled) {
                  await NotificationService.schedule(
                    id: entry.id,
                    title: 'Money reminder',
                    body: owedToMe
                        ? '${person.text.trim()} owes you ${entry.currency} ${parsedAmount.toStringAsFixed(0)}'
                        : 'You owe ${person.text.trim()} ${entry.currency} ${parsedAmount.toStringAsFixed(0)}',
                    date: dueDate!,
                  );
                }
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
    if (saved == true && mounted) {
      final updated = (await widget.database.allMoney()).firstWhere(
        (item) => item.id == entry.id,
      );
      setState(() => entry = updated);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Money details'),
      actions: [
        IconButton(onPressed: _edit, icon: const Icon(Icons.edit_outlined)),
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
                _DetailRow(label: 'Person', value: entry.person),
                _DetailRow(
                  label: 'Reason',
                  value: entry.reason.isEmpty ? '—' : entry.reason,
                ),
                _DetailRow(
                  label: 'Status',
                  value: entry.settled ? 'Settled' : 'Open',
                ),
                if (entry.dueDate != null)
                  _DetailRow(
                    label: 'Due date',
                    value:
                        '${entry.dueDate!.day}/${entry.dueDate!.month}/${entry.dueDate!.year}',
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _toggleSettled,
          icon: Icon(entry.settled ? Icons.undo_rounded : Icons.check_rounded),
          label: Text(entry.settled ? 'Mark as open' : 'Mark as settled'),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Documents and images',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            IconButton(
              onPressed: _pickAttachment,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        if (attachments.isEmpty)
          const Text('No attachments yet. Add a receipt, invoice, or image.'),
        ...attachments.map(
          (attachment) => Card(
            elevation: 0,
            child: ListTile(
              leading: Icon(
                attachment.kind == 'image'
                    ? Icons.image_outlined
                    : Icons.description_outlined,
              ),
              title: Text(attachment.name),
              subtitle: Text(attachment.path),
            ),
          ),
        ),
      ],
    ),
  );
}

String _date(DateTime date) => '${date.day}/${date.month}/${date.year}';

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 90, child: Text(label)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
