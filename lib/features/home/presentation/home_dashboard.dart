import '../../../core/reminders/reminder_preferences.dart';
import '../../../core/widgets/empty_state.dart';

import 'package:flutter/material.dart';
import 'package:later/core/database/app_database.dart' hide Thing;
import 'package:later/core/utils/search_match.dart';

import '../../things/presentation/widgets/thing_list_tile.dart';

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
  final VoidCallback onOpenMoneySection;
  final ValueChanged<Thing> onCompleteThing;
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
    required this.onOpenMoneySection,
    required this.onCompleteThing,
  });
  @override
  Widget build(BuildContext context) {
    final visible = entries
        .where(
          (entry) =>
              entry.isActive &&
              matchesSearch(entry.title, entry.category, query),
        )
        .take(3)
        .toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 100),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Your things',
                action: 'View all →',
                onAction: onOpenThings,
              ),
              const SizedBox(height: 12),
              if (visible.isEmpty)
                const EmptyState(
                  icon: Icons.eco_outlined,
                  title: 'A little room to remember',
                  body: 'Save a thing now. Come back to it later.',
                ),
              for (final entry in visible)
                ThingListTile(
                  entry: entry,
                  onTap: () => onOpenThing(entry),
                  onCompleted: () => onCompleteThing(entry),
                ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'A little money clarity',
                action: 'View money',
                actionIcon: Icons.north_east_rounded,
                onAction: onOpenMoneySection,
              ),
              const SizedBox(height: 12),
              MoneySummaryCards(
                entries: moneyEntries,
                defaultCurrency: currency,
                showSpending: false,
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Coming up',
                action: 'View all →',
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
            ],
          ),
        ),
      ),
    );
  }
}
