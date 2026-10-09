import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/home/presentation/home_screen.dart';

class LaterApp extends StatelessWidget {
  const LaterApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Later',
    theme: buildAppTheme(),
    home: const LaterHome(),
  );
}
