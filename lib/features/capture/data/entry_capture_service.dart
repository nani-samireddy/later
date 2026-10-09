import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';

class EntryCaptureService {
  final AppDatabase database;
  EntryCaptureService(this.database);
  Future<bool> save({
    required String kind,
    required String description,
    required String category,
    required String amount,
    required String person,
    required String currency,
    required List<PlatformFile> attachments,
    DateTime? reminderDate,
    required TimeOfDay reminderTime,
  }) async {
    final text = description.trim();
    if (text.isEmpty) return false;
    if (kind == 'thing') {
      final thingId = await database.addThing(
        ThingsCompanion.insert(
          title: text,
          category: category.trim().isEmpty ? 'General' : category.trim(),
          iconCodePoint: Icons.bookmark_outline_rounded.codePoint,
          reminderDate: Value(
            reminderDate == null
                ? null
                : DateTime(
                    reminderDate.year,
                    reminderDate.month,
                    reminderDate.day,
                    reminderTime.hour,
                    reminderTime.minute,
                  ),
          ),
        ),
      );
      for (final file in attachments) {
        await database.addAttachment(
          AttachmentsCompanion.insert(
            thingId: thingId,
            name: file.path ?? file.name,
          ),
        );
      }
    } else {
      final parsedAmount = double.tryParse(amount.trim());
      if (parsedAmount == null || parsedAmount <= 0) {
        return false;
      }
      final moneyId = await database.addMoney(
        MoneyEntriesCompanion.insert(
          person: person.trim().isEmpty ? 'Unknown' : person.trim(),
          amount: parsedAmount,
          currency: currency,
          reason: Value(text),
          owedToMe: kind == 'owedToMe',
          kind: Value(kind == 'spending' ? 'spending' : 'debt'),
          dueDate: Value(
            reminderDate == null
                ? null
                : DateTime(
                    reminderDate.year,
                    reminderDate.month,
                    reminderDate.day,
                    reminderTime.hour,
                    reminderTime.minute,
                  ),
          ),
        ),
      );
      for (final file in attachments) {
        await database.addMoneyAttachment(
          MoneyAttachmentsCompanion.insert(
            moneyId: moneyId,
            name: file.name,
            path: file.path ?? file.name,
            kind: file.extension?.toLowerCase() == 'pdf' ? 'document' : 'image',
          ),
        );
      }
    }
    return true;
  }
}
