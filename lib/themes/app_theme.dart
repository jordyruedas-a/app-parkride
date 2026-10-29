import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF22C55E);
  static const Color primaryDark = Color(0xFF14532D);
  static const Color dark = Color(0xFF0F172A);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color muted = Color(0xFF64748B);
  static const Color card = Colors.white;
  static const Color success = Color(0xFF22C55E);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: primaryDark,
        surface: surface,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.w800, color: dark),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: dark),
        bodyMedium: TextStyle(color: dark),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: dark,
        elevation: 0,
      ),
    );
  }
}
