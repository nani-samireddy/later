import '../../../core/reminders/recurrence.dart';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/notifications/reminder_coordinator.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/notifications/reminder_scheduler.dart';
import '../../../core/attachments/attachment_repository.dart';
import '../../../core/attachments/attachment_store.dart';
import '../../../core/attachments/stored_attachment.dart';
import '../domain/entry_validation.dart';
import '../../money/domain/amount.dart';

class EntryCaptureService {
  final AppDatabase database;
  final ReminderScheduler? scheduler;
  final AttachmentStore store;
  EntryCaptureService(this.database, {this.scheduler, AttachmentStore? store})
    : store = store ?? AttachmentStore();
  Future<bool> save({
    String? title,
    required String kind,
    required String description,
    required String category,
    required String amount,
    required String person,
    required String currency,
    required List<PlatformFile> attachments,
    DateTime? reminderDate,
    ReminderRecurrence recurrence = ReminderRecurrence.none,
    required TimeOfDay reminderTime,
  }) async {
    if (reminderDate == null && recurrence != ReminderRecurrence.none) {
      return false;
    }
    if (validateEntry(
          kind: kind,
          description: title ?? description,
          person: person,
          amount: amount,
        ) !=
        null) {
      return false;
    }
    final date = reminderDate == null
        ? null
        : DateTime(
            reminderDate.year,
            reminderDate.month,
            reminderDate.day,
            reminderTime.hour,
            reminderTime.minute,
          );
    final copied = <StoredAttachment>[];
    final repository = AttachmentRepository(database, store: store);
    late int id;
    final owner = kind == 'thing'
        ? AttachmentOwner.thing
        : AttachmentOwner.money;
    try {
      await database.transaction(() async {
        if (kind == 'thing') {
          id = await database.addThing(
            ThingsCompanion.insert(
              title: (title ?? description).trim(),
              description: Value(title == null ? '' : description.trim()),
              category: category.trim().isEmpty ? 'General' : category.trim(),
              iconCodePoint: Icons.bookmark_outline_rounded.codePoint,
              reminderDate: Value(date),
            ),
          );
        } else {
          id = await database.addMoney(
            MoneyEntriesCompanion.insert(
              person: person.trim().isEmpty ? 'Spending' : person.trim(),
              amount: parseAmount(amount)!,
              currency: currency,
              reason: Value(description.trim()),
              owedToMe: kind == 'owedToMe',
              kind: Value(kind == 'spending' ? 'spending' : 'debt'),
              dueDate: Value(date),
            ),
          );
        }
        for (final file in attachments) {
          copied.add(await repository.add(owner, id, file));
        }
      });
    } catch (_) {
      for (final attachment in copied) {
        await store.remove(attachment.path);
      }
      rethrow;
    }
    final reminders = ReminderCoordinator(database, scheduler: scheduler);
    try {
      await reminders.configure(owner.name, id, recurrence);
    } catch (_) {
      // The record already committed. Reporting failure as unsaved permits
      // duplicate entries on retry; surface only the reminder failure.
      NotificationService.warnings.add(
        'Entry saved, but its reminder could not be updated. Check notification settings and try editing the reminder.',
      );
    }
    return true;
  }
}
