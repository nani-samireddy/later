import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/notifications/notification_service.dart';

import 'package:flutter_gemma/flutter_gemma.dart';

export 'app/app.dart' show LaterApp;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  await FlutterGemma.initialize();
  runApp(const LaterApp());
}
