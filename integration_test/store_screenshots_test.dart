import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:later/core/database/app_database.dart' as db;
import 'package:later/core/theme/app_theme.dart';
import 'package:later/features/home/presentation/home_dashboard.dart';
import 'package:later/features/home/presentation/home_sections.dart';
import 'package:later/features/home/presentation/widgets/home_scaffold.dart';
import 'package:later/features/things/domain/thing.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('capture real app screens with isolated illustrative data', (
    tester,
  ) async {
    final database = db.AppDatabase.withExecutor(NativeDatabase.memory());
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 8);
    final things = [
      Thing(
        id: 1,
        title: 'Water the balcony plants',
        category: 'Home',
        icon: Icons.eco_outlined,
        reminderDate: tomorrow,
        description: 'A little care for the plants on the balcony.',
      ),
      Thing(
        id: 2,
        title: 'Passport renewal',
        category: 'Personal',
        icon: Icons.description_outlined,
        reminderDate: tomorrow.add(const Duration(days: 7)),
        description: 'Check the renewal checklist and book an appointment.',
      ),
    ];
    db.MoneyEntry money(
      int id,
      String person,
      double amount,
      String reason, {
      bool owed = true,
      String kind = 'debt',
    }) => db.MoneyEntry(
      id: id,
      person: person,
      amount: amount,
      currency: 'INR',
      reason: reason,
      owedToMe: owed,
      settled: false,
      kind: kind,
      paidAmount: 0,
      createdAt: now,
      dueDate: kind == 'debt' ? tomorrow.add(const Duration(hours: 9)) : null,
    );
    final entries = [
      money(1, 'Alex', 2400, 'Weekend tickets'),
      money(2, 'Taylor', 850, 'Dinner together', owed: false),
      money(3, 'Groceries', 620, 'Weekly essentials', kind: 'spending'),
    ];
    try {
      await binding.convertFlutterSurfaceToImage();
      for (var index = 0; index < 4; index++) {
        final page = PageController(initialPage: index);
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            debugShowCheckedModeBanner: false,
            home: HomeScaffold(
              selected: index,
              pageController: page,
              onSelected: (_) {},
              onAdd: () {},
              onSearch: () {},
              viewFor: (i) => i == 0
                  ? HomeDashboard(
                      currency: 'INR',
                      entries: things,
                      moneyEntries: entries,
                      query: '',
                      onQueryChanged: (_) {},
                      onSearchTap: () {},
                      onOpenUpcoming: () {},
                      onOpenThings: () {},
                      onOpenThing: (_) {},
                      onSettingsTap: () {},
                      onOpenMoney: (_) {},
                      onOpenMoneySection: () {},
                      onCompleteThing: (_) {},
                    )
                  : HomeSectionPage(
                      database: database,
                      index: i,
                      currency: 'INR',
                      entries: things,
                      moneyEntries: entries,
                      onThingTap: (_) {},
                      onMoneyChanged: () async {},
                      query: '',
                      onQueryChanged: (_) {},
                      onSearchTap: () {},
                    ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await binding.takeScreenshot(
          [
            'phone-01-overview',
            'phone-02-things',
            'phone-03-money',
            'phone-04-reminders',
          ][index],
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        page.dispose();
      }
    } finally {
      await database.close();
    }
  });
}
