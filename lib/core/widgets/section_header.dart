import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title, action;
  final VoidCallback? onAction;
  final IconData? actionIcon;
  const SectionHeader({
    super.key,
    required this.title,
    required this.action,
    this.onAction,
    this.actionIcon,
  });
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      const SizedBox(width: 12),
      if (actionIcon != null)
        IconButton(
          onPressed: onAction,
          tooltip: action,
          icon: Icon(actionIcon, size: 18, color: const Color(0xFF7A8373)),
        )
      else
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF7A8373),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: const Size(44, 44),
            textStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
          child: Text(action),
        ),
    ],
  );
}
