import '../../../core/attachments/attachment_store.dart';
import '../../../core/attachments/stored_attachment.dart';
import '../../../core/attachments/attachment_repository.dart';

import 'package:file_picker/file_picker.dart';
import 'package:drift/drift.dart'
    show Value, OrderingTerm, BooleanExpressionOperators;
import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/notifications/reminder_coordinator.dart';
import '../../../core/notifications/reminder_scheduler.dart';

class MoneyRepository {
  final AppDatabase database;
  final AttachmentStore store;
  final ReminderScheduler? scheduler;
  late final ReminderCoordinator reminders = ReminderCoordinator(
    database,
    scheduler: scheduler,
  );
  MoneyRepository(this.database, {this.scheduler, AttachmentStore? store})
    : store = store ?? AttachmentStore();
  Future<void> delete(int id) async {
    await reminders.forget('money', id);
    await database.deleteMoney(id);
    await store.removeRecord(AttachmentOwner.money, id);
  }

  Future<List<MoneyAttachment>> attachmentsFor(int id) =>
      database.moneyAttachmentsFor(id);
  Future<MoneyEntry> find(int id) async =>
      (await database.allMoney()).firstWhere((item) => item.id == id);
  Future<List<MoneyPayment>> paymentsFor(int id) =>
      (database.select(database.moneyPayments)
            ..where((p) => p.moneyId.equals(id))
            ..orderBy([
              (p) => OrderingTerm.desc(p.paidAt),
              (p) => OrderingTerm.desc(p.id),
            ]))
          .get();

  Future<void> _refreshBalance(int id) async {
    final entry = await find(id);
    final payments = await paymentsFor(id);
    final paid = payments.fold<double>(0, (sum, p) => sum + p.amount);
    await database.updateMoney(
      id,
      MoneyEntriesCompanion(
        paidAmount: Value(paid),
        settled: Value(paid >= entry.amount - 0.000001),
      ),
    );
  }

  Future<void> savePayment(
    int moneyId,
    double amount, {
    int? paymentId,
    DateTime? paidAt,
  }) async {
    if (!amount.isFinite ||
        amount <= 0 ||
        (amount * 100 - (amount * 100).round()).abs() > 0.000001) {
      throw ArgumentError('Enter a positive amount with at most two decimals');
    }
    await database.transaction(() async {
      final entry = await find(moneyId);
      final payments = await paymentsFor(moneyId);
      if (entry.kind != 'debt') {
        throw ArgumentError('Spending cannot have repayments');
      }
      if (paymentId != null && !payments.any((p) => p.id == paymentId)) {
        throw ArgumentError('Payment not found');
      }
      final other = payments
          .where((p) => p.id != paymentId)
          .fold<double>(0, (sum, p) => sum + p.amount);
      if (other + amount > entry.amount + 0.000001) {
        throw ArgumentError('Payment exceeds remaining balance');
      }
      if (paymentId == null) {
        await database
            .into(database.moneyPayments)
            .insert(
              MoneyPaymentsCompanion.insert(
                moneyId: moneyId,
                amount: amount,
                paidAt: paidAt ?? DateTime.now(),
              ),
            );
      } else {
        await (database.update(
          database.moneyPayments,
        )..where((p) => p.id.equals(paymentId))).write(
          MoneyPaymentsCompanion(
            amount: Value(amount),
            paidAt: paidAt == null ? const Value.absent() : Value(paidAt),
          ),
        );
      }
      await _refreshBalance(moneyId);
    });
    await reminders.syncMoney(moneyId);
  }

  Future<void> deletePayment(int moneyId, int paymentId) async {
    await database.transaction(() async {
      await (database.delete(
        database.moneyPayments,
      )..where((p) => p.id.equals(paymentId) & p.moneyId.equals(moneyId))).go();
      await _refreshBalance(moneyId);
    });
    await reminders.syncMoney(moneyId);
  }

  Future<void> setSettled(int id, bool settled) async {
    final entry = await find(id);
    if (settled) {
      final remaining = entry.amount - entry.paidAmount;
      if (remaining > 0) await savePayment(id, remaining);
    } else {
      await database.transaction(() async {
        await (database.delete(
          database.moneyPayments,
        )..where((p) => p.moneyId.equals(id))).go();
        await database.updateMoney(
          id,
          const MoneyEntriesCompanion(
            paidAmount: Value(0),
            settled: Value(false),
          ),
        );
      });
      await reminders.syncMoney(id);
    }
  }

  Future<void> addAttachment(int id, PlatformFile file) async {
    await AttachmentRepository(
      database,
      store: store,
    ).add(AttachmentOwner.money, id, file);
  }

  Future<void> edit(
    MoneyEntry entry, {
    required String person,
    required double amount,
    required String reason,
    required bool owedToMe,
    required String moneyKind,
    required DateTime? dueDate,
    required TimeOfDay reminderTime,
  }) async {
    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError('Invalid amount');
    }
    if (!{'owedToMe', 'iOwe', 'spending'}.contains(moneyKind) ||
        (moneyKind != 'spending' && person.trim().isEmpty)) {
      throw ArgumentError('Choose a type and enter a person');
    }
    final current = await find(entry.id);
    if (amount < current.paidAmount ||
        (moneyKind == 'spending' && current.paidAmount > 0)) {
      throw ArgumentError(
        'Correct repayments before reducing the amount or changing to spending',
      );
    }
    await database.updateMoney(
      entry.id,
      MoneyEntriesCompanion(
        person: Value(person.trim().isEmpty ? 'Spending' : person.trim()),
        settled: Value(
          moneyKind == 'spending' || entry.kind == 'spending'
              ? false
              : current.paidAmount > 0
              ? current.paidAmount >= amount
              : current.settled,
        ),
        amount: Value(amount),
        reason: Value(reason),
        owedToMe: Value(owedToMe),
        kind: Value(moneyKind == 'spending' ? 'spending' : 'debt'),
        dueDate: Value(
          dueDate == null
              ? null
              : DateTime(
                  dueDate.year,
                  dueDate.month,
                  dueDate.day,
                  reminderTime.hour,
                  reminderTime.minute,
                ),
        ),
      ),
    );
    await reminders.syncMoney(entry.id);
  }
}
