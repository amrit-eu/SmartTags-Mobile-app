import 'package:flutter/material.dart';

/// A custom theme extension to hold status-related colors.
class StatusColors extends ThemeExtension<StatusColors> {
  /// Creates a [StatusColors].
  const StatusColors({
    required this.activeBorderColor,
    required this.inactiveBorderColor,
  });

  /// The color used for active status border.
  final Color activeBorderColor;

  /// The color used for inactive status border.
  final Color inactiveBorderColor;

  @override
  ThemeExtension<StatusColors> copyWith({
    Color? activeBorderColor,
    Color? inactiveBorderColor,
  }) {
    return StatusColors(
      activeBorderColor: activeBorderColor ?? this.activeBorderColor,
      inactiveBorderColor: inactiveBorderColor ?? this.inactiveBorderColor,
    );
  }

  @override
  ThemeExtension<StatusColors> lerp(
    ThemeExtension<StatusColors>? other,
    double t,
  ) {
    if (other is! StatusColors) return this;
    return StatusColors(
      activeBorderColor: Color.lerp(activeBorderColor, other.activeBorderColor, t)!,
      inactiveBorderColor: Color.lerp(inactiveBorderColor, other.inactiveBorderColor, t)!,
    );
  }
}

/// Centralized theme configuration for the application.
class AppTheme {
  /// Defines the light theme data.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreenAccent),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      extensions: const <ThemeExtension<dynamic>>[
        StatusColors(
          activeBorderColor: Color.fromARGB(255, 46, 125, 50),
          inactiveBorderColor: Color.fromARGB(255, 198, 40, 40),
        ),
      ],
    );
  }

  /// Defines the dark theme data.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepOrange,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      extensions: const <ThemeExtension<dynamic>>[
        StatusColors(
          activeBorderColor: Color.fromARGB(255, 76, 175, 80),
          inactiveBorderColor: Color.fromARGB(255, 244, 67, 54),
        ),
      ],
    );
  }
}
