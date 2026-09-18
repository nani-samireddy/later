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
}

@DriftDatabase(tables: [Things, Attachments, AppSettings, MoneyEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  @override
  int get schemaVersion => 2;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from) async {
      if (from < 2) await m.createTable(moneyEntries);
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
}

QueryExecutor _openConnection() => driftDatabase(name: 'later');
