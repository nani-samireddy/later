import 'package:flutter/material.dart';

class CaptureOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const CaptureOption({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF34725F), size: 27),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    ),
  );
}
