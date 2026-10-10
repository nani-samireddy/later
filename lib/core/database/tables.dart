import 'package:drift/drift.dart';

class Things extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  TextColumn get category => text()();
  IntColumn get iconCodePoint => integer()();
  DateTimeColumn get reminderDate => dateTime().nullable()();
}

class Attachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get thingId =>
      integer().customConstraint('NOT NULL REFERENCES things(id)')();
  TextColumn get name => text()();
  TextColumn get path => text().withDefault(const Constant(''))();
  TextColumn get kind => text().withDefault(const Constant('document'))();
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
  RealColumn get paidAmount => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class MoneyAttachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get moneyId =>
      integer().customConstraint('NOT NULL REFERENCES money_entries(id)')();
  TextColumn get name => text()();
  TextColumn get path => text()();
  TextColumn get kind => text()();
}

class MoneyPayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get moneyId => integer().customConstraint(
    'NOT NULL REFERENCES money_entries(id) ON DELETE CASCADE',
  )();
  RealColumn get amount => real()();
  DateTimeColumn get paidAt => dateTime()();
}
