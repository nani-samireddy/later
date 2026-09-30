part of 'home_screen.dart';

class _SectionPage extends StatelessWidget {
  final int index;
  final List<ThingRecord> entries;
  final List<MoneyEntry> moneyEntries;
  final Future<void> Function() onMoneyChanged;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onSearchTap;
  const _SectionPage({
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
                    _Pill(label: 'Appliances', icon: Icons.kitchen_outlined),
                    _Pill(label: 'Documents', icon: Icons.description_outlined),
                    _Pill(label: 'Medicines', icon: Icons.medication_outlined),
                    _Pill(label: 'Tools', icon: Icons.handyman_outlined),
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
                      (entry) => _matches(entry.title, entry.category, query),
                    )
                    .map((entry) => _ThingRecordListTile(entry: entry)),
              ],
            )
          else if (index == 2)
            moneyEntries.isEmpty
                ? const _EmptyState(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'No transactions yet',
                    body: 'Add money you owe or money owed to you.',
                  )
                : Column(
                    children: moneyEntries
                        .where(
                          (entry) =>
                              _matches(entry.person, entry.reason, query),
                        )
                        .map(
                          (entry) => Card(
                            elevation: 0,
                            color: Colors.white,
                            child: ListTile(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MoneyDetailScreen(
                                      entry: entry,
                                      database: appDatabase,
                                    ),
                                  ),
                                );
                                await onMoneyChanged();
                              },
                              leading: Icon(
                                entry.kind == 'spending'
                                    ? Icons.shopping_bag_outlined
                                    : entry.owedToMe
                                    ? Icons.arrow_downward_rounded
                                    : Icons.arrow_upward_rounded,
                                color: entry.kind == 'spending'
                                    ? const Color(0xFF5C6BC0)
                                    : entry.owedToMe
                                    ? const Color(0xFF34725F)
                                    : const Color(0xFFC66A3D),
                              ),
                              title: Text(entry.person),
                              subtitle: Text(
                                entry.kind == 'spending'
                                    ? 'Spending${entry.reason.isEmpty ? '' : ' · ${entry.reason}'}'
                                    : entry.reason,
                              ),
                              trailing: Text(
                                '${entry.currency} ${entry.amount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  )
          else if (index == 3)
            _UpcomingList(entries: entries, moneyEntries: moneyEntries)
          else
            const _EmptyState(
              icon: Icons.event_available_outlined,
              title: 'Your timeline is clear',
              body: 'Dates from your entries will appear here.',
            ),
        ],
      ),
    );
  }
}

bool _matches(String first, String second, String query) {
  final normalized = query.trim().toLowerCase();
  return normalized.isEmpty ||
      first.toLowerCase().contains(normalized) ||
      second.toLowerCase().contains(normalized);
}
