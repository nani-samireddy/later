import 'package:flutter/material.dart';

class CategoryPill extends StatelessWidget {
  final String label;
  final IconData icon;
  const CategoryPill({super.key, required this.label, required this.icon});
  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, size: 18, color: const Color(0xFF34725F)),
    label: Text(label),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    backgroundColor: Colors.white,
    side: BorderSide.none,
  );
}
