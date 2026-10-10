import 'package:flutter/material.dart';
import 'package:later/core/database/app_database.dart' hide Thing;
import 'package:later/core/utils/date_format.dart';
import 'package:later/core/widgets/empty_state.dart';
import 'package:later/core/widgets/reminder_card.dart';
import 'package:later/core/reminders/reminder_preferences.dart';
import 'package:later/features/things/domain/thing.dart';

class UpcomingReminders extends StatelessWidget {
  final ValueChanged<Thing>? onThingTap;
  final ValueChanged<MoneyEntry>? onMoneyTap;
  final DateTime? now;
  final Map<String, ReminderPreferences> preferences;
  final List<Thing> entries;
  final List<MoneyEntry> moneyEntries;
  const UpcomingReminders({
    super.key,
    this.onThingTap,
    this.now,
    this.preferences = const {},
    this.onMoneyTap,
    required this.entries,
    required this.moneyEntries,
  });
  @override
  Widget build(BuildContext context) {
    final clock = now ?? DateTime.now();
    final reminders = [
      ...entries
          .where((entry) => entry.isActive && entry.reminderDate != null)
          .map(
            (entry) => _UpcomingItem(
              onTap: onThingTap == null ? null : () => onThingTap!(entry),
              date: entry.reminderDate!,
              title: entry.title,
              subtitle: _subtitle('thing', entry.id, entry.category, clock),
              icon: Icons.notifications_none_rounded,
            ),
          ),
      ...moneyEntries
          .where(
            (entry) =>
                entry.dueDate != null &&
                (entry.kind != 'spending' || entry.dueDate!.isAfter(clock)) &&
                !entry.settled &&
                (entry.kind != 'debt' || entry.amount > entry.paidAmount),
          )
          .map(
            (entry) => _UpcomingItem(
              onTap: onMoneyTap == null ? null : () => onMoneyTap!(entry),
              date: entry.dueDate!,
              title:
                  '${entry.person} · ${entry.currency} ${(entry.kind == 'debt' ? (entry.amount - entry.paidAmount).clamp(0, entry.amount) : entry.amount).toStringAsFixed(2)}',
              subtitle: _subtitle(
                'money',
                entry.id,
                entry.kind == 'spending'
                    ? 'Spending'
                    : entry.owedToMe
                    ? 'Money owed to you'
                    : 'Money you owe',
                clock,
              ),
              icon: Icons.account_balance_wallet_rounded,
              canBeOverdue: entry.kind != 'spending',
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
    final overdue = reminders
        .where((item) => !item.date.isAfter(clock) && item.canBeOverdue)
        .toList();
    final upcoming = reminders
        .where((item) => item.date.isAfter(clock) || !item.canBeOverdue)
        .toList();
    Widget section(
      String title,
      List<_UpcomingItem> items,
      bool late,
    ) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Text(
            '$title (${items.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ...items.map(
          (item) => ReminderCard(
            onTap: item.onTap,
            icon: item.icon,
            color: late ? const Color(0xFFFFE8DE) : const Color(0xFFE5ECF8),
            title: item.title,
            subtitle:
                '${late ? 'Overdue · ' : ''}${formatDate(item.date)} ${TimeOfDay.fromDateTime(item.date).format(context)} · ${item.subtitle}',
          ),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (overdue.isNotEmpty) section('Overdue', overdue, true),
        if (upcoming.isNotEmpty) section('Upcoming', upcoming, false),
      ],
    );
  }

  String _subtitle(String type, int id, String label, DateTime clock) {
    final policy = preferences['$type:$id'];
    if (policy == null) return label;
    final parts = [label];
    if (policy.recurrence.name != 'none') parts.add(policy.recurrence.label);
    if (policy.snoozedUntil?.isAfter(clock) == true) {
      parts.add('Snoozed until ${formatDate(policy.snoozedUntil!)}');
    }
    return parts.join(' · ');
  }
}

class _UpcomingItem {
  final VoidCallback? onTap;
  final bool canBeOverdue;
  final DateTime date;
  final String title;
  final String subtitle;
  final IconData icon;
  const _UpcomingItem({
    this.onTap,
    this.canBeOverdue = true,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
