import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';

class SettingsPreferences {
  final AppDatabase database;
  const SettingsPreferences(this.database);
  static const reminderTimeKey = 'default_reminder_minutes';
  static const defaultReminderTime = TimeOfDay(hour: 9, minute: 0);

  Future<TimeOfDay> reminderTime() async {
    final minutes = int.tryParse(await database.setting(reminderTimeKey) ?? '');
    if (minutes == null || minutes < 0 || minutes >= 1440) {
      return defaultReminderTime;
    }
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  Future<void> saveReminderTime(TimeOfDay time) =>
      database.saveSetting(reminderTimeKey, '${time.hour * 60 + time.minute}');
}
