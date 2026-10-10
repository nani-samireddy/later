import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/summary_card.dart';
import '../../domain/money_totals.dart';

class MoneySummaryCards extends StatelessWidget {
  final List<MoneyEntry> entries;
  final String defaultCurrency;
  final bool showSpending;
  const MoneySummaryCards({
    super.key,
    required this.entries,
    required this.defaultCurrency,
    this.showSpending = true,
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
              const Color(0xFFEAF0E0),
            ),
            _card(
              constraints,
              'You owe',
              currency,
              totals[currency]!.youOwe,
              Icons.arrow_upward_rounded,
              const Color(0xFFF6E8D9),
            ),
            if (showSpending)
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
    width: constraints.maxWidth < 240
        ? constraints.maxWidth
        : (constraints.maxWidth -
                  (showSpending && constraints.maxWidth >= 600 ? 24 : 12)) /
              (showSpending && constraints.maxWidth >= 600 ? 3 : 2),
    child: SummaryCard(
      title: title,
      value: '$currency ${amount.toStringAsFixed(2)}',
      icon: icon,
      tint: tint,
    ),
  );
}
