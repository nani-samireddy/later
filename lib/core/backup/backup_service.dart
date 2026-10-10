import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:drift/drift.dart' show DriftSqlType;
import 'package:path/path.dart' as p;

import '../attachments/attachment_store.dart';
import '../database/app_database.dart';
import '../notifications/reminder_coordinator.dart';
import '../notifications/reminder_scheduler.dart';
import '../notifications/notification_service.dart';

class BackupException implements Exception {
  final String message;
  const BackupException(this.message);
  @override
  String toString() => message;
}

/// A validated, immutable snapshot. Restore rechecks the installed schema.
class BackupPreview {
  final Map<String, List<Map<String, Object?>>> _tables;
  final Map<String, Uint8List> _files;
  final Map<String, Object?> _schema;
  final int schemaVersion;
  final DateTime createdAt;
  Map<String, int> get counts => Map.unmodifiable(
    _tables.map((name, rows) => MapEntry(name, rows.length)),
  );
  int get attachmentCount => _files.length;
  BackupPreview._(
    this._tables,
    this._files,
    this._schema,
    this.schemaVersion,
    this.createdAt,
  );
}

class BackupRestoreResult {
  final String? warning;
  const BackupRestoreResult({this.warning});
}

/// Format 1: bounded gzip JSON, validated installed table/column manifest, and
/// embedded private attachment bytes. SQL identifiers come only from the DB.
class BackupService {
  static const maxArchiveBytes = 64 * 1024 * 1024;
  static const maxDecodedBytes = 192 * 1024 * 1024;
  final AppDatabase database;
  final AttachmentStore store;
  final ReminderScheduler? scheduler;
  final Future<void> Function(List<int> things, List<int> money)? rebuild;
  final Future<void> Function()? beforeCommit;
  static final _busy = Expando<bool>();

  BackupService(
    this.database, {
    AttachmentStore? store,
    this.rebuild,
    this.scheduler,
    this.beforeCommit,
  }) : store = store ?? AttachmentStore();

  String _quote(String name) => '"${name.replaceAll('"', '""')}"';
  Future<Map<String, Object?>> _schema(AppDatabase db) async {
    final result = <String, Object?>{};
    final names = db.allTables.map((t) => t.actualTableName).toList()..sort();
    for (final name in names) {
      result[name] =
          (await db.customSelect('PRAGMA table_info(${_quote(name)})').get())
              .map(
                (r) => <String, Object?>{
                  for (final key in [
                    'name',
                    'type',
                    'notnull',
                    'dflt_value',
                    'pk',
                  ])
                    key: r.data[key],
                },
              )
              .toList()
            ..sort(
              (a, b) => (a['name'] as String).compareTo(b['name'] as String),
            );
    }
    return result;
  }

  Future<T> _exclusive<T>(Future<T> Function() work) async {
    if (_busy[database] == true) {
      throw const BackupException(
        'Another backup operation is running. Try again shortly.',
      );
    }
    _busy[database] = true;
    try {
      return await work();
    } finally {
      _busy[database] = false;
    }
  }

