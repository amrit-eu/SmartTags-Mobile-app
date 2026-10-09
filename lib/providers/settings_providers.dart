import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides updates about changes to the app theme
final themeProvider = NotifierProvider<AppThemeMode, ThemeMode>(AppThemeMode.new);

/// Defines a provider to toggle the app theme (light/dark/system)
class AppThemeMode extends Notifier<ThemeMode> {
  /// Load initial state. Currently statically initialised.
  /// Change to using AsyncNotifier once we load from a DB or similar.
  @override
  ThemeMode build() {
    return ThemeMode.system;
  }

  /// Resets to system theme
  void useSystem() {
    state = ThemeMode.system;
  }

  /// Enables dark mode
  void useDark() {
    state = ThemeMode.dark;
  }

  /// Enables light mode
  void useLight() {
    state = ThemeMode.light;
  }
}

/// Global text scale factor (1.0 = system default size)
final textScaleProvider = NotifierProvider<AppTextScale, double?>(AppTextScale.new);

/// Defines a provider to set text size in the app (exposed via settings slider)
class AppTextScale extends Notifier<double?> {
  /// Minimum text scale factor
  static const double min = 0.8;
  /// Maximum text scale factor
  static const double max = 2;
  /// Slider goes up in 20% increments
  static const double step = 0.2;
  /// (max - min) / step
  static const int divisions = 6;

  /// Load initial state. Currently statically initialised.
  /// Change to using AsyncNotifier once we load from a DB or similar.
  @override
  double? build() => null;

  /// Reset text scale factor to system default size
  void useSystem() => state = null;

  /// Enable custom scaling (starts at 1.0, i.e. identical to system size)
  void useCustom() => state = 1.0;

  /// Set text scale factor from user input
  void set(double relativeScale){
    final snapped = (relativeScale / step).round() * step;
    state = snapped.clamp(min, max);
  }
}
