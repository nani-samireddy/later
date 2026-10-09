import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/features/home/presentation/widgets/home_scaffold.dart';
import 'package:later/features/things/domain/thing.dart';
import 'package:later/features/upcoming/presentation/widgets/upcoming_reminders.dart';

void main() {
  testWidgets('Upcoming reminders remain in chronological order', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UpcomingReminders(
            entries: [
              Thing(
                title: 'Later reminder',
                category: 'General',
                icon: Icons.bookmark,
                reminderDate: DateTime(2027, 2, 1),
              ),
              Thing(
                title: 'Earlier reminder',
                category: 'General',
                icon: Icons.bookmark,
                reminderDate: DateTime(2027, 1, 1),
              ),
              const Thing(
                title: 'Undated',
                category: 'General',
                icon: Icons.bookmark,
              ),
            ],
            moneyEntries: const [],
          ),
        ),
      ),
    );
    expect(find.text('Undated'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Earlier reminder')).dy,
      lessThan(tester.getTopLeft(find.text('Later reminder')).dy),
    );
  });

  testWidgets('Desktop navigation and capture delegate to home callbacks', (
    tester,
  ) async {
    final controller = PageController();
    addTearDown(controller.dispose);
    var selected = 0;
    var addCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(splashFactory: InkRipple.splashFactory),
        home: HomeScaffold(
          selected: 0,
          pageController: controller,
          onSelected: (value) => selected = value,
          viewFor: (_) => const SizedBox(),
          onAdd: () => addCount++,
        ),
      ),
    );
    expect(find.byType(NavigationRail), findsOneWidget);
    await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
    expect(selected, 2);
    await tester.tap(find.text('Add'));
    expect(addCount, 1);
    await tester.pumpWidget(const SizedBox());
  });
}
