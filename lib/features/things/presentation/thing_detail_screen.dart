import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:later/core/utils/date_format.dart';
import 'package:later/core/widgets/detail_section.dart';
import 'package:later/features/things/domain/thing.dart';
import 'package:later/features/things/presentation/widgets/thing_attachment_section.dart';

class ThingDetailScreen extends StatefulWidget {
  final Thing entry;
  const ThingDetailScreen({super.key, required this.entry});
  @override
  State<ThingDetailScreen> createState() => _ThingDetailScreenState();
}

class _ThingDetailScreenState extends State<ThingDetailScreen> {
  late String title;
  late String category;

  @override
  void initState() {
    super.initState();
    title = widget.entry.title;
    category = widget.entry.category;
  }

  Future<void> _addAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    if (result == null) return;
    setState(
      () => widget.entry.attachments.addAll(
        result.files.map((file) => file.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Thing'),
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          onPressed: () => _showEditDialog(context),
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFE4F1EB),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(widget.entry.icon, size: 42, color: const Color(0xFF34725F)),
              const SizedBox(height: 22),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                category,
                style: const TextStyle(
                  color: Color(0xFF34725F),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        DetailSection(
          title: 'Record',
          rows: {
            'Added': 'Today',
            'Location': 'Not added yet',
            'Notes': 'No notes yet',
            if (widget.entry.reminderDate != null)
              'Reminder': formatDate(widget.entry.reminderDate!),
          },
        ),
        const SizedBox(height: 16),
        ThingAttachmentSection(
          entry: widget.entry,
          onAdd: _addAttachment,
          onRemove: (name) =>
              setState(() => widget.entry.attachments.remove(name)),
        ),
        const SizedBox(height: 16),
        const DetailSection(title: 'History', rows: {'Today': 'Entry created'}),
      ],
    ),
  );

  Future<void> _showEditDialog(BuildContext context) async {
    final title = TextEditingController(text: widget.entry.title);
    final category = TextEditingController(text: widget.entry.category);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: category,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (title.text.trim().isEmpty) return;
              this.title = title.text.trim();
              this.category = category.text.trim().isEmpty
                  ? 'General'
                  : category.text.trim();
              setState(() {});
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
