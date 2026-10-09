import 'package:file_picker/file_picker.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/notifications/notification_service.dart';

class MoneyRepository {
  final AppDatabase database;
  MoneyRepository(this.database);
  Future<List<MoneyAttachment>> attachmentsFor(int id) =>
      database.moneyAttachmentsFor(id);
  Future<MoneyEntry> find(int id) async =>
      (await database.allMoney()).firstWhere((item) => item.id == id);
  Future<void> setSettled(int id, bool settled) =>
      database.updateMoney(id, MoneyEntriesCompanion(settled: Value(settled)));
  Future<void> addAttachment(int id, PlatformFile file) async {
    await database.addMoneyAttachment(
      MoneyAttachmentsCompanion.insert(
        moneyId: id,
        name: file.name,
        path: file.path!,
        kind: file.extension?.toLowerCase() == 'pdf' ? 'document' : 'image',
      ),
    );
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
    await database.updateMoney(
      entry.id,
      MoneyEntriesCompanion(
        person: Value(person),
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
    await NotificationService.cancel(entry.id);
    if (dueDate != null && !entry.settled) {
      await NotificationService.schedule(
        id: entry.id,
        title: 'Money reminder',
        body: owedToMe
            ? '$person owes you ${entry.currency} ${amount.toStringAsFixed(0)}'
            : 'You owe $person ${entry.currency} ${amount.toStringAsFixed(0)}',
        date: dueDate,
      );
    }
  }
}
