import 'package:flutter/material.dart';

import '../../../core/ai/local_entry_data.dart';

Future<bool> reviewEntrySuggestion(
  BuildContext context,
  LocalEntryData suggestion,
  String currency,
) async {
  final kind = switch (suggestion.kind) {
    'owedToMe' => 'Someone owes me',
    'iOwe' => 'I owe someone',
    'spending' => 'I spent money',
    _ => 'Thing',
  };
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Review suggestion'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kind, style: Theme.of(context).textTheme.titleMedium),
                if (suggestion.person.isNotEmpty) Text(suggestion.person),
                if (suggestion.amount.isNotEmpty)
                  Text('$currency ${suggestion.amount}'),
                const SizedBox(height: 8),
                Text(suggestion.description),
                const SizedBox(height: 16),
                const Text('You can edit these details before saving.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep my text'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Use suggestion'),
            ),
          ],
        ),
      ) ??
      false;
}
