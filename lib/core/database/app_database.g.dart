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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    description,
    status,
    completedAt,
    archivedAt,
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
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
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
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
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
  final String description;
  final String status;
  final DateTime? completedAt;
  final DateTime? archivedAt;
  final String category;
  final int iconCodePoint;
  final DateTime? reminderDate;
  const Thing({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.completedAt,
    this.archivedAt,
    required this.category,
    required this.iconCodePoint,
    this.reminderDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
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
      description: Value(description),
      status: Value(status),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
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
      description: serializer.fromJson<String>(json['description']),
      status: serializer.fromJson<String>(json['status']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
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
      'description': serializer.toJson<String>(description),
      'status': serializer.toJson<String>(status),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'category': serializer.toJson<String>(category),
      'iconCodePoint': serializer.toJson<int>(iconCodePoint),
      'reminderDate': serializer.toJson<DateTime?>(reminderDate),
    };
  }

  Thing copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<DateTime?> archivedAt = const Value.absent(),
    String? category,
    int? iconCodePoint,
    Value<DateTime?> reminderDate = const Value.absent(),
  }) => Thing(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    status: status ?? this.status,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    category: category ?? this.category,
    iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    reminderDate: reminderDate.present ? reminderDate.value : this.reminderDate,
  );
  Thing copyWithCompanion(ThingsCompanion data) {
    return Thing(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      status: data.status.present ? data.status.value : this.status,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
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
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('category: $category, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('reminderDate: $reminderDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    status,
    completedAt,
    archivedAt,
    category,
    iconCodePoint,
    reminderDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Thing &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.status == this.status &&
          other.completedAt == this.completedAt &&
          other.archivedAt == this.archivedAt &&
          other.category == this.category &&
          other.iconCodePoint == this.iconCodePoint &&
          other.reminderDate == this.reminderDate);
}

class ThingsCompanion extends UpdateCompanion<Thing> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String> status;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> archivedAt;
  final Value<String> category;
  final Value<int> iconCodePoint;
  final Value<DateTime?> reminderDate;
  const ThingsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.category = const Value.absent(),
    this.iconCodePoint = const Value.absent(),
    this.reminderDate = const Value.absent(),
  });
  ThingsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    required String category,
    required int iconCodePoint,
    this.reminderDate = const Value.absent(),
  }) : title = Value(title),
       category = Value(category),
       iconCodePoint = Value(iconCodePoint);
  static Insertable<Thing> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? status,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? archivedAt,
    Expression<String>? category,
    Expression<int>? iconCodePoint,
    Expression<DateTime>? reminderDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (completedAt != null) 'completed_at': completedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (category != null) 'category': category,
      if (iconCodePoint != null) 'icon_code_point': iconCodePoint,
      if (reminderDate != null) 'reminder_date': reminderDate,
    });
  }

  ThingsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? description,
    Value<String>? status,
    Value<DateTime?>? completedAt,
    Value<DateTime?>? archivedAt,
    Value<String>? category,
    Value<int>? iconCodePoint,
    Value<DateTime?>? reminderDate,
  }) {
    return ThingsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      archivedAt: archivedAt ?? this.archivedAt,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
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
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('archivedAt: $archivedAt, ')
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
    $customConstraints: 'NOT NULL REFERENCES things(id)',
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('document'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, thingId, name, path, kind];
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
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
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
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class Attachment extends DataClass implements Insertable<Attachment> {
  final int id;
  final int thingId;
  final String name;
  final String path;
  final String kind;
  const Attachment({
    required this.id,
    required this.thingId,
    required this.name,
    required this.path,
    required this.kind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['thing_id'] = Variable<int>(thingId);
    map['name'] = Variable<String>(name);
    map['path'] = Variable<String>(path);
    map['kind'] = Variable<String>(kind);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      thingId: Value(thingId),
      name: Value(name),
      path: Value(path),
      kind: Value(kind),
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
      path: serializer.fromJson<String>(json['path']),
      kind: serializer.fromJson<String>(json['kind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'thingId': serializer.toJson<int>(thingId),
      'name': serializer.toJson<String>(name),
      'path': serializer.toJson<String>(path),
      'kind': serializer.toJson<String>(kind),
    };
  }

  Attachment copyWith({
    int? id,
    int? thingId,
    String? name,
    String? path,
    String? kind,
  }) => Attachment(
    id: id ?? this.id,
    thingId: thingId ?? this.thingId,
    name: name ?? this.name,
    path: path ?? this.path,
    kind: kind ?? this.kind,
  );
  Attachment copyWithCompanion(AttachmentsCompanion data) {
    return Attachment(
      id: data.id.present ? data.id.value : this.id,
      thingId: data.thingId.present ? data.thingId.value : this.thingId,
      name: data.name.present ? data.name.value : this.name,
      path: data.path.present ? data.path.value : this.path,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attachment(')
          ..write('id: $id, ')
          ..write('thingId: $thingId, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, thingId, name, path, kind);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attachment &&
          other.id == this.id &&
          other.thingId == this.thingId &&
          other.name == this.name &&
          other.path == this.path &&
          other.kind == this.kind);
}

class AttachmentsCompanion extends UpdateCompanion<Attachment> {
  final Value<int> id;
  final Value<int> thingId;
  final Value<String> name;
  final Value<String> path;
  final Value<String> kind;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.thingId = const Value.absent(),
    this.name = const Value.absent(),
    this.path = const Value.absent(),
    this.kind = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    this.id = const Value.absent(),
    required int thingId,
    required String name,
    this.path = const Value.absent(),
    this.kind = const Value.absent(),
  }) : thingId = Value(thingId),
       name = Value(name);
  static Insertable<Attachment> custom({
    Expression<int>? id,
    Expression<int>? thingId,
    Expression<String>? name,
    Expression<String>? path,
    Expression<String>? kind,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (thingId != null) 'thing_id': thingId,
      if (name != null) 'name': name,
      if (path != null) 'path': path,
      if (kind != null) 'kind': kind,
    });
  }

  AttachmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? thingId,
    Value<String>? name,
    Value<String>? path,
    Value<String>? kind,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      thingId: thingId ?? this.thingId,
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
    if (thingId.present) {
      map['thing_id'] = Variable<int>(thingId.value);
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
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('thingId: $thingId, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('kind: $kind')
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
  static const VerificationMeta _paidAmountMeta = const VerificationMeta(
    'paidAmount',
  );
  @override
  late final GeneratedColumn<double> paidAmount = GeneratedColumn<double>(
    'paid_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    paidAmount,
    createdAt,
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
    if (data.containsKey('paid_amount')) {
      context.handle(
        _paidAmountMeta,
        paidAmount.isAcceptableOrUnknown(data['paid_amount']!, _paidAmountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
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
      paidAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}paid_amount'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
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
  final double paidAmount;
  final DateTime createdAt;
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
    required this.paidAmount,
    required this.createdAt,
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
    map['paid_amount'] = Variable<double>(paidAmount);
    map['created_at'] = Variable<DateTime>(createdAt);
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
      paidAmount: Value(paidAmount),
      createdAt: Value(createdAt),
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
      paidAmount: serializer.fromJson<double>(json['paidAmount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
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
      'paidAmount': serializer.toJson<double>(paidAmount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
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
    double? paidAmount,
    DateTime? createdAt,
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
    paidAmount: paidAmount ?? this.paidAmount,
    createdAt: createdAt ?? this.createdAt,
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
      paidAmount: data.paidAmount.present
          ? data.paidAmount.value
          : this.paidAmount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
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
          ..write('kind: $kind, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('createdAt: $createdAt')
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
    paidAmount,
    createdAt,
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
          other.kind == this.kind &&
          other.paidAmount == this.paidAmount &&
          other.createdAt == this.createdAt);
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
  final Value<double> paidAmount;
  final Value<DateTime> createdAt;
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
    this.paidAmount = const Value.absent(),
    this.createdAt = const Value.absent(),
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
    this.paidAmount = const Value.absent(),
    this.createdAt = const Value.absent(),
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
    Expression<double>? paidAmount,
    Expression<DateTime>? createdAt,
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
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (createdAt != null) 'created_at': createdAt,
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
    Value<double>? paidAmount,
    Value<DateTime>? createdAt,
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
      paidAmount: paidAmount ?? this.paidAmount,
      createdAt: createdAt ?? this.createdAt,
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
    if (paidAmount.present) {
      map['paid_amount'] = Variable<double>(paidAmount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
          ..write('kind: $kind, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('createdAt: $createdAt')
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
    $customConstraints: 'NOT NULL REFERENCES money_entries(id)',
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

class $MoneyPaymentsTable extends MoneyPayments
    with TableInfo<$MoneyPaymentsTable, MoneyPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoneyPaymentsTable(this.attachedDatabase, [this._alias]);
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
    $customConstraints:
        'NOT NULL REFERENCES money_entries(id) ON DELETE CASCADE',
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
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<DateTime> paidAt = GeneratedColumn<DateTime>(
    'paid_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, moneyId, amount, paidAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'money_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoneyPayment> instance, {
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
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('paid_at')) {
      context.handle(
        _paidAtMeta,
        paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta),
      );
    } else if (isInserting) {
      context.missing(_paidAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MoneyPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoneyPayment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      moneyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}money_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      paidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_at'],
      )!,
    );
  }

  @override
  $MoneyPaymentsTable createAlias(String alias) {
    return $MoneyPaymentsTable(attachedDatabase, alias);
  }
}

class MoneyPayment extends DataClass implements Insertable<MoneyPayment> {
  final int id;
  final int moneyId;
  final double amount;
  final DateTime paidAt;
  const MoneyPayment({
    required this.id,
    required this.moneyId,
    required this.amount,
    required this.paidAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['money_id'] = Variable<int>(moneyId);
    map['amount'] = Variable<double>(amount);
    map['paid_at'] = Variable<DateTime>(paidAt);
    return map;
  }

  MoneyPaymentsCompanion toCompanion(bool nullToAbsent) {
    return MoneyPaymentsCompanion(
      id: Value(id),
      moneyId: Value(moneyId),
      amount: Value(amount),
      paidAt: Value(paidAt),
    );
  }

  factory MoneyPayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoneyPayment(
      id: serializer.fromJson<int>(json['id']),
      moneyId: serializer.fromJson<int>(json['moneyId']),
      amount: serializer.fromJson<double>(json['amount']),
      paidAt: serializer.fromJson<DateTime>(json['paidAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'moneyId': serializer.toJson<int>(moneyId),
      'amount': serializer.toJson<double>(amount),
      'paidAt': serializer.toJson<DateTime>(paidAt),
    };
  }

  MoneyPayment copyWith({
    int? id,
    int? moneyId,
    double? amount,
    DateTime? paidAt,
  }) => MoneyPayment(
    id: id ?? this.id,
    moneyId: moneyId ?? this.moneyId,
    amount: amount ?? this.amount,
    paidAt: paidAt ?? this.paidAt,
  );
  MoneyPayment copyWithCompanion(MoneyPaymentsCompanion data) {
    return MoneyPayment(
      id: data.id.present ? data.id.value : this.id,
      moneyId: data.moneyId.present ? data.moneyId.value : this.moneyId,
      amount: data.amount.present ? data.amount.value : this.amount,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoneyPayment(')
          ..write('id: $id, ')
          ..write('moneyId: $moneyId, ')
          ..write('amount: $amount, ')
          ..write('paidAt: $paidAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, moneyId, amount, paidAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoneyPayment &&
          other.id == this.id &&
          other.moneyId == this.moneyId &&
          other.amount == this.amount &&
          other.paidAt == this.paidAt);
}

class MoneyPaymentsCompanion extends UpdateCompanion<MoneyPayment> {
  final Value<int> id;
  final Value<int> moneyId;
  final Value<double> amount;
  final Value<DateTime> paidAt;
  const MoneyPaymentsCompanion({
    this.id = const Value.absent(),
    this.moneyId = const Value.absent(),
    this.amount = const Value.absent(),
    this.paidAt = const Value.absent(),
  });
  MoneyPaymentsCompanion.insert({
    this.id = const Value.absent(),
    required int moneyId,
    required double amount,
    required DateTime paidAt,
  }) : moneyId = Value(moneyId),
       amount = Value(amount),
       paidAt = Value(paidAt);
  static Insertable<MoneyPayment> custom({
    Expression<int>? id,
    Expression<int>? moneyId,
    Expression<double>? amount,
    Expression<DateTime>? paidAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (moneyId != null) 'money_id': moneyId,
      if (amount != null) 'amount': amount,
      if (paidAt != null) 'paid_at': paidAt,
    });
  }

  MoneyPaymentsCompanion copyWith({
    Value<int>? id,
    Value<int>? moneyId,
    Value<double>? amount,
    Value<DateTime>? paidAt,
  }) {
    return MoneyPaymentsCompanion(
      id: id ?? this.id,
      moneyId: moneyId ?? this.moneyId,
      amount: amount ?? this.amount,
      paidAt: paidAt ?? this.paidAt,
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
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<DateTime>(paidAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoneyPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('moneyId: $moneyId, ')
          ..write('amount: $amount, ')
          ..write('paidAt: $paidAt')
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
  late final $MoneyPaymentsTable moneyPayments = $MoneyPaymentsTable(this);
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
    moneyPayments,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'money_entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('money_payments', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ThingsTableCreateCompanionBuilder = ThingsCompanion Function({
  Value<int> id,
  required String title,
  Value<String> description,
  Value<String> status,
  Value<DateTime?> completedAt,
  Value<DateTime?> archivedAt,
  required String category,
  required int iconCodePoint,
  Value<DateTime?> reminderDate,
});
typedef $$ThingsTableUpdateCompanionBuilder = ThingsCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> description,
  Value<String> status,
  Value<DateTime?> completedAt,
  Value<DateTime?> archivedAt,
  Value<String> category,
  Value<int> iconCodePoint,
  Value<DateTime?> reminderDate,
});

final class $$ThingsTableReferences
    extends BaseReferences<_$AppDatabase, $ThingsTable, Thing> {
  $$ThingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AttachmentsTable, List<Attachment>>
  _attachmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attachments,
    aliasName: $_aliasNameGenerator(db.things.id, db.attachments.thingId),
  );

  $$AttachmentsTableProcessedTableManager get attachmentsRefs {
    final manager = $$AttachmentsTableTableManager(
      $_db,
      $_db.attachments,
    ).filter((f) => f.thingId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attachmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
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

  Expression<bool> attachmentsRefs(
    Expression<bool> Function($$AttachmentsTableFilterComposer f) f,
  ) {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.thingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

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

  Expression<T> attachmentsRefs<T extends Object>(
    Expression<T> Function($$AttachmentsTableAnnotationComposer a) f,
  ) {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.thingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (Thing, $$ThingsTableReferences),
          Thing,
          PrefetchHooks Function({bool attachmentsRefs})
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
                Value<String> description = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> iconCodePoint = const Value.absent(),
                Value<DateTime?> reminderDate = const Value.absent(),
              }) => ThingsCompanion(
                id: id,
                title: title,
                description: description,
                status: status,
                completedAt: completedAt,
                archivedAt: archivedAt,
                category: category,
                iconCodePoint: iconCodePoint,
                reminderDate: reminderDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String> description = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                required String category,
                required int iconCodePoint,
                Value<DateTime?> reminderDate = const Value.absent(),
              }) => ThingsCompanion.insert(
                id: id,
                title: title,
                description: description,
                status: status,
                completedAt: completedAt,
                archivedAt: archivedAt,
                category: category,
                iconCodePoint: iconCodePoint,
                reminderDate: reminderDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ThingsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({attachmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (attachmentsRefs) db.attachments],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (attachmentsRefs)
                    await $_getPrefetchedData<Thing, $ThingsTable, Attachment>(
                      currentTable: table,
                      referencedTable: $$ThingsTableReferences
                          ._attachmentsRefsTable(db),
                      managerFromTypedResult: (p0) => $$ThingsTableReferences(
                        db,
                        table,
                        p0,
                      ).attachmentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.thingId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
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
      (Thing, $$ThingsTableReferences),
      Thing,
      PrefetchHooks Function({bool attachmentsRefs})
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<int> id,
      required int thingId,
      required String name,
      Value<String> path,
      Value<String> kind,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<int> id,
      Value<int> thingId,
      Value<String> name,
      Value<String> path,
      Value<String> kind,
    });

final class $$AttachmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment> {
  $$AttachmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ThingsTable _thingIdTable(_$AppDatabase db) => db.things.createAlias(
    $_aliasNameGenerator(db.attachments.thingId, db.things.id),
  );

  $$ThingsTableProcessedTableManager get thingId {
    final $_column = $_itemColumn<int>('thing_id')!;

    final manager = $$ThingsTableTableManager(
      $_db,
      $_db.things,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_thingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

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

  $$ThingsTableFilterComposer get thingId {
    final $$ThingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.thingId,
      referencedTable: $db.things,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ThingsTableFilterComposer(
            $db: $db,
            $table: $db.things,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  $$ThingsTableOrderingComposer get thingId {
    final $$ThingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.thingId,
      referencedTable: $db.things,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ThingsTableOrderingComposer(
            $db: $db,
            $table: $db.things,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  $$ThingsTableAnnotationComposer get thingId {
    final $$ThingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.thingId,
      referencedTable: $db.things,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ThingsTableAnnotationComposer(
            $db: $db,
            $table: $db.things,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
          (Attachment, $$AttachmentsTableReferences),
          Attachment,
          PrefetchHooks Function({bool thingId})
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
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> thingId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> kind = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                thingId: thingId,
                name: name,
                path: path,
                kind: kind,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int thingId,
                required String name,
                Value<String> path = const Value.absent(),
                Value<String> kind = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                thingId: thingId,
                name: name,
                path: path,
                kind: kind,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({thingId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (thingId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.thingId,
                        referencedTable: $$AttachmentsTableReferences
                            ._thingIdTable(db),
                        referencedColumn: $$AttachmentsTableReferences
                            ._thingIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
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
      (Attachment, $$AttachmentsTableReferences),
      Attachment,
      PrefetchHooks Function({bool thingId})
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
      Value<double> paidAmount,
      Value<DateTime> createdAt,
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
      Value<double> paidAmount,
      Value<DateTime> createdAt,
    });

final class $$MoneyEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $MoneyEntriesTable, MoneyEntry> {
  $$MoneyEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MoneyAttachmentsTable, List<MoneyAttachment>>
  _moneyAttachmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.moneyAttachments,
    aliasName: $_aliasNameGenerator(
      db.moneyEntries.id,
      db.moneyAttachments.moneyId,
    ),
  );

  $$MoneyAttachmentsTableProcessedTableManager get moneyAttachmentsRefs {
    final manager = $$MoneyAttachmentsTableTableManager(
      $_db,
      $_db.moneyAttachments,
    ).filter((f) => f.moneyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _moneyAttachmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MoneyPaymentsTable, List<MoneyPayment>>
  _moneyPaymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.moneyPayments,
    aliasName: $_aliasNameGenerator(
      db.moneyEntries.id,
      db.moneyPayments.moneyId,
    ),
  );

  $$MoneyPaymentsTableProcessedTableManager get moneyPaymentsRefs {
    final manager = $$MoneyPaymentsTableTableManager(
      $_db,
      $_db.moneyPayments,
    ).filter((f) => f.moneyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_moneyPaymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  ColumnFilters<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> moneyAttachmentsRefs(
    Expression<bool> Function($$MoneyAttachmentsTableFilterComposer f) f,
  ) {
    final $$MoneyAttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moneyAttachments,
      getReferencedColumn: (t) => t.moneyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyAttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.moneyAttachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> moneyPaymentsRefs(
    Expression<bool> Function($$MoneyPaymentsTableFilterComposer f) f,
  ) {
    final $$MoneyPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moneyPayments,
      getReferencedColumn: (t) => t.moneyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.moneyPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  ColumnOrderings<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  GeneratedColumn<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> moneyAttachmentsRefs<T extends Object>(
    Expression<T> Function($$MoneyAttachmentsTableAnnotationComposer a) f,
  ) {
    final $$MoneyAttachmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moneyAttachments,
      getReferencedColumn: (t) => t.moneyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyAttachmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.moneyAttachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> moneyPaymentsRefs<T extends Object>(
    Expression<T> Function($$MoneyPaymentsTableAnnotationComposer a) f,
  ) {
    final $$MoneyPaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moneyPayments,
      getReferencedColumn: (t) => t.moneyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyPaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.moneyPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (MoneyEntry, $$MoneyEntriesTableReferences),
          MoneyEntry,
          PrefetchHooks Function({
            bool moneyAttachmentsRefs,
            bool moneyPaymentsRefs,
          })
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
                Value<double> paidAmount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
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
                paidAmount: paidAmount,
                createdAt: createdAt,
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
                Value<double> paidAmount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
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
                paidAmount: paidAmount,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MoneyEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({moneyAttachmentsRefs = false, moneyPaymentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (moneyAttachmentsRefs) db.moneyAttachments,
                    if (moneyPaymentsRefs) db.moneyPayments,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (moneyAttachmentsRefs)
                        await $_getPrefetchedData<
                          MoneyEntry,
                          $MoneyEntriesTable,
                          MoneyAttachment
                        >(
                          currentTable: table,
                          referencedTable: $$MoneyEntriesTableReferences
                              ._moneyAttachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MoneyEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).moneyAttachmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.moneyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (moneyPaymentsRefs)
                        await $_getPrefetchedData<
                          MoneyEntry,
                          $MoneyEntriesTable,
                          MoneyPayment
                        >(
                          currentTable: table,
                          referencedTable: $$MoneyEntriesTableReferences
                              ._moneyPaymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MoneyEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).moneyPaymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.moneyId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
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
      (MoneyEntry, $$MoneyEntriesTableReferences),
      MoneyEntry,
      PrefetchHooks Function({
        bool moneyAttachmentsRefs,
        bool moneyPaymentsRefs,
      })
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

final class $$MoneyAttachmentsTableReferences
    extends
        BaseReferences<_$AppDatabase, $MoneyAttachmentsTable, MoneyAttachment> {
  $$MoneyAttachmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MoneyEntriesTable _moneyIdTable(_$AppDatabase db) =>
      db.moneyEntries.createAlias(
        $_aliasNameGenerator(db.moneyAttachments.moneyId, db.moneyEntries.id),
      );

  $$MoneyEntriesTableProcessedTableManager get moneyId {
    final $_column = $_itemColumn<int>('money_id')!;

    final manager = $$MoneyEntriesTableTableManager(
      $_db,
      $_db.moneyEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_moneyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

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

  $$MoneyEntriesTableFilterComposer get moneyId {
    final $$MoneyEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moneyId,
      referencedTable: $db.moneyEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyEntriesTableFilterComposer(
            $db: $db,
            $table: $db.moneyEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  $$MoneyEntriesTableOrderingComposer get moneyId {
    final $$MoneyEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moneyId,
      referencedTable: $db.moneyEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.moneyEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  $$MoneyEntriesTableAnnotationComposer get moneyId {
    final $$MoneyEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moneyId,
      referencedTable: $db.moneyEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.moneyEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
          (MoneyAttachment, $$MoneyAttachmentsTableReferences),
          MoneyAttachment,
          PrefetchHooks Function({bool moneyId})
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
              .map(
                (e) => (
                  e.readTable(table),
                  $$MoneyAttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({moneyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (moneyId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.moneyId,
                        referencedTable: $$MoneyAttachmentsTableReferences
                            ._moneyIdTable(db),
                        referencedColumn: $$MoneyAttachmentsTableReferences
                            ._moneyIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
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
      (MoneyAttachment, $$MoneyAttachmentsTableReferences),
      MoneyAttachment,
      PrefetchHooks Function({bool moneyId})
    >;
typedef $$MoneyPaymentsTableCreateCompanionBuilder =
    MoneyPaymentsCompanion Function({
      Value<int> id,
      required int moneyId,
      required double amount,
      required DateTime paidAt,
    });
typedef $$MoneyPaymentsTableUpdateCompanionBuilder =
    MoneyPaymentsCompanion Function({
      Value<int> id,
      Value<int> moneyId,
      Value<double> amount,
      Value<DateTime> paidAt,
    });

final class $$MoneyPaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $MoneyPaymentsTable, MoneyPayment> {
  $$MoneyPaymentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MoneyEntriesTable _moneyIdTable(_$AppDatabase db) =>
      db.moneyEntries.createAlias(
        $_aliasNameGenerator(db.moneyPayments.moneyId, db.moneyEntries.id),
      );

  $$MoneyEntriesTableProcessedTableManager get moneyId {
    final $_column = $_itemColumn<int>('money_id')!;

    final manager = $$MoneyEntriesTableTableManager(
      $_db,
      $_db.moneyEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_moneyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MoneyPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $MoneyPaymentsTable> {
  $$MoneyPaymentsTableFilterComposer({
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

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MoneyEntriesTableFilterComposer get moneyId {
    final $$MoneyEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moneyId,
      referencedTable: $db.moneyEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyEntriesTableFilterComposer(
            $db: $db,
            $table: $db.moneyEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoneyPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $MoneyPaymentsTable> {
  $$MoneyPaymentsTableOrderingComposer({
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

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MoneyEntriesTableOrderingComposer get moneyId {
    final $$MoneyEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moneyId,
      referencedTable: $db.moneyEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.moneyEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoneyPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoneyPaymentsTable> {
  $$MoneyPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  $$MoneyEntriesTableAnnotationComposer get moneyId {
    final $$MoneyEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moneyId,
      referencedTable: $db.moneyEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.moneyEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoneyPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoneyPaymentsTable,
          MoneyPayment,
          $$MoneyPaymentsTableFilterComposer,
          $$MoneyPaymentsTableOrderingComposer,
          $$MoneyPaymentsTableAnnotationComposer,
          $$MoneyPaymentsTableCreateCompanionBuilder,
          $$MoneyPaymentsTableUpdateCompanionBuilder,
          (MoneyPayment, $$MoneyPaymentsTableReferences),
          MoneyPayment,
          PrefetchHooks Function({bool moneyId})
        > {
  $$MoneyPaymentsTableTableManager(_$AppDatabase db, $MoneyPaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoneyPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoneyPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoneyPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> moneyId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> paidAt = const Value.absent(),
              }) => MoneyPaymentsCompanion(
                id: id,
                moneyId: moneyId,
                amount: amount,
                paidAt: paidAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int moneyId,
                required double amount,
                required DateTime paidAt,
              }) => MoneyPaymentsCompanion.insert(
                id: id,
                moneyId: moneyId,
                amount: amount,
                paidAt: paidAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MoneyPaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({moneyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (moneyId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.moneyId,
                        referencedTable: $$MoneyPaymentsTableReferences
                            ._moneyIdTable(db),
                        referencedColumn: $$MoneyPaymentsTableReferences
                            ._moneyIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MoneyPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoneyPaymentsTable,
      MoneyPayment,
      $$MoneyPaymentsTableFilterComposer,
      $$MoneyPaymentsTableOrderingComposer,
      $$MoneyPaymentsTableAnnotationComposer,
      $$MoneyPaymentsTableCreateCompanionBuilder,
      $$MoneyPaymentsTableUpdateCompanionBuilder,
      (MoneyPayment, $$MoneyPaymentsTableReferences),
      MoneyPayment,
      PrefetchHooks Function({bool moneyId})
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
  $$MoneyPaymentsTableTableManager get moneyPayments =>
      $$MoneyPaymentsTableTableManager(_db, _db.moneyPayments);
}
