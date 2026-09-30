part of 'home_screen.dart';

class _Dashboard extends StatelessWidget {
  final List<ThingRecord> entries;
  final List<MoneyEntry> moneyEntries;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onSearchTap;
  final VoidCallback onOpenUpcoming;
  final VoidCallback onOpenThings;
  final ValueChanged<ThingRecord> onOpenThing;
  final VoidCallback onSettingsTap;
  const _Dashboard({
    required this.entries,
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
      final owedToMe = moneyEntries
          .where((entry) => entry.kind == 'debt' && entry.owedToMe)
          .fold<double>(0, (sum, entry) => sum + entry.amount);
      final owedByMe = moneyEntries
          .where((entry) => entry.kind == 'debt' && !entry.owedToMe)
          .fold<double>(0, (sum, entry) => sum + entry.amount);
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cards = [
                      _SummaryCard(
                        title: 'Owed to you',
                        value: '₹${owedToMe.toStringAsFixed(0)}',
                        icon: Icons.arrow_downward_rounded,
                        tint: Color(0xFFE2F1E7),
                      ),
                      _SummaryCard(
                        title: 'You owe',
                        value: '₹${owedByMe.toStringAsFixed(0)}',
                        icon: Icons.arrow_upward_rounded,
                        tint: Color(0xFFFFEBDD),
                      ),
                    ];
                    if (constraints.maxWidth < 430) {
                      return Column(
                        children: [
                          cards[0],
                          const SizedBox(height: 12),
                          cards[1],
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: cards[0]),
                        const SizedBox(width: 14),
                        Expanded(child: cards[1]),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 30),
                _SectionHeader(
                  title: 'Coming up',
                  action: 'View all',
                  onAction: onOpenUpcoming,
                ),
                const SizedBox(height: 12),
                _UpcomingList(entries: entries, moneyEntries: moneyEntries),
                const SizedBox(height: 26),
                _SectionHeader(
                  title: 'Recently added',
                  action: 'See all',
                  onAction: onOpenThings,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ...entries
                        .where(
                          (entry) =>
                              _matches(entry.title, entry.category, query),
                        )
                        .take(4)
                        .map(
                          (entry) => GestureDetector(
                            onTap: () => onOpenThing(entry),
                            child: _RecentCard(
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
