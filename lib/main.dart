import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/notifications/notification_service.dart';

import 'package:flutter_gemma/flutter_gemma.dart';

export 'app/app.dart' show LaterApp;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Manual entry stays available when a platform plugin cannot finish startup.
  try {
    await NotificationService.initialize().timeout(const Duration(seconds: 10));
  } catch (error) {
    debugPrint('Notification startup unavailable: $error');
  }
  try {
    await FlutterGemma.initialize().timeout(const Duration(seconds: 10));
  } catch (error) {
    debugPrint('Optional AI startup unavailable: $error');
  }
  runApp(const LaterApp());
}
