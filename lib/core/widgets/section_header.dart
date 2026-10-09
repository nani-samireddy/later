import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title, action;
  final VoidCallback? onAction;
  const SectionHeader({
    super.key,
    required this.title,
    required this.action,
    this.onAction,
  });
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
      InkWell(
        onTap: onAction,
        child: Text(
          action,
          style: const TextStyle(
            color: Color(0xFF34725F),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}
