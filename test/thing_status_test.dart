import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/database/app_database.dart' as db;
import 'package:later/core/notifications/reminder_coordinator.dart';
import 'package:later/core/notifications/reminder_scheduler.dart';
import 'package:later/features/home/presentation/home_sections.dart';
import 'package:later/features/things/data/things_repository.dart';
import 'package:later/features/things/presentation/thing_detail_screen.dart';
import 'package:later/features/search/presentation/search_screen.dart';
import 'package:later/features/things/domain/thing.dart';
import 'package:later/features/upcoming/presentation/widgets/upcoming_reminders.dart';

import 'support/fake_reminders.dart';

void main() {
  test('status persists across reopen and preserves content and reminder lifecycle', () async {
    final directory = await Directory.systemTemp.createTemp('later-status');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/records.sqlite');
    var database = db.AppDatabase.withExecutor(NativeDatabase(file));
    final scheduler = FakeReminders();
    var repository = ThingsRepository(database, scheduler: scheduler);
    final id = await database.addThing(
      db.ThingsCompanion.insert(
        title: 'Passport',
        description: const Value('Keep in drawer'),
        category: 'Documents',
        iconCodePoint: Icons.bookmark.codePoint,
        reminderDate: Value(DateTime(2090)),
      ),
    );
    await database.addAttachment(
      db.AttachmentsCompanion.insert(thingId: id, name: 'scan.pdf'),
    );
    await repository.reminders.syncThing(id);
    expect(scheduler.pending, isNotEmpty);
    await repository.setCompleted(id, true);
    expect(scheduler.pending, isEmpty);
    await repository.setArchived(id, true);
    await database.close();
    database = db.AppDatabase.withExecutor(NativeDatabase(file));
    repository = ThingsRepository(database, scheduler: scheduler);
    final archived = (await repository.find(id))!;
    expect(archived.status, ThingStatus.archived);
    expect(archived.completedAt, isNotNull);
    expect(archived.archivedAt, isNotNull);
    expect(archived.description, 'Keep in drawer');
    expect(archived.attachments, ['scan.pdf']);
    await ReminderCoordinator(database, scheduler: scheduler).syncAll();
    expect(scheduler.pending, isEmpty);
    await repository.setArchived(id, false);
    expect((await repository.find(id))!.status, ThingStatus.completed);
    expect(scheduler.pending, isEmpty);
    await repository.setCompleted(id, false);
    expect(scheduler.pending.containsKey(reminderId('thing', id)), isTrue);
    await repository.setArchived(id, true);
    expect(scheduler.pending, isEmpty);
    await repository.setArchived(id, false);
    expect(scheduler.pending, isNotEmpty);
    await repository.setCompleted(id, true);
    await repository.edit(
      id,
      'Passport renewed',
      'Documents',
      reminderDate: DateTime(2091),
    );
    expect(scheduler.pending, isEmpty);
    await repository.setCompleted(id, false);
    expect(scheduler.pending[reminderId('thing', id)]!.date, DateTime(2091));
    await repository.edit(
      id,
      'Passport',
      'Documents',
      reminderDate: DateTime(2000),
    );
    await repository.setArchived(id, true);
    await repository.setArchived(id, false);
    expect(scheduler.pending, isEmpty);
    await database.close();
  });

  test('version 7 migration defaults existing things to active without losing content', () async {
    final directory = await Directory.systemTemp.createTemp('later-migration');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/old.sqlite');
    final database = db.AppDatabase.withExecutor(
      NativeDatabase(
        file,
        setup: (old) {
          old.execute(
            'CREATE TABLE things (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, description TEXT NOT NULL DEFAULT \'\', category TEXT NOT NULL, icon_code_point INTEGER NOT NULL, reminder_date INTEGER)',
          );
          old.execute(
            "INSERT INTO things (title, description, category, icon_code_point) VALUES ('Existing', 'Original description', 'General', 1)",
          );
          old.execute('PRAGMA user_version = 7');
        },
      ),
    );
    addTearDown(database.close);
    final row = (await database.allThings()).single;
    expect(row.status, 'active');
    expect(row.description, 'Original description');
    expect(row.completedAt, isNull);
    expect(row.archivedAt, isNull);
  });

  testWidgets(
    'detail actions refresh status and returning to search reloads records',
    (tester) async {
      final database = db.AppDatabase.withExecutor(NativeDatabase.memory());
      addTearDown(database.close);
      final id = await database.addThing(
        db.ThingsCompanion.insert(
          title: 'Passport',
          category: 'Documents',
          iconCodePoint: Icons.bookmark.codePoint,
        ),
      );
      final repository = ThingsRepository(database);
      final entry = (await repository.find(id))!;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => SearchScreen(
              things: [entry],
              moneyEntries: const [],
              database: database,
              onThingTap: (item) async => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      ThingDetailScreen(entry: item, database: database),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Passport'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark done'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect(find.text('Status: Completed'), findsOneWidget);
      await tester.tap(find.text('Archive'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect(find.text('Status: Archived'), findsOneWidget);
      await tester.tap(find.text('Unarchive'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect(find.text('Status: Completed'), findsOneWidget);
      await tester.pageBack();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect(find.text('Documents · Completed'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('Upcoming includes only active things', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UpcomingReminders(
            entries: ThingStatus.values
                .map(
                  (status) => Thing(
                    title: status.label,
                    category: 'General',
                    icon: Icons.bookmark,
                    status: status,
                    reminderDate: DateTime(2090),
                  ),
                )
                .toList(),
            moneyEntries: const [],
          ),
        ),
      ),
    );
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Completed'), findsNothing);
    expect(find.text('Archived'), findsNothing);
  });

  testWidgets(
    'Things filters history and refreshes the selected view when records reload',
    (tester) async {
      final database = db.AppDatabase.withExecutor(NativeDatabase.memory());
      addTearDown(database.close);
      List<Thing> entries = ThingStatus.values
          .map(
            (status) => Thing(
              title: '${status.label} record',
              category: 'General',
              icon: Icons.bookmark,
              status: status,
            ),
          )
          .toList();
      Future<void> render() => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeSectionPage(
              database: database,
              index: 1,
              entries: entries,
              moneyEntries: const [],
              onMoneyChanged: () async {},
              onThingTap: (_) {},
              query: '',
              onQueryChanged: (_) {},
              onSearchTap: () {},
            ),
          ),
        ),
      );
      await render();
      expect(find.text('Active record'), findsOneWidget);
      expect(find.text('Completed record'), findsNothing);
      await tester.tap(find.byTooltip('Filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Status: Active ▾'));
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
      expect(find.text('Completed record'), findsOneWidget);
      entries = [
        const Thing(
          title: 'Refreshed record',
          category: 'General',
          icon: Icons.bookmark,
          status: ThingStatus.completed,
        ),
      ];
      await render();
      expect(find.text('Refreshed record'), findsOneWidget);
      expect(find.text('Completed record'), findsNothing);
      await tester.tap(find.byTooltip('Filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Status: Completed ▾'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.ancestor(
          of: find.text('Archived'),
          matching: find.byType(CheckedPopupMenuItem<String>),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply filters'));
      await tester.pumpAndSettle();
      expect(find.text('No archived things'), findsOneWidget);
    },
  );
}
