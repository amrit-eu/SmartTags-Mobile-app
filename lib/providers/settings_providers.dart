import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides updates about changes to the app theme
final themeProvider = NotifierProvider<AppThemeMode, ThemeMode>(AppThemeMode.new);

/// Defines a provider to change the toggle the app theme (light/dark/system)
class AppThemeMode extends Notifier<ThemeMode> {
  /// Load initial state. Currently statically initialised.
  /// Change to using AsyncNotifier once we load from a DB or similar.
  @override
  ThemeMode build() {
    return ThemeMode.system;
  }

  /// Reset to system theme
  void setSystem() {
    state = ThemeMode.system;
  }

  /// Enable dark mode
  void setDark() {
    state = ThemeMode.dark;
  }

  /// Enable light mode
  void setLight() {
    state = ThemeMode.light;
  }
}

/// Provides updates about changes to the user login status
final loginProvider = NotifierProvider<AppLoginState, bool>(AppLoginState.new);

class AppLoginState extends Notifier<bool> {
  /// Load initial state. Currently statically initialised.
  /// Change to using AsyncNotifier once we load from a DB or similar.
  @override
  bool build() {
    return false;
  }

  void setLoggedIn() {
    state = true;
  }

  void setLoggedOut() {
    state = false;
  }
}
