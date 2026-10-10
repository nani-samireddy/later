import 'package:flutter/material.dart';

class ReminderCard extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final Color color;
  final String title, subtitle;
  const ReminderCard({
    super.key,
    this.onTap,
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
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF34725F)),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right_rounded),
    ),
  );
}
