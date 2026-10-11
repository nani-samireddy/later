import 'package:flutter/material.dart';

class QuickAddMenu extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<String>? onSelected;

  const QuickAddMenu({
    super.key,
    required this.expanded,
    required this.onToggle,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      AnimatedSize(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        alignment: Alignment.bottomRight,
        child: expanded
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final action in <(String, IconData)>[
                    ('Photo', Icons.photo_camera_outlined),
                    ('Voice', Icons.mic_none),
                    ('List', Icons.checklist),
                    ('Text', Icons.text_fields),
                    ('Money', Icons.account_balance_wallet_outlined),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: FilledButton.icon(
                        onPressed: () => onSelected?.call(action.$1),
                        icon: Icon(action.$2),
                        label: Text(action.$1),
                        style: FilledButton.styleFrom(
                          elevation: 3,
                          minimumSize: const Size(148, 48),
                        ),
                      ),
                    ),
                ],
              )
            : const SizedBox.shrink(),
      ),
      FloatingActionButton(
        onPressed: onToggle,
        backgroundColor: const Color(0xFF323D35),
        foregroundColor: Colors.white,
        tooltip: expanded ? 'Close quick add' : 'Add',
        shape: const CircleBorder(),
        child: AnimatedRotation(
          turns: expanded ? 0.125 : 0,
          duration: const Duration(milliseconds: 180),
          child: const Icon(Icons.add_rounded),
        ),
      ),
    ],
  );
}
