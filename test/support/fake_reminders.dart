import 'package:later/core/notifications/reminder_scheduler.dart';

class FakeReminders implements ReminderScheduler {
  final pending = <int, ({DateTime date, String payload})>{};
  final cancelled = <int>[];
  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    pending.remove(id);
  }

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime date,
    required String payload,
  }) async {
    pending[id] = (date: date, payload: payload);
  }
}
