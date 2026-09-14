import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================
  // LIGHT THEME
  // ============================================================

  static final ThemeData light = ThemeData(
    useMaterial3: true,

    brightness: Brightness.light,

    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),

    scaffoldBackgroundColor: Colors.white,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
    ),

    cardTheme: const CardThemeData(
      color: Colors.white,
    ),

    inputDecorationTheme:
        const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),

    elevatedButtonTheme:
        ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(
          double.infinity,
          50,
        ),
      ),
    ),
  );

  // ============================================================
  // DARK THEME
  // ============================================================

  static final ThemeData dark = ThemeData(
    useMaterial3: true,

    brightness: Brightness.dark,

    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),

    scaffoldBackgroundColor:
        const Color(0xFF121212),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),

    cardTheme: const CardThemeData(
      color: Color(0xFF1E1E1E),
    ),

    inputDecorationTheme:
        const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),

    elevatedButtonTheme:
        ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(
          double.infinity,
          50,
        ),
      ),
    ),
  );
}