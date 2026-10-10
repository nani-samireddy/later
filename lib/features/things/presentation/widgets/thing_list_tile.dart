import 'package:flutter/material.dart';

import '../../domain/thing.dart';

class ThingListTile extends StatelessWidget {
  final Thing entry;
  final VoidCallback onTap;
  const ThingListTile({super.key, required this.entry, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      onTap: onTap,
      leading: Icon(entry.icon, color: const Color(0xFF34725F)),
      title: Text(
        entry.title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text('${entry.category} · ${entry.status.label}'),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}
