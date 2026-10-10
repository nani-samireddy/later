import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const ink = Color(0xFF323D35);
  const muted = Color(0xFF7A8373);
  const border = Color(0xFFE4E7DE);
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF8F9F5),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF647C52),
      surface: const Color(0xFFF8F9F5),
      onSurface: ink,
    ),
    fontFamily: 'Arial',
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: ink, fontSize: 14),
      bodyMedium: TextStyle(color: ink, fontSize: 13),
      bodySmall: TextStyle(color: muted, fontSize: 11),
      titleMedium: TextStyle(
        color: ink,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF8F9F5),
      foregroundColor: ink,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: border),
      ),
    ),
    dividerTheme: const DividerThemeData(color: border),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: ink,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  );
}
