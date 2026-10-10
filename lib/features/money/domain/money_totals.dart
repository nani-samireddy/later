import '../../../core/database/app_database.dart';

class MoneyTotals {
  final double owedToYou, youOwe, spending;
  const MoneyTotals({this.owedToYou = 0, this.youOwe = 0, this.spending = 0});
}

Map<String, MoneyTotals> summarizeMoney(List<MoneyEntry> entries) {
  final result = <String, MoneyTotals>{};
  for (final entry in entries) {
    if (!entry.amount.isFinite || entry.amount <= 0) continue;
    final current = result[entry.currency] ?? const MoneyTotals();
    result[entry.currency] = MoneyTotals(
      owedToYou:
          current.owedToYou +
          (entry.kind == 'debt' && entry.owedToMe && !entry.settled
              ? (entry.amount - entry.paidAmount).clamp(0, entry.amount)
              : 0),
      youOwe:
          current.youOwe +
          (entry.kind == 'debt' && !entry.owedToMe && !entry.settled
              ? (entry.amount - entry.paidAmount).clamp(0, entry.amount)
              : 0),
      spending:
          current.spending + (entry.kind == 'spending' ? entry.amount : 0),
    );
  }
  return result;
}

Map<DateTime, Map<String, MoneyTotals>> summarizeSpendingByMonth(
  List<MoneyEntry> entries,
) {
  final months = <DateTime, List<MoneyEntry>>{};
  for (final entry in entries.where((e) => e.kind == 'spending')) {
    final month = DateTime(entry.createdAt.year, entry.createdAt.month);
    months.putIfAbsent(month, () => []).add(entry);
  }
  return {
    for (final month in months.keys) month: summarizeMoney(months[month]!),
  };
}
