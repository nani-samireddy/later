import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/money_totals.dart';

/// Embeddable month summaries and dated spending history, separated by currency.
class SpendingHistory extends StatelessWidget {
  final List<MoneyEntry> entries;
  final ValueChanged<MoneyEntry>? onTap;
  const SpendingHistory({super.key, required this.entries, this.onTap});

  @override
  Widget build(BuildContext context) {
    final summaries = summarizeSpendingByMonth(entries);
    final months = summaries.keys.toList()..sort((a, b) => b.compareTo(a));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Spending history'),
        if (months.isEmpty) const Text('No spending recorded yet'),
        for (final month in months) ...[
          ListTile(
            title: Text(
              '${month.year}-${month.month.toString().padLeft(2, '0')}',
            ),
            subtitle: Text(
              summaries[month]!.entries
                  .map((e) => '${e.key} ${e.value.spending.toStringAsFixed(2)}')
                  .join(' · '),
            ),
          ),
          for (final entry
              in (entries
                  .where(
                    (e) =>
                        e.kind == 'spending' &&
                        e.createdAt.year == month.year &&
                        e.createdAt.month == month.month,
                  )
                  .toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt))))
            ListTile(
              title: Text(entry.person),
              subtitle: Text(
                '${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year}${entry.reason.isEmpty ? '' : ' · ${entry.reason}'}',
              ),
              trailing: Text(
                '${entry.currency} ${entry.amount.toStringAsFixed(2)}',
              ),
              onTap: onTap == null ? null : () => onTap!(entry),
            ),
        ],
      ],
    );
  }
}
