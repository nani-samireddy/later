import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Things extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get category => text()();
  IntColumn get iconCodePoint => integer()();
  DateTimeColumn get reminderDate => dateTime().nullable()();
}

class Attachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get thingId => integer().references(Things, #id)();
  TextColumn get name => text()();
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

class MoneyEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get person => text()();
  RealColumn get amount => real()();
  TextColumn get currency => text()();
  TextColumn get reason => text().withDefault(const Constant(''))();
  BoolColumn get owedToMe => boolean()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get settled => boolean().withDefault(const Constant(false))();
  TextColumn get kind => text().withDefault(const Constant('debt'))();
}

class MoneyAttachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get moneyId => integer().references(MoneyEntries, #id)();
  TextColumn get name => text()();
  TextColumn get path => text()();
  TextColumn get kind => text()();
}

@DriftDatabase(
  tables: [Things, Attachments, AppSettings, MoneyEntries, MoneyAttachments],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  @override
  int get schemaVersion => 5;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(moneyEntries);
      if (from < 3) await m.createTable(moneyAttachments);
      if (from < 4) await m.createTable(appSettings);
      if (from < 5) await m.addColumn(moneyEntries, moneyEntries.kind);
    },
  );

  Future<List<Thing>> allThings() => select(things).get();
  Future<int> addThing(ThingsCompanion thing) => into(things).insert(thing);
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
      into(moneyEntries).insert(entry);
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
