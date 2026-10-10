import 'dart:convert';

import '../database/app_database.dart';
import 'recurrence.dart';

/// Record-scoped policy uses the existing settings table, so no schema change
/// or database migration is needed. Anchor mismatch invalidates an old snooze.
class ReminderPreferences {
  const ReminderPreferences({
    this.recurrence = ReminderRecurrence.none,
    this.snoozedUntil,
    this.anchor,
  });
  final ReminderRecurrence recurrence;
  final DateTime? snoozedUntil;
  final DateTime? anchor;

  DateTime? effectiveDate(DateTime date, DateTime now) {
    if (anchor != date) return date.isAfter(now) ? date : null;
    if (snoozedUntil != null && snoozedUntil!.isAfter(now)) return snoozedUntil;
    return nextReminderOccurrence(
      anchor: date,
      recurrence: recurrence,
      after: now,
    );
  }
}

class ReminderPreferencesStore {
  const ReminderPreferencesStore(this.database);
  final AppDatabase database;
  String _key(String type, int id) {
    if (!{'thing', 'money'}.contains(type) || id <= 0) {
      throw ArgumentError('Invalid reminder record');
    }
    return 'reminder:$type:$id';
  }

  Future<void> remove(String type, int id) async {
    await (database.delete(
      database.appSettings,
    )..where((row) => row.key.equals(_key(type, id)))).go();
  }

  Future<ReminderPreferences> read(String type, int id) async {
    final raw = await database.setting(_key(type, id));
    if (raw == null) return const ReminderPreferences();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return ReminderPreferences(
        recurrence: ReminderRecurrence.parse(json['recurrence'] as String?),
        anchor: DateTime.tryParse(json['anchor'] as String? ?? ''),
        snoozedUntil: DateTime.tryParse(json['snoozedUntil'] as String? ?? ''),
      );
    } on FormatException {
      return const ReminderPreferences();
    } on TypeError {
      return const ReminderPreferences();
    }
  }

  Future<void> write(String type, int id, ReminderPreferences preferences) =>
      database.saveSetting(
        _key(type, id),
        jsonEncode({
          'recurrence': preferences.recurrence.name,
          'anchor': preferences.anchor?.toIso8601String(),
          'snoozedUntil': preferences.snoozedUntil?.toIso8601String(),
        }),
      );
}