  Future<Uint8List> export() => _exclusive(() async {
    try {
      return await database.transaction(() async {
        final schema = await _schema(database);
        final tables = <String, Object?>{};
        final files = <String, Object?>{};
        var attachmentBytes = 0;
        final root = await store.directory();
        for (final name in schema.keys) {
          final rows =
              (await database
                      .customSelect('SELECT * FROM ${_quote(name)}')
                      .get())
                  .map((r) => Map<String, Object?>.from(r.data))
                  .toList();
          if (name == 'attachments' || name == 'money_attachments') {
            for (final row in rows) {
              final source = row['path'];
              if (source is! String || !await store.owns(source)) {
                throw const BackupException(
                  'An attachment is outside private storage. Reattach it before exporting.',
                );
              }
              final file = File(source);
              if (!await file.exists()) {
                throw const BackupException(
                  'An attachment is missing. Remove or reattach it before exporting.',
                );
              }
              if (!p.isWithin(
                await root.resolveSymbolicLinks(),
                await file.resolveSymbolicLinks(),
              )) {
                throw const BackupException(
                  'An attachment points outside private storage.',
                );
              }
              final key = 'files/${files.length}';
              attachmentBytes += await file.length();
              if (attachmentBytes > maxDecodedBytes ~/ 2) {
                throw const BackupException(
                  'Attachments are too large for local export.',
                );
              }
              final bytes = await file.readAsBytes();
              files[key] = {
                'length': bytes.length,
                'data': base64Encode(bytes),
              };
              row['path'] = key;
            }
          }
          tables[name] = rows;
        }
        final raw = utf8.encode(
          jsonEncode({
            'format': 'laterbackup',
            'version': 1,
            'schemaVersion': database.schemaVersion,
            'createdAt': DateTime.now().toUtc().toIso8601String(),
            'schema': schema,
            'tables': tables,
            'files': files,
          }),
        );
        if (raw.length > maxDecodedBytes) {
          throw const BackupException('Backup is too large for local export.');
        }
        final bytes = Uint8List.fromList(gzip.encode(raw));
        if (bytes.length > maxArchiveBytes) {
          throw const BackupException('Backup is too large for local export.');
        }
        return bytes;
      });
    } on BackupException {
      rethrow;
    } catch (_) {
      throw const BackupException(
        'Could not export the backup. Your data has not changed.',
      );
    }
  });

