import 'package:flutter/material.dart';

import '../domain/money_entry.dart';

class MoneyListScreen extends StatelessWidget {
  final List<MoneyEntry> entries;
  const MoneyListScreen({super.key, required this.entries});
  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.all(24),
    itemCount: entries.length,
    itemBuilder: (_, index) {
      final entry = entries[index];
      return Card(
        elevation: 0,
        child: ListTile(
          title: Text(entry.person),
          subtitle: Text(entry.reason),
          trailing: Text(
            '${entry.currency} ${entry.amount.toStringAsFixed(0)}',
          ),
        ),
      );
    },
  );
}
