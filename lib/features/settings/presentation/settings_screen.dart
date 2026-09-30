import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final String currency;
  final ValueChanged<String> onCurrencyChanged;
  const SettingsScreen({
    super.key,
    required this.currency,
    required this.onCurrencyChanged,
  });
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      ListTile(
        title: const Text('Default currency'),
        subtitle: const Text('Used for new money entries'),
        trailing: DropdownButton<String>(
          value: currency,
          items: const [
            DropdownMenuItem(value: 'INR', child: Text('₹ INR')),
            DropdownMenuItem(value: 'USD', child: Text('\$ USD')),
            DropdownMenuItem(value: 'EUR', child: Text('€ EUR')),
          ],
          onChanged: (value) {
            if (value != null) onCurrencyChanged(value);
          },
        ),
      ),
    ],
  );
}