  Future<BackupPreview> preview(List<int> archive) => _exclusive(() async {
    try {
      if (archive.length > maxArchiveBytes) throw const FormatException();
      final sink = _BoundedSink(maxDecodedBytes);
      final decoder = gzip.decoder.startChunkedConversion(sink);
      decoder.add(archive);
      decoder.close();
      final value = jsonDecode(utf8.decode(sink.bytes.takeBytes()));
      if (value is! Map<String, dynamic> ||
          value.keys.toSet().difference({
            'format',
            'version',
            'schemaVersion',
            'createdAt',
            'schema',
            'tables',
            'files',
          }).isNotEmpty ||
          value.length != 7 ||
          value['format'] != 'laterbackup' ||
          (value['version'] is! int || value['version'] != 1)) {
        throw const FormatException();
      }
      final version = value['schemaVersion'];
      final currentSchema = await _schema(database);
      final schema = Map<String, Object?>.from(value['schema'] as Map);
      if (version is! int ||
          version < 8 ||
          version > database.schemaVersion ||
          !{
            'things',
            'attachments',
            'app_settings',
            'money_entries',
            'money_attachments',
          }.every(schema.containsKey) ||
          !schema.keys.every(currentSchema.containsKey)) {
        throw const BackupException(
          'This backup uses an unsupported database schema. Update Later or use the matching version. Nothing was restored.',
        );
      }
      for (final name in schema.keys) {
        final expected = {
          for (final c in currentSchema[name] as List) (c as Map)['name']: c,
        };
        final seen = <String>{};
        for (final c in schema[name] as List) {
          if (c is! Map ||
              c.length != 5 ||
              !{
                'name',
                'type',
                'notnull',
                'dflt_value',
                'pk',
              }.every(c.containsKey) ||
              c['name'] is! String ||
              c['type'] is! String ||
              c['notnull'] is! int ||
              c['pk'] is! int ||
              !seen.add(c['name'] as String) ||
              !expected.containsKey(c['name'])) {
            throw const FormatException();
          }
          final installed = expected[c['name']] as Map;
          if ((c['dflt_value'] != null && c['dflt_value'] is! String) ||
              !installed.keys
                  .where((key) => key != 'dflt_value')
                  .every((key) => c[key] == installed[key])) {
            throw const BackupException(
              'This backup has incompatible column definitions. Nothing was restored.',
            );
          }
        }
        for (final c in expected.values) {
          if (!seen.contains(c['name']) &&
              (version == database.schemaVersion ||
                  c['pk'] != 0 ||
                  (c['notnull'] == 1 && c['dflt_value'] == null))) {
            throw const BackupException(
              'This backup is missing required fields. Nothing was restored.',
            );
          }
        }
      }
      if (version == database.schemaVersion &&
          schema.length != currentSchema.length) {
        throw const FormatException();
      }
      final created = DateTime.parse(value['createdAt'] as String);
      if (created.toUtc().toIso8601String() != value['createdAt']) {
        throw const FormatException();
      }
      final inputTables = Map<String, dynamic>.from(value['tables'] as Map);
      if (inputTables.length != schema.length ||
          !schema.keys.every(inputTables.containsKey)) {
        throw const FormatException();
      }
      final tables = <String, List<Map<String, Object?>>>{};
      for (final name in schema.keys) {
        final dateColumns = database.allTables
            .firstWhere((t) => t.actualTableName == name)
            .$columns
            .where((c) => c.type == DriftSqlType.dateTime)
            .map((c) => c.$name)
            .toSet();
        final columns = (schema[name] as List)
            .map((c) => (c as Map)['name'] as String)
            .toSet();
        final rows = <Map<String, Object?>>[];
        for (final input in inputTables[name] as List) {
          final row = Map<String, Object?>.from(input as Map);
          if (row.length != columns.length || !columns.every(row.containsKey)) {
            throw const FormatException();
          }
          for (final column in schema[name] as List) {
            final c = column as Map;
            final cell = row[c['name']];
            if (cell != null &&
                dateColumns.contains(c['name']) &&
                (cell is! int ||
                    cell < -8640000000000 ||
                    cell > 8640000000000)) {
              throw const FormatException();
            }
            if (cell == null) {
              if (c['notnull'] == 1 || c['pk'] != 0) {
                throw const FormatException();
              }
            } else {
              final type = (c['type'] as String).toUpperCase();
              if ((type == 'INTEGER' && cell is! int) ||
                  (type == 'REAL' && (cell is! num || !cell.isFinite)) ||
                  (type == 'TEXT' && cell is! String) ||
                  !{'INTEGER', 'REAL', 'TEXT'}.contains(type)) {
                throw const FormatException();
              }
            }
          }
          if (columns.contains('id') &&
              (row['id'] is! int || (row['id'] as int) <= 0)) {
            throw const FormatException();
          }
          rows.add(row);
        }
        tables[name] = rows;
      }
      final files = <String, Uint8List>{};
      for (final entry in (value['files'] as Map).entries) {
        final key = entry.key as String;
        if (!RegExp(r'^files/(0|[1-9][0-9]*)$').hasMatch(key)) {
          throw const FormatException();
        }
        final info = entry.value as Map;
        if (info.length != 2 ||
            !info.containsKey('length') ||
            !info.containsKey('data')) {
          throw const FormatException();
        }
        final bytes = base64Decode(info['data'] as String);
        if (info['length'] is! int || info['length'] != bytes.length) {
          throw const FormatException();
        }
        files[key] = bytes;
      }
      final referenced = <String>{};
      for (final name in ['attachments', 'money_attachments']) {
        for (final row in tables[name] ?? <Map<String, Object?>>[]) {
          final key = row['path'];
          if (key is! String ||
              !files.containsKey(key) ||
              !referenced.add(key)) {
            throw const FormatException();
          }
        }
      }
      if (referenced.length != files.length) throw const FormatException();
      // Use installed SQL defaults for additive fields and empty new tables.
      // SQLite verifies CHECK, UNIQUE and foreign-key constraints in isolation.
      final validator = _BackupValidationDatabase();
      try {
        await _replace(validator, tables);
        // Generated row readers also validate DateTime ranges and adapters.
        for (final table in validator.allTables) {
          await validator.select(table).get();
        }
        final expanded = <String, List<Map<String, Object?>>>{};
        for (final name in currentSchema.keys) {
          expanded[name] =
              (await validator
                      .customSelect('SELECT * FROM ${_quote(name)}')
                      .get())
                  .map((r) => Map<String, Object?>.from(r.data))
                  .toList();
        }
        return BackupPreview._(
          expanded,
          files,
          currentSchema,
          database.schemaVersion,
          created,
        );
      } finally {
        await validator.close();
      }
    } on BackupException {
      rethrow;
    } catch (_) {
      throw const BackupException(
        'Invalid or incomplete backup. Nothing was restored; existing data is safe.',
      );
    }
  });

