import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/database/app_database.dart';
import 'package:later/features/money/domain/money_totals.dart';
import 'package:later/features/money/domain/amount.dart';
import 'package:later/features/capture/domain/entry_validation.dart';

MoneyEntry entry(
  int id,
  double amount,
  String currency, {
  bool owedToMe = true,
  bool settled = false,
  String kind = 'debt',
}) => MoneyEntry(
  id: id,
  paidAmount: 0,
  createdAt: DateTime(2026, 1, 1),
  person: 'Ravi',
  amount: amount,
  currency: currency,
  reason: '',
  owedToMe: owedToMe,
  settled: settled,
  kind: kind,
);
void main() {
  test('Totals separate currencies, spending and unsettled debts', () {
    final totals = summarizeMoney([
      entry(1, 100, 'INR'),
      entry(2, 40, 'INR', owedToMe: false),
      entry(3, 500, 'INR', settled: true),
      entry(4, 20, 'USD'),
      entry(5, 15, 'INR', kind: 'spending'),
      entry(6, 50, 'INR', settled: true, owedToMe: false),
    ]);
    expect(totals['INR']!.owedToYou, 100);
    expect(totals['INR']!.youOwe, 40);
    expect(totals['INR']!.spending, 15);
    expect(totals['USD']!.owedToYou, 20);
  });
  test('Amounts reject invalid, nonfinite, nonpositive and excess precision values', () {
    for (final invalid in ['', 'NaN', 'Infinity', '-5', '0', '1.234', '1e20']) {
      expect(parseAmount(invalid), isNull);
    }
    expect(parseAmount(' 500.25 '), 500.25);
    expect(parseAmount('0.01'), .01);
  });
  test('Entry validation requires a thing title or debt person, with optional spending merchant/reason', () {
    expect(
      validateEntry(kind: 'thing', description: '', person: '', amount: ''),
      isNotNull,
    );
    expect(
      validateEntry(kind: 'owedToMe', description: '', person: '', amount: '5'),
      isNotNull,
    );
    expect(
      validateEntry(kind: 'spending', description: '', person: '', amount: '5'),
      isNull,
    );
    expect(
      validateEntry(
        kind: 'owedToMe',
        description: '',
        person: 'Ravi',
        amount: '5',
      ),
      isNull,
    );
  });
}
