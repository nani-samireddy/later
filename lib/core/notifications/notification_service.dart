import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
    await plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: darwin),
    );
    await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    final scheduled = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      date.hour == 0 ? 9 : date.hour,
      date.hour == 0 ? 0 : date.minute,
    );
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;
    await plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'later_reminders',
          'Later reminders',
          channelDescription: 'Reminders for saved items',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> cancel(int id) => plugin.cancel(id: id);
}
