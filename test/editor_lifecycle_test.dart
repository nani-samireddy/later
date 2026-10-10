import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/database/app_database.dart' as db;
import 'package:later/features/things/domain/thing.dart';
import 'package:later/features/things/presentation/thing_detail_screen.dart';
import 'package:later/features/money/presentation/dialogs/edit_money_dialog.dart';

void main() {
  testWidgets('Thing editor controllers live through the closing animation', (
    tester,
  ) async {
    final database = db.AppDatabase.withExecutor(NativeDatabase.memory());
    await tester.pumpWidget(
      MaterialApp(
        home: ThingDetailScreen(
          entry: Thing(
            id: 1,
            title: 'Passport',
            category: 'General',
            icon: Icons.bookmark,
          ),
          database: database,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Edited');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await database.close();
  });

  testWidgets('Money editor controllers live through the closing animation', (
    tester,
  ) async {
    final database = db.AppDatabase.withExecutor(NativeDatabase.memory());
    final id = await database.addMoney(
      db.MoneyEntriesCompanion.insert(
        person: 'Sam',
        currency: 'USD',
        amount: 10,
        owedToMe: true,
      ),
    );
    final entry = (await database.allMoney()).singleWhere((e) => e.id == id);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showEditMoneyDialog(
                context,
                entry: entry,
                database: database,
              ),
              child: const Text('Edit'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Edited');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await database.close();
  });
}
