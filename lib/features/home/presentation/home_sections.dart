import '../../../core/reminders/reminder_preferences.dart';
import '../../money/presentation/widgets/money_list_tile.dart';
import '../../money/presentation/widgets/spending_history.dart';

import 'package:flutter/material.dart';
import 'package:later/core/database/app_database.dart' hide Thing;

import '../../search/domain/entry_filters.dart';
import '../../search/presentation/widgets/entry_filter_controls.dart';

import 'package:later/core/widgets/empty_state.dart';
import 'package:later/features/money/presentation/money_detail_screen.dart';
import 'package:later/features/things/domain/thing.dart';
import 'package:later/features/things/presentation/widgets/thing_list_tile.dart';
import 'package:later/features/upcoming/presentation/widgets/upcoming_reminders.dart';

class HomeSectionPage extends StatefulWidget {
  final AppDatabase database;
  final ValueChanged<Thing> onThingTap;
  final int index;
  final List<Thing> entries;
  final Map<String, ReminderPreferences> reminderPreferences;
  final List<MoneyEntry> moneyEntries;
  final Future<void> Function() onMoneyChanged;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onSearchTap;
  const HomeSectionPage({
    super.key,
    required this.database,
    required this.onThingTap,
    required this.index,
    required this.entries,
    this.reminderPreferences = const {},
    required this.moneyEntries,
    required this.onMoneyChanged,
    required this.query,
    required this.onQueryChanged,
    required this.onSearchTap,
  });
  @override
  State<HomeSectionPage> createState() => _HomeSectionPageState();
}

class _HomeSectionPageState extends State<HomeSectionPage> {
  EntryFilters filters = const EntryFilters(status: ThingStatus.active);
  @override
  void didUpdateWidget(covariant HomeSectionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      filters = const EntryFilters(status: ThingStatus.active);
    }
  }

  AppDatabase get database => widget.database;
  ValueChanged<Thing> get onThingTap => widget.onThingTap;
  int get index => widget.index;
  List<Thing> get entries => widget.entries;
  List<MoneyEntry> get moneyEntries => widget.moneyEntries;
  Future<void> Function() get onMoneyChanged => widget.onMoneyChanged;
  String get query => widget.query;
  VoidCallback get onSearchTap => widget.onSearchTap;
  @override
  Widget build(BuildContext context) {
    final current = EntryFilters(
      query: query,
      category: filters.category,
      status: filters.status,
      moneyType: filters.moneyType,
      settled: filters.settled,
      start: filters.start,
      end: filters.end,
      sort: filters.sort,
    );
    final visible = current.things(entries);
    final visibleMoney = current.money(moneyEntries);
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
                tooltip: 'Search everything',
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
                EntryFilterControls(
                  key: const ValueKey('things-filters'),
                  categories: (entries.map((e) => e.category).toSet().toList()
                    ..sort()),
                  showMoney: false,
                  initialStatus: ThingStatus.active,
                  onChanged: (value) => setState(() => filters = value),
                ),
                const SizedBox(height: 16),
                Text(
                  '${visible.length} ${filters.status?.label.toLowerCase() ?? 'matching'} items',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                if (visible.isEmpty)
                  EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title:
                        'No ${filters.status?.label.toLowerCase() ?? 'matching'} things',
                    body: 'Items in this state will appear here.',
                  ),
                ...visible.map(
                  (entry) => ThingListTile(
                    entry: entry,
                    onTap: () => onThingTap(entry),
                  ),
                ),
              ],
            )
          else if (index == 2)
            Column(
              children: [
                EntryFilterControls(
                  key: const ValueKey('money-filters'),
                  categories: const [],
                  showThings: false,
                  onChanged: (value) => setState(() => filters = value),
                ),
                if (visibleMoney.isEmpty)
                  const EmptyState(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'No matching transactions',
                    body: 'Try changing your search or filters.',
                  ),
                if (filters.moneyType == MoneyType.spending &&
                    filters.sort == EntrySort.newest)
                  SpendingHistory(
                    entries: visibleMoney,
                    onTap: (entry) async {
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
                  )
                else
                  ...visibleMoney.map(
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
                  ),
              ],
            )
          else if (index == 3)
            UpcomingReminders(
              preferences: widget.reminderPreferences,
              entries: entries,
              moneyEntries: moneyEntries,
              onThingTap: onThingTap,
              onMoneyTap: (entry) async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MoneyDetailScreen(entry: entry, database: database),
                  ),
                );
                await onMoneyChanged();
              },
            )
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
