import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';

class MoneyListTile extends StatelessWidget {
  final MoneyEntry entry;
  final VoidCallback onTap;
  const MoneyListTile({super.key, required this.entry, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    child: ListTile(
      onTap: onTap,
      leading: Icon(
        entry.kind == 'spending'
            ? Icons.shopping_bag_outlined
            : entry.owedToMe
            ? Icons.arrow_downward_rounded
            : Icons.arrow_upward_rounded,
        color: entry.kind == 'spending'
            ? const Color(0xFF5C6BC0)
            : entry.owedToMe
            ? const Color(0xFF34725F)
            : const Color(0xFFC66A3D),
      ),
      title: Text(entry.person),
      subtitle: Text(
        entry.kind == 'spending'
            ? 'Spending${entry.reason.isEmpty ? '' : ' · ${entry.reason}'}'
            : '${entry.settled
                  ? 'Settled · '
                  : entry.paidAmount > 0
                  ? 'Partially repaid · '
                  : ''}${entry.reason}',
      ),
      trailing: Text(
        '${entry.currency} ${(entry.kind == 'debt' && !entry.settled ? entry.amount - entry.paidAmount : entry.amount).toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
  );
}
