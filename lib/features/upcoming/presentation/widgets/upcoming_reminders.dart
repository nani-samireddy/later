import 'package:flutter/material.dart';
import 'package:later/core/database/app_database.dart' hide Thing;
import 'package:later/core/utils/date_format.dart';
import 'package:later/core/widgets/empty_state.dart';
import 'package:later/core/widgets/reminder_card.dart';
import 'package:later/features/things/domain/thing.dart';

class UpcomingReminders extends StatelessWidget {
  final List<Thing> entries;
  final List<MoneyEntry> moneyEntries;
  const UpcomingReminders({
    super.key,
    required this.entries,
    required this.moneyEntries,
  });
  @override
  Widget build(BuildContext context) {
    final reminders = [
      ...entries
          .where((entry) => entry.reminderDate != null)
          .map(
            (entry) => _UpcomingItem(
              date: entry.reminderDate!,
              title: entry.title,
              subtitle: entry.category,
              icon: Icons.notifications_none_rounded,
            ),
          ),
      ...moneyEntries
          .where((entry) => entry.dueDate != null && !entry.settled)
          .map(
            (entry) => _UpcomingItem(
              date: entry.dueDate!,
              title:
                  '${entry.person} · ${entry.currency} ${entry.amount.toStringAsFixed(0)}',
              subtitle: entry.owedToMe ? 'Money owed to you' : 'Money you owe',
              icon: Icons.account_balance_wallet_rounded,
            ),
          ),
    ]..sort((a, b) => a.date.compareTo(b.date));
    if (reminders.isEmpty) {
      return const EmptyState(
        icon: Icons.event_available_outlined,
        title: 'Your timeline is clear',
        body: 'Dates from your entries will appear here.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: reminders
          .map(
            (item) => ReminderCard(
              icon: item.icon,
              color: const Color(0xFFE5ECF8),
              title: item.title,
              subtitle: '${formatDate(item.date)} · ${item.subtitle}',
            ),
          )
          .toList(),
    );
  }
}

class _UpcomingItem {
  final DateTime date;
  final String title;
  final String subtitle;
  final IconData icon;
  const _UpcomingItem({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
