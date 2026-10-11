import 'package:flutter/material.dart';

import '../../domain/entry_filters.dart';
import '../../../things/domain/thing.dart';
import 'entry_filter_controls.dart';

Future<EntryFilters?> showEntryFilterSheet(
  BuildContext context, {
  required EntryFilters filters,
  required List<String> categories,
  String title = 'Search filters',
  bool showThings = true,
  bool showMoney = true,
  ThingStatus? resetStatus,
}) {
  var draft = filters;
  return showModalBottomSheet<EntryFilters>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            EntryFilterControls(
              categories: categories,
              initialFilters: filters,
              initialStatus: resetStatus,
              showThings: showThings,
              showMoney: showMoney,
              onChanged: (value) => draft = value,
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 8,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, draft),
                  child: const Text('Apply filters'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
