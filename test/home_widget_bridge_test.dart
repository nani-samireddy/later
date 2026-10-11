import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/widgets/home_widget_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'widget consumes cold launch action and updates a persistent snapshot',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(HomeWidgetBridge.channel, (call) async {
            calls.add(call);
            return call.method == 'consumeAction' ? 'add' : null;
          });
      addTearDown(() {
        debugDefaultTargetPlatformOverride = null;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(HomeWidgetBridge.channel, null);
      });
      final bridge = HomeWidgetBridge();
      String? action;
      await bridge.start((value) async => action = value);
      expect(action, 'add');
      await bridge.update(
        name: 'Sam',
        upcoming: 'Water plants',
        items: [
          {'title': 'Water plants', 'time': 1893456000000},
        ],
      );
      final data = calls.last.arguments as Map;
      expect(data['greeting'], 'Hey, Sam');
      expect((data['items'] as List).single['title'], 'Water plants');
      bridge.dispose();
    },
  );
  test('missing native widget plugin does not break app startup', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    await HomeWidgetBridge().start((_) async {});
    await HomeWidgetBridge().update(name: '', upcoming: '');
  });
}
