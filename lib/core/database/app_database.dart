import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';
export 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Things,
    Attachments,
    AppSettings,
    MoneyEntries,
    MoneyAttachments,
    MoneyPayments,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.withExecutor(super.executor);
  @override
  int get schemaVersion => 9;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
    onUpgrade: (m, from, to) async {
      if (from < 8) {
        await m.addColumn(things, things.status);
        await m.addColumn(things, things.completedAt);
        await m.addColumn(things, things.archivedAt);
      }
      if (from < 7) await m.addColumn(things, things.description);
      if (from < 2) await m.createTable(moneyEntries);
      if (from < 3) await m.createTable(moneyAttachments);
      if (from < 4) await m.createTable(appSettings);
      if (from >= 2 && from < 5) {
        await m.addColumn(moneyEntries, moneyEntries.kind);
      }
      if (from < 6) {
        await m.addColumn(attachments, attachments.path);
        await m.addColumn(attachments, attachments.kind);
        await customStatement('UPDATE attachments SET path = name');
      }
      if (from < 9) {
        final existingMoney = await customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'money_entries'",
        ).get();
        if (existingMoney.isEmpty) {
          await m.createTable(moneyEntries);
        } else if (from >= 2) {
          await m.addColumn(moneyEntries, moneyEntries.paidAmount);
          // SQLite cannot add a column with a nonconstant timestamp default.
          await customStatement(
            'ALTER TABLE money_entries ADD COLUMN created_at INTEGER NOT NULL DEFAULT 0',
          );
          await customStatement(
            "UPDATE money_entries SET created_at = CAST(strftime('%s', 'now') AS INTEGER)",
          );
        }
        await m.createTable(moneyPayments);
      }
    },
  );

  Future<List<Thing>> allThings() => select(things).get();
  Future<int> addThing(ThingsCompanion thing) => into(things).insert(thing);
  Future<Thing?> thingById(int id) =>
      (select(things)..where((row) => row.id.equals(id))).getSingleOrNull();
  Future<void> updateThing(int id, ThingsCompanion entry) async {
    await (update(things)..where((row) => row.id.equals(id))).write(entry);
  }

  Future<void> deleteThing(int id) => transaction(() async {
    await (delete(attachments)..where((row) => row.thingId.equals(id))).go();
    await (delete(things)..where((row) => row.id.equals(id))).go();
  });
  Future<void> deleteMoney(int id) => transaction(() async {
    await (delete(
      moneyAttachments,
    )..where((row) => row.moneyId.equals(id))).go();
    await (delete(moneyPayments)..where((row) => row.moneyId.equals(id))).go();
    await (delete(moneyEntries)..where((row) => row.id.equals(id))).go();
  });
  Future<void> deleteThingAttachment(int id) async {
    await (delete(attachments)..where((row) => row.id.equals(id))).go();
  }

  Future<void> deleteMoneyAttachment(int id) async {
    await (delete(moneyAttachments)..where((row) => row.id.equals(id))).go();
  }

  Future<int> addAttachment(AttachmentsCompanion attachment) =>
      into(attachments).insert(attachment);
  Future<List<Attachment>> attachmentsFor(int thingId) =>
      (select(attachments)..where((row) => row.thingId.equals(thingId))).get();
  Future<String?> setting(String key) async =>
      (select(appSettings)..where((row) => row.key.equals(key)))
          .getSingleOrNull()
          .then((row) => row?.value);
  Future<void> saveSetting(String key, String value) => into(
    appSettings,
  ).insertOnConflictUpdate(AppSettingsCompanion.insert(key: key, value: value));
  Future<List<MoneyEntry>> allMoney() => select(moneyEntries).get();
  Future<int> addMoney(MoneyEntriesCompanion entry) =>
      into(moneyEntries).insert(
        entry.createdAt.present
            ? entry
            : entry.copyWith(createdAt: Value(DateTime.now())),
      );
  Future<List<MoneyAttachment>> moneyAttachmentsFor(int moneyId) => (select(
    moneyAttachments,
  )..where((row) => row.moneyId.equals(moneyId))).get();
  Future<int> addMoneyAttachment(MoneyAttachmentsCompanion attachment) =>
      into(moneyAttachments).insert(attachment);
  Future<void> updateMoney(int id, MoneyEntriesCompanion entry) async {
    await (update(
      moneyEntries,
    )..where((row) => row.id.equals(id))).write(entry);
  }
}

QueryExecutor _openConnection() => driftDatabase(name: 'later');
