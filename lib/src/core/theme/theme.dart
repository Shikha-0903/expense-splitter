// lib/src/core/theme/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Basic app colors
  static const Color softLavender = Color(0xFFF3EDFF);
  static const Color lightLavender = Color(0xFFE6DBFF);
  static const Color classicLavender = Color(0xFFCDB7F6);
  static const Color mutedLavender = Color(0xFFB39DDB);
  static const Color deepLavender = Color(0xFF9179C7);
  static const Color midnightBlue = Color(0xFF0F172A);
  static const Color charcoalBlack = Color(0xFF1C1B22);
  static const Color offWhite = Color(0xFFFAF9FF);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: deepLavender,
    brightness: Brightness.light,
    scaffoldBackgroundColor: offWhite,
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: deepLavender, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightLavender, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: deepLavender,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: charcoalBlack,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: midnightBlue,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: classicLavender, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: mutedLavender, width: 1.5),
      ),
      filled: true,
      fillColor: midnightBlue,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}
