import 'package:drift/drift.dart';

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
