import 'package:flutter/material.dart';

class DetailSection extends StatelessWidget {
  final String title;
  final Map<String, String> rows;
  const DetailSection({super.key, required this.title, required this.rows});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ...rows.entries.map(
          (row) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(row.key, style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  row.value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
