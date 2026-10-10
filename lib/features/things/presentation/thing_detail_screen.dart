import '../../../core/widgets/entry_reminder_controls.dart';
import '../../../core/widgets/attachment_panel.dart';
import '../../../core/attachments/stored_attachment.dart';
import '../../../core/widgets/reminder_picker.dart';

import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart' hide Thing;
import '../../../core/widgets/confirm_delete.dart';
import '../../../core/utils/date_format.dart';
import '../data/things_repository.dart';
import '../domain/thing.dart';

class ThingDetailScreen extends StatefulWidget {
  final Thing entry;
  final AppDatabase database;
  const ThingDetailScreen({
    super.key,
    required this.entry,
    required this.database,
  });
  @override
  State<ThingDetailScreen> createState() => _ThingDetailScreenState();
}

class _ThingDetailScreenState extends State<ThingDetailScreen> {
  late Thing entry = widget.entry;
  late final ThingsRepository repository = ThingsRepository(widget.database);
  Future<void> _edit() async {
    final title = TextEditingController(text: entry.title);
    final description = TextEditingController(text: entry.description);
    final category = TextEditingController(text: entry.category);
    DateTime? reminderDate = entry.reminderDate;
    var saving = false;
    final formKey = GlobalKey<FormState>();
    final route = DialogRoute<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('Edit item'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a title'
                        : null,
                  ),
                  TextFormField(
                    controller: description,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                    ),
                  ),
                  TextFormField(
                    controller: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  ReminderPicker(
                    database: widget.database,
                    value: reminderDate,
                    onChanged: (value) => update(() => reminderDate = value),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      update(() => saving = true);
                      try {
                        await repository.edit(
                          entry.id,
                          title.text,
                          category.text,
                          reminderDate: reminderDate,
                          description: description.text,
                        );
                        if (context.mounted) Navigator.pop(context, true);
                      } catch (_) {
                        if (context.mounted) {
                          update(() => saving = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Could not save this item. Try again.',
                              ),
                            ),
                          );
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
    title.dispose();
    category.dispose();
    description.dispose();
    if (saved == true) {
      final updated = await repository.find(entry.id);
      if (mounted && updated != null) setState(() => entry = updated);
    }
  }

  bool changingStatus = false;
  Future<void> _changeStatus(Future<void> Function() action) async {
    setState(() => changingStatus = true);
    try {
      await action();
      final updated = await repository.find(entry.id);
      if (mounted && updated != null) setState(() => entry = updated);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update status. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => changingStatus = false);
    }
  }

  Future<void> _delete() async {
    if (!await confirmDelete(context, entry.title)) return;
    await repository.delete(entry.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Thing'),
      actions: [
        IconButton(
          tooltip: 'Edit',
          onPressed: _edit,
          icon: const Icon(Icons.edit_outlined),
        ),
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
        Icon(entry.icon, size: 48),
        const SizedBox(height: 16),
        Text(entry.title, style: Theme.of(context).textTheme.headlineMedium),
        Text(entry.category),
        const SizedBox(height: 12),
        Text('Status: ${entry.status.label}'),
        if (entry.completedAt != null)
          Text('Completed on ${formatDate(entry.completedAt!)}'),
        if (entry.archivedAt != null)
          Text('Archived on ${formatDate(entry.archivedAt!)}'),
        Wrap(
          spacing: 8,
          children: [
            if (entry.status != ThingStatus.archived)
              FilledButton.tonal(
                onPressed: changingStatus
                    ? null
                    : () => _changeStatus(
                        () => repository.setCompleted(entry.id, entry.isActive),
                      ),
                child: Text(entry.isActive ? 'Mark done' : 'Reopen'),
              ),
            OutlinedButton(
              onPressed: changingStatus
                  ? null
                  : () => _changeStatus(
                      () => repository.setArchived(
                        entry.id,
                        entry.status != ThingStatus.archived,
                      ),
                    ),
              child: Text(
                entry.status == ThingStatus.archived ? 'Unarchive' : 'Archive',
              ),
            ),
          ],
        ),
        if (!entry.isActive && entry.reminderDate != null)
          const Text(
            'Reminder paused while this item is completed or archived.',
          ),
        if (entry.description.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(entry.description),
        ],
        const SizedBox(height: 24),
        if (entry.reminderDate != null)
          ListTile(
            leading: const Icon(Icons.notifications_none),
            title: Text(
              '${formatDate(entry.reminderDate!)} at ${TimeOfDay.fromDateTime(entry.reminderDate!).format(context)}',
            ),
          ),
        if (entry.reminderDate != null)
          EntryReminderControls(
            database: widget.database,
            type: 'thing',
            recordId: entry.id,
            date: entry.reminderDate!,
            enabled: entry.isActive,
          ),
        AttachmentPanel(
          database: widget.database,
          owner: AttachmentOwner.thing,
          recordId: entry.id,
        ),
      ],
    ),
  );
}
