import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/attachments/attachment_store.dart';
import 'package:later/core/attachments/stored_attachment.dart';
import 'package:later/core/backup/backup_service.dart';
import 'package:later/core/database/app_database.dart';
import 'package:later/core/notifications/reminder_scheduler.dart';
import 'package:later/core/notifications/notification_service.dart';

import 'support/fake_reminders.dart';

void main() {
  late Directory temp;
  late AppDatabase db;
  late AttachmentStore store;
  late BackupService service;
  late List<int> cancelled;
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('backup-test-');
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    store = AttachmentStore(
      directory: () async => Directory('${temp.path}/private'),
    );
    cancelled = [];
    service = BackupService(
      db,
      store: store,
      rebuild: (things, money) async {
        cancelled.addAll(things);
      },
    );
  });
  tearDown(() async {
    await db.close();
    await temp.delete(recursive: true);
  });

  Future<void> seed() async {
    await db.saveSetting('currency', 'INR');
    final id = await db.addThing(
      ThingsCompanion.insert(
        title: 'Private item',
        category: 'Other',
        iconCodePoint: 12,
        description: const Value('Full description'),
        status: const Value('completed'),
        completedAt: Value(DateTime(2026, 10, 1)),
        reminderDate: Value(DateTime(2030)),
      ),
    );
    final root = await store.directory();
    await root.create(recursive: true);
    final file = File('${root.path}/receipt.pdf');
    await file.writeAsBytes([0, 1, 2, 255]);
    await db.addAttachment(
      AttachmentsCompanion.insert(
        thingId: id,
        name: 'receipt.pdf',
        path: Value(file.path),
      ),
    );
    final money = await db.addMoney(
      MoneyEntriesCompanion.insert(
        person: 'Sam',
        amount: 12.34,
        currency: 'INR',
        owedToMe: true,
        reason: const Value('Lunch'),
        dueDate: Value(DateTime(2030)),
        kind: const Value('debt'),
      ),
    );
    await db.customStatement(
      'UPDATE money_entries SET paid_amount = 3 WHERE id = ?',
      [money],
    );
    await db.customStatement(
      'INSERT INTO money_payments (money_id, amount, paid_at) VALUES (?, ?, ?)',
      [money, 3, 1800000000],
    );
    await db.saveSetting(
      'reminder:money:$money',
      jsonEncode({
        'recurrence': 'monthly',
        'anchor': DateTime(2030).toIso8601String(),
        'snoozedUntil': DateTime(2030, 1, 2).toIso8601String(),
      }),
    );
    final moneyFile = File('${root.path}/money.txt');
    await moneyFile.writeAsString('Money attachment');
    await db.addMoneyAttachment(
      MoneyAttachmentsCompanion.insert(
        moneyId: money,
        name: 'money.txt',
        path: moneyFile.path,
        kind: 'document',
      ),
    );
  }

  List<int> mutate(
    List<int> archive,
    void Function(Map<String, dynamic>) edit,
  ) {
    final value =
        jsonDecode(utf8.decode(gzip.decode(archive))) as Map<String, dynamic>;
    edit(value);
    return gzip.encode(utf8.encode(jsonEncode(value)));
  }

  test(
    'round trip preserves every table column and private attachment bytes',
    () async {
      await seed();
      final archive = await service.export();
      final preview = await service.preview(archive);
      expect(preview.attachmentCount, 2);
      expect(preview.counts['app_settings'], 2);
      await db.saveSetting('currency', 'USD');
      final extra = await db.addThing(
        ThingsCompanion.insert(
          title: 'Replace me',
          category: 'Other',
          iconCodePoint: 1,
        ),
      );
      await service.restore(preview);
      expect(cancelled, contains(extra));
      expect(await db.setting('currency'), 'INR');
      final row = (await db.allThings()).single;
      expect(row.description, 'Full description');
      expect(row.status, 'completed');
      expect(row.completedAt, DateTime(2026, 10, 1));
      final attachment = (await db.attachmentsFor(row.id)).single;
      expect(await store.owns(attachment.path), isTrue);
      expect(attachment.path, endsWith('.pdf'));
      expect(
        (await db.customSelect('SELECT * FROM money_payments').get()).single
            .read<double>('amount'),
        3,
      );
      expect((await db.allMoney()).single.paidAmount, 3);
      expect(await File(attachment.path).readAsBytes(), [0, 1, 2, 255]);
      final again =
          jsonDecode(utf8.decode(gzip.decode(await service.export()))) as Map;
      final original = jsonDecode(utf8.decode(gzip.decode(archive))) as Map;
      expect(again['tables'], original['tables']);
      expect(again['files'], original['files']);
    },
  );

  test('corrupt, truncated, missing files, unsafe paths and schema mismatch preserve live data', () async {
    await seed();
    final archive = await service.export();
    final invalid = <List<int>>[
      [1, 2, 3],
      archive.sublist(0, archive.length ~/ 2),
      mutate(archive, (v) => (v['files'] as Map).clear()),
      mutate(
        archive,
        (v) => (v['tables']['attachments'][0] as Map)['path'] = '../escape',
      ),
      mutate(archive, (v) {
        final files = v['files'] as Map;
        files['files/../../escape'] = files.remove('files/0');
      }),
      mutate(archive, (v) => v['schemaVersion'] = 999),
      mutate(archive, (v) => v['version'] = 1.0),
      mutate(archive, (v) => v['tables']['things'][0]['id'] = -1),
      mutate(
        archive,
        (v) => v['tables']['things'][0]['reminder_date'] = 9223372036854775807,
      ),
      mutate(archive, (v) => v['tables']['things'][0]['title'] = 4),
      mutate(archive, (v) => v['tables']['attachments'][0]['thing_id'] = 999),
      mutate(
        archive,
        (v) => v['tables']['things'].add(v['tables']['things'][0]),
      ),
      mutate(archive, (v) => v['files']['files/0']['length'] = 900),
      mutate(archive, (v) => v['tables']['money_entries'][0]['owed_to_me'] = 9),
      mutate(archive, (v) {
        v['schema']['evil; DROP TABLE things'] = [];
        v['tables']['evil; DROP TABLE things'] = [];
      }),
    ];
    for (final bytes in invalid) {
      await expectLater(
        service.preview(bytes),
        throwsA(isA<BackupException>()),
      );
      expect((await db.allThings()).single.title, 'Private item');
      expect(await db.setting('currency'), 'INR');
    }
    expect(cancelled, isEmpty);
  });

  test(
    'transaction failure rolls back records and removes staged files',
    () async {
      await seed();
      final preview = await service.preview(await service.export());
      await db.saveSetting('currency', 'USD');
      final originalPath = (await db.attachmentsFor(1)).single.path;
      final failing = BackupService(
        db,
        store: store,
        beforeCommit: () async {
          throw StateError('Injected failure');
        },
        rebuild: (_, _) async {
          fail('No reminders before commit');
        },
      );
      await expectLater(
        failing.restore(preview),
        throwsA(isA<BackupException>()),
      );
      expect(await db.setting('currency'), 'USD');
      expect((await db.attachmentsFor(1)).single.path, originalPath);
      expect(await File(originalPath).exists(), isTrue);
      expect(
        (await (await store.directory()).list().toList())
            .whereType<Directory>(),
        isEmpty,
      );
    },
  );

  test('missing or external source files abort export', () async {
    await seed();
    final attachment = (await db.attachmentsFor(1)).single;
    await File(attachment.path).delete();
    await expectLater(service.export(), throwsA(isA<BackupException>()));
    final external = File('${temp.path}/external');
    await external.writeAsString('private');
    await db.customStatement('UPDATE attachments SET path = ?', [
      external.path,
    ]);
    await expectLater(service.export(), throwsA(isA<BackupException>()));
    expect(await external.readAsString(), 'private');
  });

  test('notification failure reports committed restore accurately', () async {
    await seed();
    final preview = await service.preview(await service.export());
    await db.saveSetting('currency', 'USD');
    final failing = BackupService(
      db,
      store: store,
      rebuild: (_, _) async {
        throw StateError('Notifications unavailable');
      },
    );
    final result = await failing.restore(preview);
    expect(result.warning, contains('Data restored'));
    expect(await db.setting('currency'), 'INR');
  });
  test('compatible schema 8 backup gets installed defaults and empty payment history', () async {
    await seed();
    final archive = mutate(await service.export(), (v) {
      v['schemaVersion'] = 8;
      (v['schema'] as Map).remove('money_payments');
      (v['tables'] as Map).remove('money_payments');
      (v['schema']['money_entries'] as List).removeWhere(
        (c) => ['paid_amount', 'created_at'].contains(c['name']),
      );
      for (final row in v['tables']['money_entries'] as List) {
        (row as Map).remove('paid_amount');
        row.remove('created_at');
      }
    });
    final preview = await service.preview(archive);
    expect(preview.counts['money_payments'], 0);
    await service.restore(preview);
    expect((await db.allMoney()).single.paidAmount, 0);
    expect(
      await db.customSelect('SELECT * FROM money_payments').get(),
      isEmpty,
    );
  });

  test(
    'symlink source and restore folder cannot escape private storage',
    () async {
      await seed();
      final preview = await service.preview(await service.export());
      final outside = Directory('${temp.path}/outside');
      await outside.create();
      final linked = Link('${(await store.directory()).path}/thing');
      await linked.create(outside.path);
      await expectLater(
        service.restore(preview),
        throwsA(isA<BackupException>()),
      );
      expect(await outside.list().toList(), isEmpty);
      expect((await db.allThings()).single.title, 'Private item');
      await linked.delete();
      final external = File('${outside.path}/external.txt');
      await external.writeAsString('Do not read');
      final sourceLink = Link('${(await store.directory()).path}/linked.txt');
      await sourceLink.create(external.path);
      await db.customStatement('UPDATE attachments SET path = ?', [
        sourceLink.path,
      ]);
      await expectLater(service.export(), throwsA(isA<BackupException>()));
      expect(await external.readAsString(), 'Do not read');
    },
  );

  test('restored files follow normal record deletion layout', () async {
    await seed();
    await service.restore(await service.preview(await service.export()));
    final attachment = (await db.attachmentsFor(1)).single;
    await store.removeRecord(AttachmentOwner.thing, 1);
    expect(await File(attachment.path).exists(), isFalse);
  });
  test('real reminder rebuild cancels replaced IDs and restores recurrence and snooze', () async {
    await seed();
    final preview = await service.preview(await service.export());
    final extra = await db.addThing(
      ThingsCompanion.insert(
        title: 'Old notification',
        category: 'Other',
        iconCodePoint: 1,
        reminderDate: Value(DateTime(2030)),
      ),
    );
    final fake = FakeReminders();
    fake.pending[reminderId('thing', extra)] = (
      date: DateTime(2030),
      payload: 'thing:$extra',
    );
    final restoring = BackupService(db, store: store, scheduler: fake);
    final result = await restoring.restore(preview);
    expect(result.warning, isNull);
    expect(fake.pending.containsKey(reminderId('thing', extra)), isFalse);
    expect(fake.pending[reminderId('money', 1)]?.date, DateTime(2030, 1, 2));
    expect(fake.pending[reminderId('money', 1)]?.payload, 'money:1');
    expect(
      fake.pending[monthlyReminderId('money', 1, 0)]?.date,
      DateTime(2030, 2, 1),
    );
    expect(fake.pending.length, 13);
    expect(await db.setting('reminder:money:1'), contains('monthly'));
  });

  test(
    'notification adapter warning is surfaced after committed restore',
    () async {
      await seed();
      final preview = await service.preview(await service.export());
      final restoring = BackupService(
        db,
        store: store,
        rebuild: (_, _) async {
          NotificationService.warnings.add('Permission denied');
        },
      );
      final result = await restoring.restore(preview);
      expect(result.warning, 'Data restored. Permission denied');
    },
  );

  test(
    'attachment staging I/O failure preserves records and original files',
    () async {
      await seed();
      final preview = await service.preview(await service.export());
      final originalPath = (await db.attachmentsFor(1)).single.path;
      final blocked = File('${temp.path}/not-a-directory');
      await blocked.writeAsString('Keep');
      final restoring = BackupService(
        db,
        store: AttachmentStore(directory: () async => Directory(blocked.path)),
      );
      await expectLater(
        restoring.restore(preview),
        throwsA(isA<BackupException>()),
      );
      expect((await db.allThings()).single.title, 'Private item');
      expect((await db.attachmentsFor(1)).single.path, originalPath);
      expect(await File(originalPath).exists(), isTrue);
      expect(await blocked.readAsString(), 'Keep');
    },
  );
}
