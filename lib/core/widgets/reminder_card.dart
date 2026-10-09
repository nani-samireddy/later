import 'package:flutter/material.dart';

class ReminderCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  const ReminderCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF34725F)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}
