import 'package:flutter/material.dart';

class HomeScaffold extends StatelessWidget {
  final int selected;
  final PageController pageController;
  final ValueChanged<int> onSelected;
  final Widget Function(int) viewFor;
  final VoidCallback onAdd;
  const HomeScaffold({
    super.key,
    required this.selected,
    required this.pageController,
    required this.onSelected,
    required this.viewFor,
    required this.onAdd,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = constraints.maxWidth < 700;
          if (mobile) {
            return PageView.builder(
              controller: pageController,
              onPageChanged: (value) => onSelected(value),
              itemCount: 5,
              itemBuilder: (_, index) => viewFor(index),
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
    bottomNavigationBar: MediaQuery.sizeOf(context).width < 700
        ? NavigationBar(
            selectedIndex: selected < 4 ? selected : 0,
            onDestinationSelected: (value) {
              onSelected(value);
              pageController.animateToPage(
                value,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
              );
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2_rounded),
                label: 'Things',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet_rounded),
                label: 'Money',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month_rounded),
                label: 'Upcoming',
              ),
            ],
          )
        : null,
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => onAdd(),
      backgroundColor: const Color(0xFF34725F),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add', style: TextStyle(fontWeight: FontWeight.w700)),
    ),
  );
}
