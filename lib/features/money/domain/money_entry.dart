class MoneyEntry {
  final String person;
  final double amount;
  final String currency;
  final String reason;
  final bool owedToMe;
  final DateTime? dueDate;
  final bool settled;

  const MoneyEntry({
    required this.person,
    required this.amount,
    required this.currency,
    required this.reason,
    required this.owedToMe,
    this.dueDate,
    this.settled = false,
  });
}
