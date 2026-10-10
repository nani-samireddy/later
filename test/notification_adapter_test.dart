import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:later/core/notifications/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  setUp(() async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'initialize') return true;
          if (call.method == 'canScheduleExactNotifications') return true;
          return null;
        });
    await NotificationService.plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = null;
  });
  test(
    'Native calendar repeats retain local time and use inexact fallback',
    () async {
      MethodCall? request;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'canScheduleExactNotifications') return false;
            if (call.method == 'zonedSchedule') request = call;
            return null;
          });
      for (final weekly in [false, true]) {
        await const NotificationService().scheduleCalendar(
          id: 2,
          title: 'Repeat',
          body: 'Item',
          date: DateTime(2090, 2, 1, 9),
          payload: 'thing:1',
          weekly: weekly,
        );
        final args = request!.arguments as Map;
        expect(args['matchDateTimeComponents'], weekly ? 1 : 0);
        expect(
          (args['platformSpecifics'] as Map)['scheduleMode'],
          'inexactAllowWhileIdle',
        );
        expect(args['scheduledDateTime'], startsWith('2090-02-01T09:00:00'));
      }
    },
  );
  test(
    'Denied notification permission surfaces a warning without scheduling',
    () async {
      var scheduled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'areNotificationsEnabled') return false;
            if (call.method == 'zonedSchedule') scheduled = true;
            return null;
          });
      final warning = NotificationService.warnings.stream.first;
      await const NotificationService().schedule(
        id: 2,
        title: 'Item',
        body: 'Item',
        date: DateTime(2090),
        payload: 'thing:1',
      );
      expect(await warning, contains('disabled'));
      expect(scheduled, false);
    },
  );
  test(
    'Adapter keeps midnight in local timezone and attaches record payload',
    () async {
      MethodCall? request;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'canScheduleExactNotifications') return true;
            if (call.method == 'zonedSchedule') request = call;
            return null;
          });
      await const NotificationService().schedule(
        id: 2,
        title: 'Thing',
        body: 'Passport',
        date: DateTime.utc(2090, 1, 1, 18, 45),
        payload: 'thing:1',
      );
      expect(request, isNotNull);
      final arguments = request!.arguments as Map;
      expect(arguments['timeZoneName'], 'Asia/Kolkata');
      expect(arguments['scheduledDateTime'], startsWith('2090-01-02T00:15:00'));
      expect(arguments['payload'], 'thing:1');
    },
  );
  test('Notification errors surface a warning without turning a saved record into a retry', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'canScheduleExactNotifications') return true;
          throw PlatformException(code: 'permission_denied');
        });
    final warning = NotificationService.warnings.stream.first;
    await const NotificationService().schedule(
      id: 2,
      title: 'Thing',
      body: 'Passport',
      date: DateTime(2090),
      payload: 'thing:1',
    );
    expect(await warning, contains('Entry saved'));
  });
  test(
    'A stalled native reminder does not keep a saved entry waiting',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'canScheduleExactNotifications') return true;
            return Completer<Object?>().future;
          });
      final warning = NotificationService.warnings.stream.first;
      await const NotificationService(
        operationTimeout: Duration(milliseconds: 20),
      ).schedule(
        id: 2,
        title: 'Thing',
        body: 'Passport',
        date: DateTime(2090),
        payload: 'thing:1',
      );
      expect(await warning, contains('Entry saved'));
    },
  );
}
