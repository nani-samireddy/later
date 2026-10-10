import '../../../core/attachments/attachment_store.dart';
import '../../../core/database/app_database.dart';
import '../../../core/notifications/notification_service.dart';

/// Cancels reminders first so a permission/plugin failure does not erase records.
/// Uses every registered Drift table, including future repayment/recurrence tables.
class ClearDataService {
  final AppDatabase database;
  final AttachmentStore attachments;
  final Future<void> Function() cancelNotifications;
  ClearDataService(
    this.database, {
    AttachmentStore? attachments,
    Future<void> Function()? cancelNotifications,
  }) : attachments = attachments ?? AttachmentStore(),
       cancelNotifications =
           cancelNotifications ??
           (() => NotificationService.plugin.cancelAll());

  Future<void> clear() async {
    await cancelNotifications();
    await database.transaction(() async {
      await database.customStatement('PRAGMA defer_foreign_keys = ON');
      for (final table in database.allTables) {
        await database.delete(table).go();
      }
    });
    try {
      final directory = await attachments.directory();
      if (await directory.exists()) await directory.delete(recursive: true);
    } catch (_) {
      throw const ClearDataFileCleanupException();
    }
  }
}

class ClearDataFileCleanupException implements Exception {
  const ClearDataFileCleanupException();
}
