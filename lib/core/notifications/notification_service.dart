import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'reminder_scheduler.dart';

class NotificationService implements CalendarReminderScheduler {
  final Duration operationTimeout;
  const NotificationService({
    this.operationTimeout = const Duration(seconds: 10),
  });
  static final plugin = FlutterLocalNotificationsPlugin();
  static final warnings = StreamController<String>.broadcast();
  static final taps = StreamController<String>.broadcast();
  static String? initialPayload;
  static Future<void> initialize() async {
    tzdata.initializeTimeZones();
    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone.identifier));
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) taps.add(response.payload!);
      },
    );
    final launch = await plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true) {
      initialPayload = launch?.notificationResponse?.payload;
    }
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
    // Remove notifications from the old, unnamespaced ID scheme.
    for (final request in await plugin.pendingNotificationRequests()) {
      if (request.payload == null || !request.payload!.contains(':')) {
        await plugin.cancel(id: request.id);
      }
    }
  }

  static Future<void> requestExactTiming() async {
    final android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (await android?.canScheduleExactNotifications() == false) {
      await android?.requestExactAlarmsPermission();
    }
  }

  Future<void> _attempt(
    Future<void> Function() operation,
    String warning,
  ) async {
    try {
      await operation().timeout(operationTimeout);
    } catch (_) {
      warnings.add(warning);
    }
  }

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime date,
    required String payload,
  }) =>
      _schedule(id: id, title: title, body: body, date: date, payload: payload);

  @override
  Future<void> scheduleCalendar({
    required int id,
    required String title,
    required String body,
    required DateTime date,
    required String payload,
    required bool weekly,
  }) => _schedule(
    id: id,
    title: title,
    body: body,
    date: date,
    payload: payload,
    repeat: weekly
        ? DateTimeComponents.dayOfWeekAndTime
        : DateTimeComponents.time,
  );

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime date,
    required String payload,
    DateTimeComponents? repeat,
  }) => _attempt(
    () async {
      final scheduled = tz.TZDateTime.from(date, tz.local);
      if (!scheduled.isAfter(tz.TZDateTime.now(tz.local))) return;
      final android = plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final ios = plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (await android?.areNotificationsEnabled() == false ||
          (await ios?.checkPermissions())?.isEnabled == false) {
        warnings.add(
          'Entry saved, but notifications are disabled. Enable them in device settings.',
        );
        return;
      }
      final exact =
          await plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.canScheduleExactNotifications() ??
          true;
      await plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduled,
        payload: payload,
        matchDateTimeComponents: repeat,
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
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    },
    'Entry saved, but its reminder could not be scheduled. Check notification permissions.',
  );

  @override
  Future<void> cancel(int id) => _attempt(
    () => plugin.cancel(id: id),
    'Could not cancel a reminder. Check notification permissions.',
  );
}
