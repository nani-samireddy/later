import 'dart:io';

import 'package:drift/native.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/database/app_database.dart';
import 'package:later/core/attachments/attachment_repository.dart';
import 'package:later/core/attachments/attachment_store.dart';
import 'package:later/core/attachments/stored_attachment.dart';
import 'package:later/features/capture/data/entry_capture_service.dart';
import 'package:later/features/money/data/money_repository.dart';

import 'support/fake_reminders.dart';

void main() {
  test('Thing and money attachments survive source deletion and database reopening; cleanup stays private', () async {
    final directory = await Directory.systemTemp.createTemp('later-files-');
    final store = AttachmentStore(
      directory: () async => Directory('${directory.path}/managed'),
    );
    final source = File('${directory.path}/receipt.pdf');
    await source.writeAsString('sample PDF bytes');
    final dbFile = File('${directory.path}/data.sqlite');
    var db = AppDatabase.withExecutor(NativeDatabase(dbFile));
    try {
      final thing = await db.addThing(
        ThingsCompanion.insert(
          title: 'Drill',
          category: 'Tool',
          iconCodePoint: Icons.bookmark.codePoint,
        ),
      );
      final money = await db.addMoney(
        MoneyEntriesCompanion.insert(
          person: 'Ravi',
          amount: 20,
          currency: 'INR',
          owedToMe: true,
        ),
      );
      var repo = AttachmentRepository(db, store: store);
      final selected = PlatformFile(
        name: 'receipt.pdf',
        size: await source.length(),
        path: source.path,
      );
      final thingFile = await repo.add(AttachmentOwner.thing, thing, selected);
      final moneyFile = await repo.add(AttachmentOwner.money, money, selected);
      expect(thingFile.path, isNot(moneyFile.path));
      await source.delete();
      await db.close();
      db = AppDatabase.withExecutor(NativeDatabase(dbFile));
      repo = AttachmentRepository(db, store: store);
      final loaded = (await repo.all(AttachmentOwner.thing, thing)).single;
      expect(loaded.name, 'receipt.pdf');
      expect(await File(loaded.path).readAsString(), 'sample PDF bytes');
      await repo.remove(AttachmentOwner.thing, loaded);
      expect(await File(loaded.path).exists(), isFalse);
      expect(await db.attachmentsFor(thing), isEmpty);
      await MoneyRepository(
        db,
        scheduler: FakeReminders(),
        store: store,
      ).delete(money);
      expect(await File(moneyFile.path).exists(), isFalse);
      expect(await db.moneyAttachmentsFor(money), isEmpty);
      final external = File('${directory.path}/keep.txt');
      await external.writeAsString('keep');
      await store.remove(external.path);
      expect(await external.exists(), isTrue);
    } finally {
      await db.close();
      await directory.delete(recursive: true);
    }
  });
  test('Failed attachment copy rolls back record and earlier copies', () async {
    final directory = await Directory.systemTemp.createTemp('later-rollback-');
    final store = AttachmentStore(
      directory: () async => Directory('${directory.path}/managed'),
    );
    final db = AppDatabase.withExecutor(NativeDatabase.memory());
    final source = File('${directory.path}/one.txt');
    await source.writeAsString('one');
    try {
      final service = EntryCaptureService(
        db,
        scheduler: FakeReminders(),
        store: store,
      );
      await expectLater(
        service.save(
          kind: 'thing',
          description: 'Item',
          category: 'General',
          amount: '',
          person: '',
          currency: 'INR',
          reminderTime: const TimeOfDay(hour: 9, minute: 0),
          attachments: [
            PlatformFile(name: 'one.txt', size: 3, path: source.path),
            PlatformFile(
              name: 'gone.txt',
              size: 3,
              path: '${directory.path}/gone.txt',
            ),
          ],
        ),
        throwsA(isA<FileSystemException>()),
      );
      expect(await db.allThings(), isEmpty);
      final files = await Directory('${directory.path}/managed')
          .list(recursive: true)
          .where((entity) => entity is File)
          .toList();
      expect(files, isEmpty);
    } finally {
      await db.close();
      await directory.delete(recursive: true);
    }
  });
  test('Schema 5 references migrate without losing the source; missing files remain removable', () async {
    final directory = await Directory.systemTemp.createTemp('later-migration-');
    final source = File('${directory.path}/legacy.pdf');
    await source.writeAsString('legacy');
    final store = AttachmentStore(
      directory: () async => Directory('${directory.path}/managed'),
    );
    final db = AppDatabase.withExecutor(
      NativeDatabase(
        File('${directory.path}/old.sqlite'),
        setup: (sqlite) {
          sqlite.execute(
            'CREATE TABLE things (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, category TEXT NOT NULL, icon_code_point INTEGER NOT NULL, reminder_date INTEGER)',
          );
          sqlite.execute(
            'CREATE TABLE attachments (id INTEGER PRIMARY KEY AUTOINCREMENT, thing_id INTEGER NOT NULL REFERENCES things(id), name TEXT NOT NULL)',
          );
          sqlite.execute('PRAGMA user_version = 5');
          sqlite.execute(
            "INSERT INTO things(title,category,icon_code_point) VALUES ('Old','General',0)",
          );
          sqlite.execute(
            'INSERT INTO attachments(thing_id,name) VALUES (1,?)',
            [source.path],
          );
          sqlite.execute(
            'INSERT INTO attachments(thing_id,name) VALUES (1,?)',
            ['${directory.path}/missing.pdf'],
          );
        },
      ),
    );
    try {
      final repo = AttachmentRepository(db, store: store);
      final files = await repo.all(AttachmentOwner.thing, 1);
      expect(files.first.name, 'legacy.pdf');
      expect(await store.owns(files.first.path), isTrue);
      expect(await source.exists(), isTrue);
      expect(await File(files.first.path).readAsString(), 'legacy');
      await repo.remove(AttachmentOwner.thing, files.last);
      expect((await db.attachmentsFor(1)).length, 1);
    } finally {
      await db.close();
      await directory.delete(recursive: true);
    }
  });
}
