import 'package:flutter/material.dart';

ThemeData buildAppTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFFF7F8F5),
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF34725F)),
  fontFamily: 'Arial',
);
