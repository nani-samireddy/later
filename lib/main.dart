import 'package:flutter/material.dart';

import 'app/app.dart';

export 'app/app.dart' show LaterApp;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LaterApp());
}
