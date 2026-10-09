import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, body;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(30),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      children: [
        Icon(icon, size: 42, color: const Color(0xFF34725F)),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        Text(body, textAlign: TextAlign.center),
      ],
    ),
  );
}
