import 'dart:io';

import 'package:later/core/attachments/attachment_store.dart';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:later/core/database/app_database.dart';
import 'package:later/features/money/data/money_repository.dart';
import 'package:later/features/money/domain/money_totals.dart';

import 'support/fake_reminders.dart';

void main() {
  test(
    'repayments persist, validate, settle, correct, reopen and delete',
    () async {
      final dir = await Directory.systemTemp.createTemp('repayments');
      final file = File('${dir.path}/db.sqlite');
      var db = AppDatabase.withExecutor(NativeDatabase(file));
      final scheduler = FakeReminders();
      var repo = MoneyRepository(
        db,
        scheduler: scheduler,
        store: AttachmentStore(directory: () async => dir),
      );
      final id = await db.addMoney(
        MoneyEntriesCompanion.insert(
          person: 'A',
          amount: 100,
          currency: 'INR',
          owedToMe: true,
          dueDate: Value(DateTime(2090)),
        ),
      );
      await repo.savePayment(id, 30);
      expect(summarizeMoney(await db.allMoney())['INR']!.owedToYou, 70);
      for (final amount in [
        0.0,
        -1.0,
        double.nan,
        double.infinity,
        1.234,
        71.0,
      ]) {
        await expectLater(repo.savePayment(id, amount), throwsArgumentError);
      }
      await db.close();
      db = AppDatabase.withExecutor(NativeDatabase(file));
      repo = MoneyRepository(
        db,
        scheduler: scheduler,
        store: AttachmentStore(directory: () async => dir),
      );
      expect((await repo.find(id)).paidAmount, 30);
      final payment = (await repo.paymentsFor(id)).single;
      await expectLater(
        repo.edit(
          await repo.find(id),
          person: 'A',
          amount: 20,
          reason: '',
          owedToMe: true,
          moneyKind: 'owedToMe',
          dueDate: DateTime(2090),
          reminderTime: const TimeOfDay(hour: 9, minute: 0),
        ),
        throwsArgumentError,
      );
      await expectLater(
        repo.edit(
          await repo.find(id),
          person: 'Shop',
          amount: 100,
          reason: '',
          owedToMe: false,
          moneyKind: 'spending',
          dueDate: null,
          reminderTime: const TimeOfDay(hour: 9, minute: 0),
        ),
        throwsArgumentError,
      );
      await repo.setSettled(id, true);
      expect((await repo.find(id)).settled, true);
      expect(scheduler.pending, isEmpty);
      await repo.savePayment(id, 20, paymentId: payment.id);
      expect((await repo.find(id)).settled, false);
      expect(summarizeMoney(await db.allMoney())['INR']!.owedToYou, 10);
      expect(scheduler.pending, isNotEmpty);
      await repo.deletePayment(id, payment.id);
      expect((await repo.find(id)).paidAmount, 70);
      await repo.setSettled(id, false);
      expect(await repo.paymentsFor(id), isEmpty);
      expect(summarizeMoney(await db.allMoney())['INR']!.owedToYou, 100);
      await repo.savePayment(id, 25);
      await repo.delete(id);
      expect(await db.select(db.moneyPayments).get(), isEmpty);
      expect(await db.allMoney(), isEmpty);
      await db.close();
      await dir.delete(recursive: true);
    },
  );

  test(
    'version 8 migration preserves legacy settlement and creates history',
    () async {
      final db = AppDatabase.withExecutor(
        NativeDatabase.memory(
          setup: (old) {
            old.execute(
              'CREATE TABLE money_entries (id INTEGER PRIMARY KEY AUTOINCREMENT, person TEXT NOT NULL, amount REAL NOT NULL, currency TEXT NOT NULL, reason TEXT NOT NULL DEFAULT \'\', owed_to_me INTEGER NOT NULL, due_date INTEGER, settled INTEGER NOT NULL DEFAULT 0, kind TEXT NOT NULL DEFAULT \'debt\')',
            );
            old.execute(
              "INSERT INTO money_entries(person, amount, currency, owed_to_me, settled) VALUES ('A', 100, 'USD', 1, 1)",
            );
            old.execute('PRAGMA user_version = 8');
          },
        ),
      );
      final entry = (await db.allMoney()).single;
      expect(entry.settled, true);
      expect(entry.paidAmount, 0);
      expect(entry.createdAt.year, greaterThan(2020));
      expect(summarizeMoney([entry])['USD']!.owedToYou, 0);
      expect(await db.select(db.moneyPayments).get(), isEmpty);
      await db.close();
    },
  );

  test(
    'monthly spending remains separate across months and currencies',
    () async {
      final db = AppDatabase.withExecutor(NativeDatabase.memory());
      for (final row in [
        (10.0, 'INR', DateTime(2026, 1, 1)),
        (20.0, 'USD', DateTime(2026, 1, 2)),
        (30.0, 'INR', DateTime(2026, 2, 1)),
      ]) {
        await db.addMoney(
          MoneyEntriesCompanion.insert(
            person: 'Shop',
            amount: row.$1,
            currency: row.$2,
            owedToMe: false,
            kind: const Value('spending'),
            createdAt: Value(row.$3),
          ),
        );
      }
      final months = summarizeSpendingByMonth(await db.allMoney());
      expect(months[DateTime(2026, 1)]!['INR']!.spending, 10);
      expect(months[DateTime(2026, 1)]!['USD']!.spending, 20);
      expect(months[DateTime(2026, 2)]!['INR']!.spending, 30);
      await db.close();
    },
  );
}
