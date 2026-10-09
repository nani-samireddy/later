import '../data/money_repository.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import 'dialogs/edit_money_dialog.dart';
import 'widgets/money_detail_row.dart';

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
  List<MoneyAttachment> attachments = [];

  @override
  void initState() {
    super.initState();
    entry = widget.entry;
    _loadAttachments();
  }

  Future<void> _loadAttachments() async {
    final loaded = await _repository.attachmentsFor(entry.id);
    if (mounted) setState(() => attachments = loaded);
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp', 'heic'],
    );
    final file = result?.files.single;
    if (file == null || file.path == null) return;
    await _repository.addAttachment(entry.id, file);
    await _loadAttachments();
  }

  Future<void> _toggleSettled() async {
    await _repository.setSettled(entry.id, !entry.settled);
    setState(() => entry = entry.copyWith(settled: !entry.settled));
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
