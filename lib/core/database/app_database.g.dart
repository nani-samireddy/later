// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ThingsTable extends Things with TableInfo<$ThingsTable, Thing> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodePointMeta = const VerificationMeta(
    'iconCodePoint',
  );
  @override
  late final GeneratedColumn<int> iconCodePoint = GeneratedColumn<int>(
    'icon_code_point',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderDateMeta = const VerificationMeta(
    'reminderDate',
  );
  @override
  late final GeneratedColumn<DateTime> reminderDate = GeneratedColumn<DateTime>(
    'reminder_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    category,
    iconCodePoint,
    reminderDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'things';
  @override
  VerificationContext validateIntegrity(
    Insertable<Thing> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('icon_code_point')) {
      context.handle(
        _iconCodePointMeta,
        iconCodePoint.isAcceptableOrUnknown(
          data['icon_code_point']!,
          _iconCodePointMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_iconCodePointMeta);
    }
    if (data.containsKey('reminder_date')) {
      context.handle(
        _reminderDateMeta,
        reminderDate.isAcceptableOrUnknown(
          data['reminder_date']!,
          _reminderDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Thing map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Thing(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      iconCodePoint: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code_point'],
      )!,
      reminderDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reminder_date'],
      ),
    );
  }

  @override
  $ThingsTable createAlias(String alias) {
    return $ThingsTable(attachedDatabase, alias);
  }
}

class Thing extends DataClass implements Insertable<Thing> {
  final int id;
  final String title;
  final String category;
  final int iconCodePoint;
  final DateTime? reminderDate;
  const Thing({
    required this.id,
    required this.title,
    required this.category,
    required this.iconCodePoint,
    this.reminderDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['category'] = Variable<String>(category);
    map['icon_code_point'] = Variable<int>(iconCodePoint);
    if (!nullToAbsent || reminderDate != null) {
      map['reminder_date'] = Variable<DateTime>(reminderDate);
    }
    return map;
  }

  ThingsCompanion toCompanion(bool nullToAbsent) {
    return ThingsCompanion(
      id: Value(id),
      title: Value(title),
      category: Value(category),
      iconCodePoint: Value(iconCodePoint),
      reminderDate: reminderDate == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderDate),
    );
  }

  factory Thing.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Thing(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String>(json['category']),
      iconCodePoint: serializer.fromJson<int>(json['iconCodePoint']),
      reminderDate: serializer.fromJson<DateTime?>(json['reminderDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>(category),
      'iconCodePoint': serializer.toJson<int>(iconCodePoint),
      'reminderDate': serializer.toJson<DateTime?>(reminderDate),
    };
  }

  Thing copyWith({
    int? id,
    String? title,
    String? category,
    int? iconCodePoint,
    Value<DateTime?> reminderDate = const Value.absent(),
  }) => Thing(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category ?? this.category,
    iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    reminderDate: reminderDate.present ? reminderDate.value : this.reminderDate,
  );
  Thing copyWithCompanion(ThingsCompanion data) {
    return Thing(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      iconCodePoint: data.iconCodePoint.present
          ? data.iconCodePoint.value
          : this.iconCodePoint,
      reminderDate: data.reminderDate.present
          ? data.reminderDate.value
          : this.reminderDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Thing(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('reminderDate: $reminderDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, category, iconCodePoint, reminderDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Thing &&
          other.id == this.id &&
          other.title == this.title &&
          other.category == this.category &&
          other.iconCodePoint == this.iconCodePoint &&
          other.reminderDate == this.reminderDate);
}

class ThingsCompanion extends UpdateCompanion<Thing> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> category;
  final Value<int> iconCodePoint;
  final Value<DateTime?> reminderDate;
  const ThingsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.iconCodePoint = const Value.absent(),
    this.reminderDate = const Value.absent(),
  });
  ThingsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String category,
    required int iconCodePoint,
    this.reminderDate = const Value.absent(),
  }) : title = Value(title),
       category = Value(category),
       iconCodePoint = Value(iconCodePoint);
  static Insertable<Thing> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? category,
    Expression<int>? iconCodePoint,
    Expression<DateTime>? reminderDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (iconCodePoint != null) 'icon_code_point': iconCodePoint,
      if (reminderDate != null) 'reminder_date': reminderDate,
    });
  }

  ThingsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? category,
    Value<int>? iconCodePoint,
    Value<DateTime?>? reminderDate,
  }) {
    return ThingsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      reminderDate: reminderDate ?? this.reminderDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (iconCodePoint.present) {
      map['icon_code_point'] = Variable<int>(iconCodePoint.value);
    }
    if (reminderDate.present) {
      map['reminder_date'] = Variable<DateTime>(reminderDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThingsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('reminderDate: $reminderDate')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, Attachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _thingIdMeta = const VerificationMeta(
    'thingId',
  );
  @override
  late final GeneratedColumn<int> thingId = GeneratedColumn<int>(
    'thing_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, thingId, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('thing_id')) {
      context.handle(
        _thingIdMeta,
        thingId.isAcceptableOrUnknown(data['thing_id']!, _thingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_thingIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      thingId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}thing_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class Attachment extends DataClass implements Insertable<Attachment> {
  final int id;
  final int thingId;
  final String name;
  const Attachment({
    required this.id,
    required this.thingId,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['thing_id'] = Variable<int>(thingId);
    map['name'] = Variable<String>(name);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      thingId: Value(thingId),
      name: Value(name),
    );
  }

  factory Attachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attachment(
      id: serializer.fromJson<int>(json['id']),
      thingId: serializer.fromJson<int>(json['thingId']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'thingId': serializer.toJson<int>(thingId),
      'name': serializer.toJson<String>(name),
    };
  }

  Attachment copyWith({int? id, int? thingId, String? name}) => Attachment(
    id: id ?? this.id,
    thingId: thingId ?? this.thingId,
    name: name ?? this.name,
  );
  Attachment copyWithCompanion(AttachmentsCompanion data) {
    return Attachment(
      id: data.id.present ? data.id.value : this.id,
      thingId: data.thingId.present ? data.thingId.value : this.thingId,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attachment(')
          ..write('id: $id, ')
          ..write('thingId: $thingId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, thingId, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attachment &&
          other.id == this.id &&
          other.thingId == this.thingId &&
          other.name == this.name);
}

class AttachmentsCompanion extends UpdateCompanion<Attachment> {
  final Value<int> id;
  final Value<int> thingId;
  final Value<String> name;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.thingId = const Value.absent(),
    this.name = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    this.id = const Value.absent(),
    required int thingId,
    required String name,
  }) : thingId = Value(thingId),
       name = Value(name);
  static Insertable<Attachment> custom({
    Expression<int>? id,
    Expression<int>? thingId,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (thingId != null) 'thing_id': thingId,
      if (name != null) 'name': name,
    });
  }

  AttachmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? thingId,
    Value<String>? name,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      thingId: thingId ?? this.thingId,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (thingId.present) {
      map['thing_id'] = Variable<int>(thingId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('thingId: $thingId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MoneyEntriesTable extends MoneyEntries
    with TableInfo<$MoneyEntriesTable, MoneyEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoneyEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _personMeta = const VerificationMeta('person');
  @override
  late final GeneratedColumn<String> person = GeneratedColumn<String>(
    'person',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _owedToMeMeta = const VerificationMeta(
    'owedToMe',
  );
  @override
  late final GeneratedColumn<bool> owedToMe = GeneratedColumn<bool>(
    'owed_to_me',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("owed_to_me" IN (0, 1))',
    ),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _settledMeta = const VerificationMeta(
    'settled',
  );
  @override
  late final GeneratedColumn<bool> settled = GeneratedColumn<bool>(
    'settled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("settled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('debt'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    person,
    amount,
    currency,
    reason,
    owedToMe,
    dueDate,
    settled,
    kind,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'money_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoneyEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('person')) {
      context.handle(
        _personMeta,
        person.isAcceptableOrUnknown(data['person']!, _personMeta),
      );
    } else if (isInserting) {
      context.missing(_personMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('owed_to_me')) {
      context.handle(
        _owedToMeMeta,
        owedToMe.isAcceptableOrUnknown(data['owed_to_me']!, _owedToMeMeta),
      );
    } else if (isInserting) {
      context.missing(_owedToMeMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('settled')) {
      context.handle(
        _settledMeta,
        settled.isAcceptableOrUnknown(data['settled']!, _settledMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MoneyEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoneyEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      person: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      owedToMe: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}owed_to_me'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      settled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}settled'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
    );
  }

  @override
  $MoneyEntriesTable createAlias(String alias) {
    return $MoneyEntriesTable(attachedDatabase, alias);
  }
}

class MoneyEntry extends DataClass implements Insertable<MoneyEntry> {
  final int id;
  final String person;
  final double amount;
  final String currency;
  final String reason;
  final bool owedToMe;
  final DateTime? dueDate;
  final bool settled;
  final String kind;
  const MoneyEntry({
    required this.id,
    required this.person,
    required this.amount,
    required this.currency,
    required this.reason,
    required this.owedToMe,
    this.dueDate,
    required this.settled,
    required this.kind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['person'] = Variable<String>(person);
    map['amount'] = Variable<double>(amount);
    map['currency'] = Variable<String>(currency);
    map['reason'] = Variable<String>(reason);
    map['owed_to_me'] = Variable<bool>(owedToMe);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['settled'] = Variable<bool>(settled);
    map['kind'] = Variable<String>(kind);
    return map;
  }

  MoneyEntriesCompanion toCompanion(bool nullToAbsent) {
    return MoneyEntriesCompanion(
      id: Value(id),
      person: Value(person),
      amount: Value(amount),
      currency: Value(currency),
      reason: Value(reason),
      owedToMe: Value(owedToMe),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      settled: Value(settled),
      kind: Value(kind),
    );
  }

  factory MoneyEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoneyEntry(
      id: serializer.fromJson<int>(json['id']),
      person: serializer.fromJson<String>(json['person']),
      amount: serializer.fromJson<double>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      reason: serializer.fromJson<String>(json['reason']),
      owedToMe: serializer.fromJson<bool>(json['owedToMe']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      settled: serializer.fromJson<bool>(json['settled']),
      kind: serializer.fromJson<String>(json['kind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'person': serializer.toJson<String>(person),
      'amount': serializer.toJson<double>(amount),
      'currency': serializer.toJson<String>(currency),
      'reason': serializer.toJson<String>(reason),
      'owedToMe': serializer.toJson<bool>(owedToMe),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'settled': serializer.toJson<bool>(settled),
      'kind': serializer.toJson<String>(kind),
    };
  }

  MoneyEntry copyWith({
    int? id,
    String? person,
    double? amount,
    String? currency,
    String? reason,
    bool? owedToMe,
    Value<DateTime?> dueDate = const Value.absent(),
    bool? settled,
    String? kind,
  }) => MoneyEntry(
    id: id ?? this.id,
    person: person ?? this.person,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    reason: reason ?? this.reason,
    owedToMe: owedToMe ?? this.owedToMe,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    settled: settled ?? this.settled,
    kind: kind ?? this.kind,
  );
  MoneyEntry copyWithCompanion(MoneyEntriesCompanion data) {
    return MoneyEntry(
      id: data.id.present ? data.id.value : this.id,
      person: data.person.present ? data.person.value : this.person,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      reason: data.reason.present ? data.reason.value : this.reason,
      owedToMe: data.owedToMe.present ? data.owedToMe.value : this.owedToMe,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      settled: data.settled.present ? data.settled.value : this.settled,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoneyEntry(')
          ..write('id: $id, ')
          ..write('person: $person, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('reason: $reason, ')
          ..write('owedToMe: $owedToMe, ')
          ..write('dueDate: $dueDate, ')
          ..write('settled: $settled, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    person,
    amount,
    currency,
    reason,
    owedToMe,
    dueDate,
    settled,
    kind,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoneyEntry &&
          other.id == this.id &&
          other.person == this.person &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.reason == this.reason &&
          other.owedToMe == this.owedToMe &&
          other.dueDate == this.dueDate &&
          other.settled == this.settled &&
          other.kind == this.kind);
}

class MoneyEntriesCompanion extends UpdateCompanion<MoneyEntry> {
  final Value<int> id;
  final Value<String> person;
  final Value<double> amount;
  final Value<String> currency;
  final Value<String> reason;
  final Value<bool> owedToMe;
  final Value<DateTime?> dueDate;
  final Value<bool> settled;
  final Value<String> kind;
  const MoneyEntriesCompanion({
    this.id = const Value.absent(),
    this.person = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.reason = const Value.absent(),
    this.owedToMe = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.settled = const Value.absent(),
    this.kind = const Value.absent(),
  });
  MoneyEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String person,
    required double amount,
    required String currency,
    this.reason = const Value.absent(),
    required bool owedToMe,
    this.dueDate = const Value.absent(),
    this.settled = const Value.absent(),
    this.kind = const Value.absent(),
  }) : person = Value(person),
       amount = Value(amount),
       currency = Value(currency),
       owedToMe = Value(owedToMe);
  static Insertable<MoneyEntry> custom({
    Expression<int>? id,
    Expression<String>? person,
    Expression<double>? amount,
    Expression<String>? currency,
    Expression<String>? reason,
    Expression<bool>? owedToMe,
    Expression<DateTime>? dueDate,
    Expression<bool>? settled,
    Expression<String>? kind,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (person != null) 'person': person,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (reason != null) 'reason': reason,
      if (owedToMe != null) 'owed_to_me': owedToMe,
      if (dueDate != null) 'due_date': dueDate,
      if (settled != null) 'settled': settled,
      if (kind != null) 'kind': kind,
    });
  }

  MoneyEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? person,
    Value<double>? amount,
    Value<String>? currency,
    Value<String>? reason,
    Value<bool>? owedToMe,
    Value<DateTime?>? dueDate,
    Value<bool>? settled,
    Value<String>? kind,
  }) {
    return MoneyEntriesCompanion(
      id: id ?? this.id,
      person: person ?? this.person,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      reason: reason ?? this.reason,
      owedToMe: owedToMe ?? this.owedToMe,
      dueDate: dueDate ?? this.dueDate,
      settled: settled ?? this.settled,
      kind: kind ?? this.kind,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (person.present) {
      map['person'] = Variable<String>(person.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (owedToMe.present) {
      map['owed_to_me'] = Variable<bool>(owedToMe.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (settled.present) {
      map['settled'] = Variable<bool>(settled.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoneyEntriesCompanion(')
          ..write('id: $id, ')
          ..write('person: $person, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('reason: $reason, ')
          ..write('owedToMe: $owedToMe, ')
          ..write('dueDate: $dueDate, ')
          ..write('settled: $settled, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }
}

class $MoneyAttachmentsTable extends MoneyAttachments
    with TableInfo<$MoneyAttachmentsTable, MoneyAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoneyAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _moneyIdMeta = const VerificationMeta(
    'moneyId',
  );
  @override
  late final GeneratedColumn<int> moneyId = GeneratedColumn<int>(
    'money_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, moneyId, name, path, kind];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'money_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoneyAttachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('money_id')) {
      context.handle(
        _moneyIdMeta,
        moneyId.isAcceptableOrUnknown(data['money_id']!, _moneyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_moneyIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MoneyAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoneyAttachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      moneyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}money_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
    );
  }

  @override
  $MoneyAttachmentsTable createAlias(String alias) {
    return $MoneyAttachmentsTable(attachedDatabase, alias);
  }
}

class MoneyAttachment extends DataClass implements Insertable<MoneyAttachment> {
  final int id;
  final int moneyId;
  final String name;
  final String path;
  final String kind;
  const MoneyAttachment({
    required this.id,
    required this.moneyId,
    required this.name,
    required this.path,
    required this.kind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['money_id'] = Variable<int>(moneyId);
    map['name'] = Variable<String>(name);
    map['path'] = Variable<String>(path);
    map['kind'] = Variable<String>(kind);
    return map;
  }

  MoneyAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return MoneyAttachmentsCompanion(
      id: Value(id),
      moneyId: Value(moneyId),
      name: Value(name),
      path: Value(path),
      kind: Value(kind),
    );
  }

  factory MoneyAttachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoneyAttachment(
      id: serializer.fromJson<int>(json['id']),
      moneyId: serializer.fromJson<int>(json['moneyId']),
      name: serializer.fromJson<String>(json['name']),
      path: serializer.fromJson<String>(json['path']),
      kind: serializer.fromJson<String>(json['kind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'moneyId': serializer.toJson<int>(moneyId),
      'name': serializer.toJson<String>(name),
      'path': serializer.toJson<String>(path),
      'kind': serializer.toJson<String>(kind),
    };
  }

  MoneyAttachment copyWith({
    int? id,
    int? moneyId,
    String? name,
    String? path,
    String? kind,
  }) => MoneyAttachment(
    id: id ?? this.id,
    moneyId: moneyId ?? this.moneyId,
    name: name ?? this.name,
    path: path ?? this.path,
    kind: kind ?? this.kind,
  );
  MoneyAttachment copyWithCompanion(MoneyAttachmentsCompanion data) {
    return MoneyAttachment(
      id: data.id.present ? data.id.value : this.id,
      moneyId: data.moneyId.present ? data.moneyId.value : this.moneyId,
      name: data.name.present ? data.name.value : this.name,
      path: data.path.present ? data.path.value : this.path,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoneyAttachment(')
          ..write('id: $id, ')
          ..write('moneyId: $moneyId, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, moneyId, name, path, kind);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoneyAttachment &&
          other.id == this.id &&
          other.moneyId == this.moneyId &&
          other.name == this.name &&
          other.path == this.path &&
          other.kind == this.kind);
}

class MoneyAttachmentsCompanion extends UpdateCompanion<MoneyAttachment> {
  final Value<int> id;
  final Value<int> moneyId;
  final Value<String> name;
  final Value<String> path;
  final Value<String> kind;
  const MoneyAttachmentsCompanion({
    this.id = const Value.absent(),
    this.moneyId = const Value.absent(),
    this.name = const Value.absent(),
    this.path = const Value.absent(),
    this.kind = const Value.absent(),
  });
  MoneyAttachmentsCompanion.insert({
    this.id = const Value.absent(),
    required int moneyId,
    required String name,
    required String path,
    required String kind,
  }) : moneyId = Value(moneyId),
       name = Value(name),
       path = Value(path),
       kind = Value(kind);
  static Insertable<MoneyAttachment> custom({
    Expression<int>? id,
    Expression<int>? moneyId,
    Expression<String>? name,
    Expression<String>? path,
    Expression<String>? kind,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (moneyId != null) 'money_id': moneyId,
      if (name != null) 'name': name,
      if (path != null) 'path': path,
      if (kind != null) 'kind': kind,
    });
  }

  MoneyAttachmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? moneyId,
    Value<String>? name,
    Value<String>? path,
    Value<String>? kind,
  }) {
    return MoneyAttachmentsCompanion(
      id: id ?? this.id,
      moneyId: moneyId ?? this.moneyId,
      name: name ?? this.name,
      path: path ?? this.path,
      kind: kind ?? this.kind,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (moneyId.present) {
      map['money_id'] = Variable<int>(moneyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoneyAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('moneyId: $moneyId, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ThingsTable things = $ThingsTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $MoneyEntriesTable moneyEntries = $MoneyEntriesTable(this);
  late final $MoneyAttachmentsTable moneyAttachments = $MoneyAttachmentsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    things,
    attachments,
    appSettings,
    moneyEntries,
    moneyAttachments,
  ];
}

typedef $$ThingsTableCreateCompanionBuilder = ThingsCompanion Function({
  Value<int> id,
  required String title,
  required String category,
  required int iconCodePoint,
  Value<DateTime?> reminderDate,
});
typedef $$ThingsTableUpdateCompanionBuilder = ThingsCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> category,
  Value<int> iconCodePoint,
  Value<DateTime?> reminderDate,
});

class $$ThingsTableFilterComposer
    extends Composer<_$AppDatabase, $ThingsTable> {
  $$ThingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reminderDate => $composableBuilder(
    column: $table.reminderDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ThingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ThingsTable> {
  $$ThingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reminderDate => $composableBuilder(
    column: $table.reminderDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ThingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ThingsTable> {
  $$ThingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reminderDate => $composableBuilder(
    column: $table.reminderDate,
    builder: (column) => column,
  );
}

class $$ThingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ThingsTable,
          Thing,
          $$ThingsTableFilterComposer,
          $$ThingsTableOrderingComposer,
          $$ThingsTableAnnotationComposer,
          $$ThingsTableCreateCompanionBuilder,
          $$ThingsTableUpdateCompanionBuilder,
          (Thing, BaseReferences<_$AppDatabase, $ThingsTable, Thing>),
          Thing,
          PrefetchHooks Function()
        > {
  $$ThingsTableTableManager(_$AppDatabase db, $ThingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> iconCodePoint = const Value.absent(),
                Value<DateTime?> reminderDate = const Value.absent(),
              }) => ThingsCompanion(
                id: id,
                title: title,
                category: category,
                iconCodePoint: iconCodePoint,
                reminderDate: reminderDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String category,
                required int iconCodePoint,
                Value<DateTime?> reminderDate = const Value.absent(),
              }) => ThingsCompanion.insert(
                id: id,
                title: title,
                category: category,
                iconCodePoint: iconCodePoint,
                reminderDate: reminderDate,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ThingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ThingsTable,
      Thing,
      $$ThingsTableFilterComposer,
      $$ThingsTableOrderingComposer,
      $$ThingsTableAnnotationComposer,
      $$ThingsTableCreateCompanionBuilder,
      $$ThingsTableUpdateCompanionBuilder,
      (Thing, BaseReferences<_$AppDatabase, $ThingsTable, Thing>),
      Thing,
      PrefetchHooks Function()
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<int> id,
      required int thingId,
      required String name,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<int> id,
      Value<int> thingId,
      Value<String> name,
    });

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get thingId => $composableBuilder(
    column: $table.thingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get thingId => $composableBuilder(
    column: $table.thingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get thingId =>
      $composableBuilder(column: $table.thingId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentsTable,
          Attachment,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (
            Attachment,
            BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment>,
          ),
          Attachment,
          PrefetchHooks Function()
        > {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> thingId = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) => AttachmentsCompanion(id: id, thingId: thingId, name: name),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int thingId,
                required String name,
              }) => AttachmentsCompanion.insert(
                id: id,
                thingId: thingId,
                name: name,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentsTable,
      Attachment,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (
        Attachment,
        BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment>,
      ),
      Attachment,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$MoneyEntriesTableCreateCompanionBuilder =
    MoneyEntriesCompanion Function({
      Value<int> id,
      required String person,
      required double amount,
      required String currency,
      Value<String> reason,
      required bool owedToMe,
      Value<DateTime?> dueDate,
      Value<bool> settled,
      Value<String> kind,
    });
typedef $$MoneyEntriesTableUpdateCompanionBuilder =
    MoneyEntriesCompanion Function({
      Value<int> id,
      Value<String> person,
      Value<double> amount,
      Value<String> currency,
      Value<String> reason,
      Value<bool> owedToMe,
      Value<DateTime?> dueDate,
      Value<bool> settled,
      Value<String> kind,
    });

class $$MoneyEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $MoneyEntriesTable> {
  $$MoneyEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get person => $composableBuilder(
    column: $table.person,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get owedToMe => $composableBuilder(
    column: $table.owedToMe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get settled => $composableBuilder(
    column: $table.settled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MoneyEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MoneyEntriesTable> {
  $$MoneyEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get person => $composableBuilder(
    column: $table.person,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get owedToMe => $composableBuilder(
    column: $table.owedToMe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get settled => $composableBuilder(
    column: $table.settled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MoneyEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoneyEntriesTable> {
  $$MoneyEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get person =>
      $composableBuilder(column: $table.person, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<bool> get owedToMe =>
      $composableBuilder(column: $table.owedToMe, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<bool> get settled =>
      $composableBuilder(column: $table.settled, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);
}

class $$MoneyEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoneyEntriesTable,
          MoneyEntry,
          $$MoneyEntriesTableFilterComposer,
          $$MoneyEntriesTableOrderingComposer,
          $$MoneyEntriesTableAnnotationComposer,
          $$MoneyEntriesTableCreateCompanionBuilder,
          $$MoneyEntriesTableUpdateCompanionBuilder,
          (
            MoneyEntry,
            BaseReferences<_$AppDatabase, $MoneyEntriesTable, MoneyEntry>,
          ),
          MoneyEntry,
          PrefetchHooks Function()
        > {
  $$MoneyEntriesTableTableManager(_$AppDatabase db, $MoneyEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoneyEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoneyEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoneyEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> person = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<bool> owedToMe = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<bool> settled = const Value.absent(),
                Value<String> kind = const Value.absent(),
              }) => MoneyEntriesCompanion(
                id: id,
                person: person,
                amount: amount,
                currency: currency,
                reason: reason,
                owedToMe: owedToMe,
                dueDate: dueDate,
                settled: settled,
                kind: kind,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String person,
                required double amount,
                required String currency,
                Value<String> reason = const Value.absent(),
                required bool owedToMe,
                Value<DateTime?> dueDate = const Value.absent(),
                Value<bool> settled = const Value.absent(),
                Value<String> kind = const Value.absent(),
              }) => MoneyEntriesCompanion.insert(
                id: id,
                person: person,
                amount: amount,
                currency: currency,
                reason: reason,
                owedToMe: owedToMe,
                dueDate: dueDate,
                settled: settled,
                kind: kind,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MoneyEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoneyEntriesTable,
      MoneyEntry,
      $$MoneyEntriesTableFilterComposer,
      $$MoneyEntriesTableOrderingComposer,
      $$MoneyEntriesTableAnnotationComposer,
      $$MoneyEntriesTableCreateCompanionBuilder,
      $$MoneyEntriesTableUpdateCompanionBuilder,
      (
        MoneyEntry,
        BaseReferences<_$AppDatabase, $MoneyEntriesTable, MoneyEntry>,
      ),
      MoneyEntry,
      PrefetchHooks Function()
    >;
typedef $$MoneyAttachmentsTableCreateCompanionBuilder =
    MoneyAttachmentsCompanion Function({
      Value<int> id,
      required int moneyId,
      required String name,
      required String path,
      required String kind,
    });
typedef $$MoneyAttachmentsTableUpdateCompanionBuilder =
    MoneyAttachmentsCompanion Function({
      Value<int> id,
      Value<int> moneyId,
      Value<String> name,
      Value<String> path,
      Value<String> kind,
    });

class $$MoneyAttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $MoneyAttachmentsTable> {
  $$MoneyAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get moneyId => $composableBuilder(
    column: $table.moneyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MoneyAttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $MoneyAttachmentsTable> {
  $$MoneyAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get moneyId => $composableBuilder(
    column: $table.moneyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MoneyAttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoneyAttachmentsTable> {
  $$MoneyAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get moneyId =>
      $composableBuilder(column: $table.moneyId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);
}

class $$MoneyAttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoneyAttachmentsTable,
          MoneyAttachment,
          $$MoneyAttachmentsTableFilterComposer,
          $$MoneyAttachmentsTableOrderingComposer,
          $$MoneyAttachmentsTableAnnotationComposer,
          $$MoneyAttachmentsTableCreateCompanionBuilder,
          $$MoneyAttachmentsTableUpdateCompanionBuilder,
          (
            MoneyAttachment,
            BaseReferences<
              _$AppDatabase,
              $MoneyAttachmentsTable,
              MoneyAttachment
            >,
          ),
          MoneyAttachment,
          PrefetchHooks Function()
        > {
  $$MoneyAttachmentsTableTableManager(
    _$AppDatabase db,
    $MoneyAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoneyAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoneyAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoneyAttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> moneyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> kind = const Value.absent(),
              }) => MoneyAttachmentsCompanion(
                id: id,
                moneyId: moneyId,
                name: name,
                path: path,
                kind: kind,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int moneyId,
                required String name,
                required String path,
                required String kind,
              }) => MoneyAttachmentsCompanion.insert(
                id: id,
                moneyId: moneyId,
                name: name,
                path: path,
                kind: kind,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MoneyAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoneyAttachmentsTable,
      MoneyAttachment,
      $$MoneyAttachmentsTableFilterComposer,
      $$MoneyAttachmentsTableOrderingComposer,
      $$MoneyAttachmentsTableAnnotationComposer,
      $$MoneyAttachmentsTableCreateCompanionBuilder,
      $$MoneyAttachmentsTableUpdateCompanionBuilder,
      (
        MoneyAttachment,
        BaseReferences<_$AppDatabase, $MoneyAttachmentsTable, MoneyAttachment>,
      ),
      MoneyAttachment,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ThingsTableTableManager get things =>
      $$ThingsTableTableManager(_db, _db.things);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$MoneyEntriesTableTableManager get moneyEntries =>
      $$MoneyEntriesTableTableManager(_db, _db.moneyEntries);
  $$MoneyAttachmentsTableTableManager get moneyAttachments =>
      $$MoneyAttachmentsTableTableManager(_db, _db.moneyAttachments);
}
