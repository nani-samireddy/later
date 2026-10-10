import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/database/app_database.dart' as db;
import 'package:later/features/search/domain/entry_filters.dart';
import 'package:later/features/search/presentation/search_screen.dart';
import 'package:later/features/things/domain/thing.dart';

Thing thing(
  int id, {
  ThingStatus status = ThingStatus.active,
  DateTime? date,
}) => Thing(
  id: id,
  title: 'Item $id',
  description: 'Hidden drawer',
  category: 'Tools',
  icon: Icons.build,
  status: status,
  reminderDate: date,
);
db.MoneyEntry money(
  int id,
  double amount, {
  String kind = 'debt',
  bool settled = false,
  bool owed = true,
  DateTime? date,
}) => db.MoneyEntry(
  id: id,
  paidAmount: 0,
  createdAt: DateTime(2026, 10, 10),
  person: 'Person $id',
  amount: amount,
  currency: 'INR',
  reason: 'Lunch',
  owedToMe: owed,
  settled: settled,
  kind: kind,
  dueDate: date,
);
void main() {
  test('description, category, status and inclusive date range combine', () {
    final day = DateTime(2026, 10, 10);
    final entries = [
      thing(1, date: DateTime(2026, 10, 10, 23, 59)),
      thing(2, status: ThingStatus.completed, date: day),
      thing(3),
      thing(4, date: DateTime(2026, 10, 11)),
    ];
    expect(
      EntryFilters(
        query: ' DRAWER ',
        category: 'Tools',
        status: ThingStatus.active,
        start: day,
        end: day,
      ).things(entries).map((e) => e.id),
      [1],
    );
    expect(const EntryFilters(category: 'Other').things(entries), isEmpty);
    expect(
      const EntryFilters(sort: EntrySort.newest).things(entries).first.id,
      4,
    );
    expect(const EntryFilters(sort: EntrySort.date).things(entries).last.id, 3);
    expect(
      const EntryFilters(sort: EntrySort.title).things(entries).first.id,
      1,
    );
  });
  test('money filters combine and sort exact decimal values', () {
    final day = DateTime(2026, 10, 10);
    final entries = [
      money(1, 10.01, date: day),
      money(2, 10.09, date: day),
      money(3, 20, settled: true, date: day),
      money(4, 30, kind: 'spending', date: day),
      money(5, 40, owed: false, date: day),
    ];
    expect(
      EntryFilters(
        query: 'lunch',
        moneyType: MoneyType.owedToMe,
        settled: false,
        start: day,
        end: day,
        sort: EntrySort.amount,
      ).money(entries).map((e) => e.id),
      [2, 1],
    );
    expect(const EntryFilters(query: '10.01').money(entries).single.id, 1);
    expect(
      const EntryFilters(
        moneyType: MoneyType.spending,
        settled: false,
      ).money(entries),
      isEmpty,
    );
    expect(
      const EntryFilters(moneyType: MoneyType.iOwe).money(entries).single.id,
      5,
    );
  });
  testWidgets(
    'search finds descriptions, refreshes after navigation and preserves query',
    (tester) async {
      final database = db.AppDatabase.withExecutor(NativeDatabase.memory());
      addTearDown(database.close);
      await tester.pumpWidget(
        MaterialApp(
          home: SearchScreen(
            things: [thing(1)],
            moneyEntries: [money(1, 10.01)],
            database: database,
            onThingTap: (_) async {},
          ),
        ),
      );
      expect(find.text('INR 10.01'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'drawer');
      await tester.pump();
      expect(find.text('Item 1'), findsOneWidget);
      await tester.tap(find.text('Item 1'));
      await tester.pumpAndSettle();
      expect(find.text('No matching items found'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'drawer',
      );
    },
  );
  testWidgets('filter sheet applies, retains, cancels and resets selections', (
    tester,
  ) async {
    final database = db.AppDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(
      MaterialApp(
        home: SearchScreen(
          things: [
            thing(1),
            thing(2, status: ThingStatus.completed),
          ],
          moneyEntries: const [],
          database: database,
          onThingTap: (_) async {},
        ),
      ),
    );
    expect(find.text('Status: All ▾'), findsNothing);
    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();
    expect(find.text('Search filters'), findsOneWidget);
    await tester.tap(find.text('Status: All ▾'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.ancestor(
        of: find.text('Completed'),
        matching: find.byType(CheckedPopupMenuItem<String>),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply filters'));
    await tester.pumpAndSettle();
    expect(find.text('Item 1'), findsNothing);
    expect(find.text('Item 2'), findsOneWidget);
    await tester.tap(find.text('Filter · active'));
    await tester.pumpAndSettle();
    expect(find.text('Status: Completed ▾'), findsOneWidget);
    await tester.tap(find.text('Reset filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Item 1'), findsNothing);
    await tester.tap(find.text('Filter · active'));
    await tester.pumpAndSettle();
    expect(find.text('Status: Completed ▾'), findsOneWidget);
    await tester.tap(find.text('Reset filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply filters'));
    await tester.pumpAndSettle();
    expect(find.text('Filter'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
  });
}
