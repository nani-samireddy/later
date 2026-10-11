import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class HomeWidgetBridge {
  static const channel = MethodChannel('later/home_widget');
  bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  Future<void> start(Future<void> Function(String) onAction) async {
    if (!supported) return;
    channel.setMethodCallHandler((call) async {
      if (call.method == 'action' && call.arguments is String) {
        await onAction(call.arguments as String);
      }
    });
    try {
      final action = await channel.invokeMethod<String>('consumeAction');
      if (action != null) await onAction(action);
    } on PlatformException catch (_) {
      // Widget support must never prevent normal app startup.
    } on MissingPluginException catch (_) {}
  }

  Future<void> update({required String name, required String upcoming}) async {
    if (!supported) return;
    try {
      await channel.invokeMethod<void>('update', {
        'greeting': name.isEmpty ? 'later.' : 'Hey, $name',
        'upcoming': upcoming,
      });
    } on PlatformException catch (_) {
    } on MissingPluginException catch (_) {}
  }

  void dispose() {
    if (supported) channel.setMethodCallHandler(null);
  }
}
