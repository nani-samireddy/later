import 'package:flutter/material.dart';

class RecentCard extends StatelessWidget {
  final IconData icon;
  final String title, detail;
  const RecentCard({
    super.key,
    required this.icon,
    required this.title,
    required this.detail,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: 190,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF34725F)),
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(detail, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}
