import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color tint;
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.tint,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: tint,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: const Color(0xFF323D35).withValues(alpha: .06)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Color(0xFF737E69)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
                color: Color(0xFF323D35),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          title == 'Owed to you'
              ? 'Room for a gentle nudge'
              : title == 'You owe'
              ? 'All in one place'
              : 'The little things add up',
          style: const TextStyle(fontSize: 10, color: Color(0xFF7A8373)),
        ),
      ],
    ),
  );
}
