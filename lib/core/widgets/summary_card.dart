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
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 190;
      final content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: compact ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ],
      );
      return Container(
        padding: EdgeInsets.all(compact ? 12 : 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: tint,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(icon, color: const Color(0xFF34725F)),
                  ),
                  const SizedBox(height: 10),
                  content,
                ],
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: tint,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(icon, color: const Color(0xFF34725F)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: content),
                ],
              ),
      );
    },
  );
}
