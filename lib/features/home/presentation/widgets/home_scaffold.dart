import 'package:flutter/material.dart';

import '../../../capture/presentation/quick_add_menu.dart';

class HomeScaffold extends StatelessWidget {
  final String userName;
  final int selected;
  final PageController pageController;
  final ValueChanged<int> onSelected;
  final Widget Function(int) viewFor;
  final VoidCallback onAdd;
  final bool quickAddOpen;
  final ValueChanged<String>? onQuickAddSelected;
  final VoidCallback onSearch;
  final VoidCallback? onFilter;
  const HomeScaffold({
    super.key,
    this.userName = '',
    this.quickAddOpen = false,
    this.onQuickAddSelected,
    required this.selected,
    required this.pageController,
    required this.onSelected,
    required this.viewFor,
    required this.onAdd,
    required this.onSearch,
    this.onFilter,
  });
  void _select(int index) {
    onSelected(index);
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !quickAddOpen,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop && quickAddOpen) onAdd();
    },
    child: Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mobile = constraints.maxWidth < 700;
            if (mobile) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 12, 16, 0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'later.',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.5,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onSearch,
                          tooltip: 'Search everything',
                          icon: const Icon(Icons.search_rounded, size: 21),
                        ),
                        if (onFilter != null)
                          IconButton(
                            onPressed: onFilter,
                            tooltip: 'Filter',
                            icon: const Icon(
                              Icons.filter_list_rounded,
                              size: 21,
                            ),
                          ),
                        IconButton(
                          tooltip: 'Settings',
                          onPressed: () => _select(4),
                          icon: const CircleAvatar(
                            radius: 17,
                            backgroundColor: Color(0xFFE4EAD9),
                            child: Icon(
                              Icons.person_outline_rounded,
                              size: 18,
                              color: Color(0xFF55644D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'A little space for your day',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7A8373),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                userName.trim().isEmpty
                                    ? 'Hey there'
                                    : 'Hey, ${userName.trim()}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 29,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.emergency_outlined,
                              size: 26,
                              color: Color(0xFFD99763),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBEDE5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              for (var i = 0; i < 4; i++)
                                Expanded(
                                  child: Semantics(
                                    selected: selected == i,
                                    child: TextButton(
                                      onPressed: () => _select(i),
                                      style: TextButton.styleFrom(
                                        backgroundColor: selected == i
                                            ? Colors.white
                                            : Colors.transparent,
                                        foregroundColor: selected == i
                                            ? const Color(0xFF323D35)
                                            : const Color(0xFF7A8373),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        minimumSize: const Size(0, 44),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      child: Text(
                                        [
                                          'Overview',
                                          'Things',
                                          'Money',
                                          'Upcoming',
                                        ][i],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: pageController,
                      onPageChanged: onSelected,
                      itemCount: 5,
                      itemBuilder: (_, index) => viewFor(index),
                    ),
                  ),
                ],
              );
            }
            return Row(
              children: [
                NavigationRail(
                  selectedIndex: selected,
                  onDestinationSelected: (value) => onSelected(value),
                  backgroundColor: Colors.white,
                  extended: MediaQuery.sizeOf(context).width > 900,
                  leading: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDEDE4),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.bookmark_rounded,
                            color: Color(0xFF34725F),
                          ),
                        ),
                        if (MediaQuery.sizeOf(context).width > 900) ...[
                          const SizedBox(width: 10),
                          const Text(
                            'Later',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.inventory_2_outlined),
                      selectedIcon: Icon(Icons.inventory_2_rounded),
                      label: Text('Things'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.account_balance_wallet_outlined),
                      selectedIcon: Icon(Icons.account_balance_wallet_rounded),
                      label: Text('Money'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month_rounded),
                      label: Text('Upcoming'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings_rounded),
                      label: Text('Settings'),
                    ),
                  ],
                ),
                Expanded(child: viewFor(selected)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: QuickAddMenu(
        expanded: quickAddOpen,
        onToggle: onAdd,
        onSelected: onQuickAddSelected,
      ),
    ),
  );
}
