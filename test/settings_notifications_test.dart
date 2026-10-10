import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:later/features/settings/data/notification_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final calls = <MethodCall>[];
  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'checkPermissions') {
            return <String, bool>{
              'isEnabled': false,
              'isSoundEnabled': false,
              'isAlertEnabled': false,
              'isBadgeEnabled': false,
              'isProvisionalEnabled': false,
              'isCriticalEnabled': false,
              'isProvidesAppNotificationSettingsEnabled': false,
            };
          }
          return true;
        });
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  test(
    'Android reads notification and exact-alarm permissions separately',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      AndroidFlutterLocalNotificationsPlugin.registerWith();
      final service = NotificationPreferences();
      expect(await service.enabled(), isTrue);
      expect(await service.exactEnabled(), isTrue);
      await service.request();
      expect(calls.map((call) => call.method), [
        'areNotificationsEnabled',
        'canScheduleExactNotifications',
        'requestNotificationsPermission',
      ]);
    },
  );
  test('iOS reads status and requests alert, badge and sound without exact-alarm calls', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    IOSFlutterLocalNotificationsPlugin.registerWith();
    final service = NotificationPreferences();
    expect(await service.enabled(), isFalse);
    expect(await service.exactEnabled(), isNull);
    await service.request();
    expect(calls.map((call) => call.method), [
      'checkPermissions',
      'requestPermissions',
    ]);
    expect(calls.last.arguments, containsPair('alert', true));
    expect(calls.last.arguments, containsPair('badge', true));
    expect(calls.last.arguments, containsPair('sound', true));
  });
  test(
    'unsupported platforms expose unavailable status without plugin calls',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      final service = NotificationPreferences();
      expect(await service.enabled(), isNull);
      expect(await service.exactEnabled(), isNull);
      await service.request();
      expect(calls, isEmpty);
    },
  );
}
