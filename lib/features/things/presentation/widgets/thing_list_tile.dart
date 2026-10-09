import 'package:flutter/material.dart';
import 'package:later/features/things/domain/thing.dart';
import 'package:later/features/things/presentation/thing_detail_screen.dart';

class ThingListTile extends StatelessWidget {
  final Thing entry;
  const ThingListTile({super.key, required this.entry});
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ThingDetailScreen(entry: entry)),
      ),
      leading: Icon(entry.icon, color: const Color(0xFF34725F)),
      title: Text(
        entry.title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(entry.category),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}
