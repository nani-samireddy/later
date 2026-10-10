import '../../../core/attachments/attachment_store.dart';
import '../../../core/attachments/stored_attachment.dart';
import '../../../core/notifications/reminder_coordinator.dart';
import '../../../core/notifications/reminder_scheduler.dart';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart' as db;
import '../domain/thing.dart';

class ThingsRepository {
  final db.AppDatabase database;
  late final ReminderCoordinator reminders = ReminderCoordinator(
    database,
    scheduler: scheduler,
  );
  final AttachmentStore store;
  final ReminderScheduler? scheduler;
  ThingsRepository(this.database, {this.scheduler, AttachmentStore? store})
    : store = store ?? AttachmentStore();
  Future<Thing> map(db.Thing row) async => Thing(
    id: row.id,
    status: ThingStatus.values.firstWhere(
      (status) => status.name == row.status,
      orElse: () => ThingStatus.active,
    ),
    completedAt: row.completedAt,
    archivedAt: row.archivedAt,
    title: row.title,
    description: row.description,
    category: row.category,
    icon: _icon(row.iconCodePoint),
    reminderDate: row.reminderDate,
    attachments: (await database.attachmentsFor(row.id))
        .map((a) => a.name)
        .toList(),
  );
  Future<List<Thing>> all() async =>
      Future.wait((await database.allThings()).reversed.map(map));
  Future<Thing?> find(int id) async {
    final row = await database.thingById(id);
    return row == null ? null : map(row);
  }

  Future<void> edit(
    int id,
    String title,
    String category, {
    DateTime? reminderDate,
    String? description,
  }) async {
    if (title.trim().isEmpty) throw ArgumentError('A title is required');
    await database.updateThing(
      id,
      db.ThingsCompanion(
        title: Value(title.trim()),
        description: description == null
            ? const Value.absent()
            : Value(description.trim()),
        category: Value(category.trim().isEmpty ? 'General' : category.trim()),
        reminderDate: Value(reminderDate),
      ),
    );
    await reminders.syncThing(id);
  }

  Future<void> setCompleted(int id, bool completed) async {
    final row = await database.thingById(id);
    if (row == null) return;
    await database.updateThing(
      id,
      db.ThingsCompanion(
        status: Value(
          row.status == 'archived'
              ? 'archived'
              : completed
              ? 'completed'
              : 'active',
        ),
        completedAt: Value(
          completed ? row.completedAt ?? DateTime.now() : null,
        ),
      ),
    );
    await reminders.syncThing(id);
  }

  Future<void> setArchived(int id, bool archived) async {
    final row = await database.thingById(id);
    if (row == null) return;
    await database.updateThing(
      id,
      db.ThingsCompanion(
        status: Value(
          archived
              ? 'archived'
              : row.completedAt == null
              ? 'active'
              : 'completed',
        ),
        archivedAt: Value(archived ? row.archivedAt ?? DateTime.now() : null),
      ),
    );
    await reminders.syncThing(id);
  }

  Future<void> delete(int id) async {
    await reminders.forget('thing', id);
    await database.deleteThing(id);
    await store.removeRecord(AttachmentOwner.thing, id);
  }
}

IconData _icon(int codePoint) {
  const icons = [
    Icons.bookmark_outline_rounded,
    Icons.kitchen_outlined,
    Icons.receipt_long_outlined,
    Icons.handyman_outlined,
    Icons.description_outlined,
    Icons.medication_outlined,
    Icons.bookmark,
    Icons.inventory_2_outlined,
  ];
  return icons.firstWhere(
    (icon) => icon.codePoint == codePoint,
    orElse: () => Icons.bookmark_outline_rounded,
  );
}
