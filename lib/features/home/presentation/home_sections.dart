import '../../money/presentation/widgets/money_list_tile.dart';

import 'package:flutter/material.dart';
import 'package:later/core/database/app_database.dart' hide Thing;
import 'package:later/core/utils/search_match.dart';
import 'package:later/core/widgets/category_pill.dart';
import 'package:later/core/widgets/empty_state.dart';
import 'package:later/features/money/presentation/money_detail_screen.dart';
import 'package:later/features/things/domain/thing.dart';
import 'package:later/features/things/presentation/widgets/thing_list_tile.dart';
import 'package:later/features/upcoming/presentation/widgets/upcoming_reminders.dart';

class HomeSectionPage extends StatelessWidget {
  final AppDatabase database;
  final int index;
  final List<Thing> entries;
  final List<MoneyEntry> moneyEntries;
  final Future<void> Function() onMoneyChanged;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onSearchTap;
  const HomeSectionPage({
    super.key,
    required this.database,
    required this.index,
    required this.entries,
    required this.moneyEntries,
    required this.onMoneyChanged,
    required this.query,
    required this.onQueryChanged,
    required this.onSearchTap,
  });
  @override
  Widget build(BuildContext context) {
    final title = ['Home', 'Things', 'Money', 'Upcoming'][index];
    final copy = index == 1
        ? 'Everything you want to find again.'
        : index == 2
        ? 'Keep track of what matters, simply.'
        : 'One timeline for everything with a date.';
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(36, 36, 36, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed: onSearchTap,
                icon: const Icon(Icons.search_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(copy, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 30),
          if (index == 1)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    CategoryPill(
                      label: 'Appliances',
                      icon: Icons.kitchen_outlined,
                    ),
                    CategoryPill(
                      label: 'Documents',
                      icon: Icons.description_outlined,
                    ),
                    CategoryPill(
                      label: 'Medicines',
                      icon: Icons.medication_outlined,
                    ),
                    CategoryPill(label: 'Tools', icon: Icons.handyman_outlined),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  '${entries.length} items',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...entries
                    .where(
                      (entry) =>
                          matchesSearch(entry.title, entry.category, query),
                    )
                    .map((entry) => ThingListTile(entry: entry)),
              ],
            )
          else if (index == 2)
            moneyEntries.isEmpty
                ? const EmptyState(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'No transactions yet',
                    body: 'Add money you owe or money owed to you.',
                  )
                : Column(
                    children: moneyEntries
                        .where(
                          (entry) =>
                              matchesSearch(entry.person, entry.reason, query),
                        )
                        .map(
                          (entry) => MoneyListTile(
                            entry: entry,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MoneyDetailScreen(
                                    entry: entry,
                                    database: database,
                                  ),
                                ),
                              );
                              await onMoneyChanged();
                            },
                          ),
                        )
                        .toList(),
                  )
          else if (index == 3)
            UpcomingReminders(entries: entries, moneyEntries: moneyEntries)
          else
            const EmptyState(
              icon: Icons.event_available_outlined,
              title: 'Your timeline is clear',
              body: 'Dates from your entries will appear here.',
            ),
        ],
      ),
    );
  }
}
