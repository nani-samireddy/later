import 'package:later/core/attachments/attachment_store.dart';

import 'support/fake_reminders.dart';

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/database/app_database.dart';
import 'package:later/features/home/data/home_repository.dart';
import 'package:later/features/things/data/things_repository.dart';

void main() {
  test('Thing edits, icon and attachments survive reopening; deletion removes children', () async {
    final directory = await Directory.systemTemp.createTemp('later-records-');
    final file = File('${directory.path}/records.sqlite');
    var database = AppDatabase.withExecutor(NativeDatabase(file));
    try {
      expect(await HomeRepository(database).loadThings(), isEmpty);
      final id = await database.addThing(
        ThingsCompanion.insert(
          title: 'Drill',
          category: 'Tools',
          iconCodePoint: Icons.handyman_outlined.codePoint,
        ),
      );
      await database.addAttachment(
        AttachmentsCompanion.insert(thingId: id, name: 'receipt.pdf'),
      );
      await ThingsRepository(database, scheduler: FakeReminders()).edit(
        id,
        'Bosch drill',
        'Workshop',
        description: 'Warranty until next June',
      );
      await database.close();
      database = AppDatabase.withExecutor(NativeDatabase(file));
      final thing = (await ThingsRepository(
        database,
        scheduler: FakeReminders(),
      ).find(id))!;
      expect(thing.id, id);
      expect(thing.title, 'Bosch drill');
      expect(thing.category, 'Workshop');
      expect(thing.description, 'Warranty until next June');
      expect(thing.icon, Icons.handyman_outlined);
      expect(thing.attachments, ['receipt.pdf']);
      await ThingsRepository(
        database,
        scheduler: FakeReminders(),
        store: AttachmentStore(
          directory: () async => Directory('${directory.path}/attachments'),
        ),
      ).delete(id);
      expect(await database.allThings(), isEmpty);
      expect(await database.attachmentsFor(id), isEmpty);
      expect(await HomeRepository(database).loadThings(), isEmpty);
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });
  test('Deleting money removes its attachment rows', () async {
    final database = AppDatabase.withExecutor(NativeDatabase.memory());
    try {
      final id = await database.addMoney(
        MoneyEntriesCompanion.insert(
          person: 'Ravi',
          amount: 500,
          currency: 'INR',
          owedToMe: true,
        ),
      );
      await database.addMoneyAttachment(
        MoneyAttachmentsCompanion.insert(
          moneyId: id,
          name: 'receipt',
          path: '/receipt',
          kind: 'image',
        ),
      );
      await database.deleteMoney(id);
      expect(await database.allMoney(), isEmpty);
      expect(await database.moneyAttachmentsFor(id), isEmpty);
    } finally {
      await database.close();
    }
  });
}
