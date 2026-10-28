import 'package:flutter/material.dart';

/// Centralized theme configuration for the application.
class AppTheme {
  /// Defines the light theme data.
  static ThemeData get lightTheme => _baseTheme(
        ColorScheme.fromSeed(seedColor: Colors.lightGreenAccent),
      );

  /// Defines the dark theme data.
  static ThemeData get darkTheme => _baseTheme(
        ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
      );

  static ThemeData _baseTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