  Future<void> _replace(
    AppDatabase db,
    Map<String, List<Map<String, Object?>>> tables, {
    Future<void> Function()? check,
    Future<void> Function()? beforeReplace,
  }) => db.transaction(() async {
    await db.customStatement('PRAGMA defer_foreign_keys = ON');
    await beforeReplace?.call();
    for (final name in tables.keys) {
      await db.customStatement('DELETE FROM ${_quote(name)}');
    }
    for (final entry in tables.entries) {
      for (final row in entry.value) {
        await db.customStatement(
          'INSERT INTO ${_quote(entry.key)} (${row.keys.map(_quote).join(',')}) VALUES (${List.filled(row.length, '?').join(',')})',
          row.values.toList(),
        );
      }
    }
    if ((await db.customSelect('PRAGMA foreign_key_check').get()).isNotEmpty) {
      throw const FormatException();
    }
    await check?.call();
  });

  /// Call only after presenting a destructive replacement confirmation.
  Future<BackupRestoreResult> restore(
    BackupPreview preview,
  ) => _exclusive(() async {
    Directory? staged;
    final promoted = <File>[];
    final createdFolders = <Directory>[];
    var committed = false;
    try {
      if (preview.schemaVersion != database.schemaVersion ||
          jsonEncode(preview._schema) != jsonEncode(await _schema(database))) {
        throw const BackupException(
          'The database changed after preview. Select the backup again.',
        );
      }
      var oldThings = <int>[];
      var oldMoney = <int>[];
      final oldPaths = <String>{};
      final root = await store.directory();
      await root.create(recursive: true);
      staged = await Directory(
        p.join(
          root.path,
          'restore_${DateTime.now().microsecondsSinceEpoch}_${Random.secure().nextInt(1 << 32)}',
        ),
      ).create();
      final paths = <String, String>{};
      for (final entry in preview._files.entries) {
        final file = File(p.join(staged.path, p.basename(entry.key)));
        await file.writeAsBytes(entry.value, flush: true);
        paths[entry.key] = file.path;
      }
      final tables = preview._tables.map(
        (name, rows) => MapEntry(
          name,
          rows.map((r) => Map<String, Object?>.from(r)).toList(),
        ),
      );
      for (final name in ['attachments', 'money_attachments']) {
        for (final row in tables[name] ?? <Map<String, Object?>>[]) {
          final owner = name == 'attachments' ? 'thing' : 'money';
          final id = row[name == 'attachments' ? 'thing_id' : 'money_id'];
          final folder = Directory(p.join(root.path, owner, '$id'));
          final parent = folder.parent;
          if (!await parent.exists()) {
            await parent.create();
            createdFolders.add(parent);
          }
          if (!p.isWithin(
            await root.resolveSymbolicLinks(),
            await parent.resolveSymbolicLinks(),
          )) {
            throw const BackupException(
              'Attachment storage points outside private storage. Restore cancelled.',
            );
          }
          if (!await folder.exists()) {
            await folder.create();
            createdFolders.add(folder);
          }
          if (!p.isWithin(
            await root.resolveSymbolicLinks(),
            await folder.resolveSymbolicLinks(),
          )) {
            throw const BackupException(
              'Attachment storage points outside private storage. Restore cancelled.',
            );
          }
          final filename = p.basename(
            (row['name'] as String).replaceAll('\\', '/'),
          );
          final target = File(
            p.join(
              folder.path,
              '${p.basename(staged.path)}_${p.basename(row['path'] as String)}_$filename',
            ),
          );
          final moved = await File(paths[row['path']]!).rename(target.path);
          promoted.add(moved);
          row['path'] = target.path;
        }
      }
      await _replace(
        database,
        tables,
        check: beforeCommit,
        beforeReplace: () async {
          oldThings = (await database.allThings()).map((r) => r.id).toList();
          oldMoney = (await database.allMoney()).map((r) => r.id).toList();
          for (final name in ['attachments', 'money_attachments']) {
            final rows = await database
                .customSelect('SELECT path FROM ${_quote(name)}')
                .get();
            oldPaths.addAll(rows.map((r) => r.read<String>('path')));
          }
        },
      );
      committed = true;
      database.markTablesUpdated(database.allTables.toSet());
      String? warning;
      final subscription = NotificationService.warnings.stream.listen((
        message,
      ) {
        warning = message;
      });
      try {
        if (rebuild != null) {
          await rebuild!(oldThings, oldMoney);
        } else {
          final native = scheduler ?? const NotificationService();
          final coordinator = ReminderCoordinator(database, scheduler: native);
          // Coordinator.cancel clears record policies. Native cancellation
          // preserves the recurrence/snooze metadata we have just restored.
          for (final pair in [('thing', oldThings), ('money', oldMoney)]) {
            for (final id in pair.$2) {
              await native.cancel(reminderId(pair.$1, id));
              for (var i = 0; i < 12; i++) {
                await native.cancel(monthlyReminderId(pair.$1, id, i));
              }
            }
          }
          await coordinator.syncAll();
        }
        await Future<void>.delayed(Duration.zero);
      } catch (_) {
        warning = 'Reminders could not be rebuilt; check notification permissions and reopen Later.';
      } finally {
        await subscription.cancel();
      }
      // Old private files are removed only after the database commit. Never
      // remove external legacy files or follow a symlink out of private storage.
      for (final oldPath in oldPaths) {
        try {
          final file = File(oldPath);
          if (await store.owns(oldPath) &&
              await file.exists() &&
              p.isWithin(
                await root.resolveSymbolicLinks(),
                await file.resolveSymbolicLinks(),
              )) {
            await file.delete();
          }
        } catch (_) {
          warning ??= 'Some replaced attachment files could not be removed from private storage.';
        }
      }
      return BackupRestoreResult(
        warning: warning == null ? null : 'Data restored. $warning',
      );
    } on BackupException {
      rethrow;
    } catch (_) {
      throw const BackupException(
        'Restore failed. Existing records and attachments were preserved.',
      );
    } finally {
      if (!committed) {
        for (final file in promoted) {
          try {
            if (await file.exists()) {
              await file.delete();
            }
          } catch (_) {
            /* Leave an unreferenced private copy if the OS prevents cleanup. */
          }
        }
        for (final folder in createdFolders.reversed) {
          try {
            if (await folder.exists() && await folder.list().isEmpty) {
              await folder.delete();
            }
          } catch (_) {
            /* Preserve other files. */
          }
        }
      }
      try {
        if (staged != null && await staged.exists()) {
          await staged.delete(recursive: true);
        }
      } catch (_) {
        /* Cleanup must not misreport a committed restore as failed. */
      }
    }
  });
}

class _BoundedSink implements Sink<List<int>> {
  final int limit;
  final bytes = BytesBuilder(copy: false);
  int length = 0;
  _BoundedSink(this.limit);
  @override
  void add(List<int> data) {
    length += data.length;
    if (length > limit) {
      throw const FormatException('Archive exceeds size limit');
    }
    bytes.add(data);
  }

  @override
  void close() {}
}

// A distinct runtime type avoids Drift's debug warning for concurrently
// instantiated AppDatabase objects; this executor is always isolated.
class _BackupValidationDatabase extends AppDatabase {
  _BackupValidationDatabase() : super.withExecutor(NativeDatabase.memory());
}
