import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/summary_card.dart';
import '../../domain/money_totals.dart';

class MoneySummaryCards extends StatelessWidget {
  final List<MoneyEntry> entries;
  final String defaultCurrency;
  const MoneySummaryCards({
    super.key,
    required this.entries,
    required this.defaultCurrency,
  });
  @override
  Widget build(BuildContext context) {
    final totals = summarizeMoney(entries);
    if (totals.isEmpty) totals[defaultCurrency] = const MoneyTotals();
    final currencies = totals.keys.toList()..sort();
    return LayoutBuilder(
      builder: (context, constraints) => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final currency in currencies) ...[
            _card(
              constraints,
              'Owed to you',
              currency,
              totals[currency]!.owedToYou,
              Icons.arrow_downward_rounded,
              const Color(0xFFE2F1E7),
            ),
            _card(
              constraints,
              'You owe',
              currency,
              totals[currency]!.youOwe,
              Icons.arrow_upward_rounded,
              const Color(0xFFFFEBDD),
            ),
            _card(
              constraints,
              'Spending',
              currency,
              totals[currency]!.spending,
              Icons.shopping_bag_outlined,
              const Color(0xFFE5ECF8),
            ),
          ],
        ],
      ),
    );
  }

  Widget _card(
    BoxConstraints constraints,
    String title,
    String currency,
    double amount,
    IconData icon,
    Color tint,
  ) => SizedBox(
    width: constraints.maxWidth < 600
        ? constraints.maxWidth
        : (constraints.maxWidth - 24) / 3,
    child: SummaryCard(
      title: title,
      value: '$currency ${amount.toStringAsFixed(2)}',
      icon: icon,
      tint: tint,
    ),
  );
}
