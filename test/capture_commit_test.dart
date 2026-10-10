import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/database/app_database.dart';
import 'package:later/core/notifications/notification_service.dart';
import 'package:later/core/notifications/reminder_scheduler.dart';
import 'package:later/features/capture/data/entry_capture_service.dart';

class ThrowingReminders implements ReminderScheduler {
  @override
  Future<void> cancel(int id) async => throw StateError('native unavailable');
  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime date,
    required String payload,
  }) async => throw StateError('native unavailable');
}

void main() {
  test(
    'committed capture succeeds with a warning when scheduling throws',
    () async {
      final database = AppDatabase.withExecutor(NativeDatabase.memory());
      final warning = NotificationService.warnings.stream.first;
      final saved =
          await EntryCaptureService(
            database,
            scheduler: ThrowingReminders(),
          ).save(
            kind: 'thing',
            title: 'Receipt',
            description: 'Original description',
            category: 'General',
            amount: '',
            person: '',
            currency: 'INR',
            attachments: [],
            reminderDate: DateTime.now().add(const Duration(days: 1)),
            reminderTime: const TimeOfDay(hour: 9, minute: 0),
          );
      expect(saved, isTrue);
      expect(await warning, contains('Entry saved'));
      expect(await database.allThings(), hasLength(1));
      await database.close();
    },
  );
}
