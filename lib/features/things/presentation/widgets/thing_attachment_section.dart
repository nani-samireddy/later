import 'package:flutter/material.dart';
import 'package:later/features/things/domain/thing.dart';

class ThingAttachmentSection extends StatelessWidget {
  final Thing entry;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  const ThingAttachmentSection({
    super.key,
    required this.entry,
    required this.onAdd,
    required this.onRemove,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Attachments',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            IconButton(
              onPressed: onAdd,
              icon: const Icon(
                Icons.attach_file_rounded,
                color: Color(0xFF34725F),
              ),
            ),
          ],
        ),
        if (entry.attachments.isEmpty)
          const Text('Add images, PDFs, receipts, or other documents.'),
        ...entry.attachments.map(
          (name) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.insert_drive_file_outlined,
              color: Color(0xFF34725F),
            ),
            title: Text(name),
            trailing: IconButton(
              onPressed: () => onRemove(name),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ),
      ],
    ),
  );
}
