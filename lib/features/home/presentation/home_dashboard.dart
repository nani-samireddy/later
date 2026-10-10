import '../../../core/reminders/reminder_preferences.dart';
import '../../../core/widgets/empty_state.dart';

import 'package:flutter/material.dart';
import 'package:later/core/database/app_database.dart' hide Thing;
import 'package:later/core/utils/search_match.dart';
import 'package:later/core/widgets/recent_card.dart';
import 'package:later/core/widgets/section_header.dart';

import '../../money/presentation/widgets/money_summary_cards.dart';

import 'package:later/features/things/domain/thing.dart';
import 'package:later/features/upcoming/presentation/widgets/upcoming_reminders.dart';

class HomeDashboard extends StatelessWidget {
  final ValueChanged<MoneyEntry> onOpenMoney;
  final String currency;
  final List<Thing> entries;
  final Map<String, ReminderPreferences> reminderPreferences;
  final List<MoneyEntry> moneyEntries;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onSearchTap;
  final VoidCallback onOpenUpcoming;
  final VoidCallback onOpenThings;
  final ValueChanged<Thing> onOpenThing;
  final VoidCallback onSettingsTap;
  const HomeDashboard({
    super.key,
    required this.currency,
    required this.onOpenMoney,
    required this.entries,
    this.reminderPreferences = const {},
    required this.moneyEntries,
    required this.query,
    required this.onQueryChanged,
    required this.onSearchTap,
    required this.onOpenUpcoming,
    required this.onOpenThings,
    required this.onOpenThing,
    required this.onSettingsTap,
  });
  @override
  Widget build(BuildContext context) => Builder(
    builder: (context) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(34, 30, 34, 110),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final heading = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good morning',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'What should you know\nright now?',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            height: 1.05,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    );
                    final actions = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: onSearchTap,
                          icon: const Icon(Icons.search_rounded, size: 28),
                        ),
                        IconButton(
                          onPressed: onSettingsTap,
                          icon: const Icon(Icons.settings_outlined, size: 25),
                        ),
                      ],
                    );
                    return constraints.maxWidth < 420
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              heading,
                              Align(
                                alignment: Alignment.centerRight,
                                child: actions,
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [heading, actions],
                          );
                  },
                ),
                const SizedBox(height: 28),
                MoneySummaryCards(
                  entries: moneyEntries,
                  defaultCurrency: currency,
                ),
                const SizedBox(height: 30),
                SectionHeader(
                  title: 'Coming up',
                  action: 'View all',
                  onAction: onOpenUpcoming,
                ),
                const SizedBox(height: 12),
                UpcomingReminders(
                  preferences: reminderPreferences,
                  entries: entries,
                  moneyEntries: moneyEntries,
                  onThingTap: onOpenThing,
                  onMoneyTap: onOpenMoney,
                ),
                const SizedBox(height: 26),
                SectionHeader(
                  title: 'Recently added',
                  action: 'See all',
                  onAction: onOpenThings,
                ),
                const SizedBox(height: 12),
                if (!entries.any((entry) => entry.isActive))
                  const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'Nothing saved yet',
                    body: 'Tap Add to save your first item.',
                  ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ...entries
                        .where(
                          (entry) =>
                              entry.isActive &&
                              matchesSearch(entry.title, entry.category, query),
                        )
                        .take(4)
                        .map(
                          (entry) => GestureDetector(
                            onTap: () => onOpenThing(entry),
                            child: RecentCard(
                              icon: entry.icon,
                              title: entry.title,
                              detail: entry.category,
                            ),
                          ),
                        ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
