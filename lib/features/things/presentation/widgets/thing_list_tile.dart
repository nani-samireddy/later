import '../../../../core/widgets/note_format.dart';

import 'package:flutter/material.dart';

import '../../../../core/utils/date_format.dart';
import '../../domain/thing.dart';

class ThingListTile extends StatelessWidget {
  final Thing entry;
  final VoidCallback onTap;
  final VoidCallback? onCompleted;
  const ThingListTile({
    super.key,
    required this.entry,
    required this.onTap,
    this.onCompleted,
  });
  @override
  Widget build(BuildContext context) {
    final tint = entry.attachments.isNotEmpty
        ? const Color(0xFFE5DDF1)
        : const Color(0xFFDFE8CE);
    final progress = checklistProgress(entry.description);
    final detail = entry.reminderDate != null
        ? '${formatDate(entry.reminderDate!)} · ${TimeOfDay.fromDateTime(entry.reminderDate!).format(context)}'
        : entry.attachments.isNotEmpty
        ? '${entry.attachments.length} attachment${entry.attachments.length == 1 ? '' : 's'}'
        : '${entry.category} · ${entry.status.label}';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            entry.icon,
            size: 21,
            color: entry.attachments.isNotEmpty
                ? const Color(0xFF9484AE)
                : const Color(0xFF6D8655),
          ),
        ),
        title: Text(
          entry.title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          progress.$2 > 0
              ? '${progress.$1} of ${progress.$2} done · $detail'
              : detail,
          style: const TextStyle(fontSize: 11, color: Color(0xFF7A8373)),
        ),
        trailing: onCompleted == null
            ? const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Color(0xFFA3AE98),
              )
            : Checkbox(
                value: false,
                onChanged: (_) => onCompleted!(),
                semanticLabel: 'Complete ${entry.title}',
                side: const BorderSide(color: Color(0xFFCAD3BD)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
      ),
    );
  }
}
