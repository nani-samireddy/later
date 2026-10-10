import 'package:flutter/material.dart';

class MoneyTypePicker extends StatelessWidget {
  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;
  const MoneyTypePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    key: ValueKey(value),
    initialValue: value,
    decoration: const InputDecoration(labelText: 'What kind of money entry?'),
    items: const [
      DropdownMenuItem(value: 'spending', child: Text('I spent money')),
      DropdownMenuItem(value: 'owedToMe', child: Text('Someone owes me')),
      DropdownMenuItem(value: 'iOwe', child: Text('I owe someone')),
    ],
    onChanged: enabled
        ? (value) {
            if (value != null) onChanged(value);
          }
        : null,
  );
}
