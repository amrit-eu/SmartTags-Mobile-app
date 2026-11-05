import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key under which the [ThemeMode] name is stored.
const String themeModePrefsKey = 'settings.themeMode';

/// Key under which the custom text scale factor is stored.
/// Absent when the system text size is used.
const String textScalePrefsKey = 'settings.textScale';

/// Key for enlarged buttons and tap targets (gloved / at-sea use).
const String largeTouchTargetsPrefsKey = 'settings.largeTouchTargets';

/// Provides the on-device key-value store used to persist user settings.
///
/// Overridden with an initialised instance in `main()`. The default is `null`
/// (settings kept in memory only), so tests that don't care about persistence
/// need no setup.
final sharedPreferencesProvider = Provider<SharedPreferencesWithCache?>((ref) => null);

/// Provides updates about changes to the app theme
final themeProvider = NotifierProvider<AppThemeMode, ThemeMode>(AppThemeMode.new);

/// Defines a provider to toggle the app theme (light/dark/system)
class AppThemeMode extends Notifier<ThemeMode> {
  SharedPreferencesWithCache? get _prefs => ref.read(sharedPreferencesProvider);

  /// Loads the persisted theme, defaulting to the system theme.
  @override
  ThemeMode build() {
    final stored = _prefs?.getString(themeModePrefsKey);
    return ThemeMode.values.asNameMap()[stored] ?? ThemeMode.system;
  }

  /// Resets to system theme
  void useSystem() => _set(ThemeMode.system);

  /// Enables dark mode
  void useDark() => _set(ThemeMode.dark);

  /// Enables light mode
  void useLight() => _set(ThemeMode.light);

  void _set(ThemeMode mode) {
    state = mode;
    unawaited(_prefs?.setString(themeModePrefsKey, mode.name));
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

  SharedPreferencesWithCache? get _prefs => ref.read(sharedPreferencesProvider);

  /// Loads the persisted text scale, or null to use the system default.
  @override
  double? build() {
    final stored = _prefs?.getDouble(textScalePrefsKey);
    return stored == null || !stored.isFinite ? null : _snap(stored);
  }

  /// Reset text scale factor to system default size
  void useSystem() {
    state = null;
    unawaited(_prefs?.remove(textScalePrefsKey));
  }

  /// Enable custom scaling (starts at 1.0, i.e. identical to system size)
  void useCustom() => _setCustom(1);

  /// Set text scale factor from user input
  void set(double relativeScale) => _setCustom(_snap(relativeScale));

  void _setCustom(double scale) {
    state = scale;
    unawaited(_prefs?.setDouble(textScalePrefsKey, scale));
  }

  static double _snap(double scale) => ((scale / step).round() * step).clamp(min, max);
}

/// Whether buttons and links use enlarged minimum touch targets.
final largeTouchTargetsProvider = NotifierProvider<AppLargeTouchTargets, bool>(AppLargeTouchTargets.new);

/// Persists the “larger buttons” accessibility preference (#46).
class AppLargeTouchTargets extends Notifier<bool> {
  SharedPreferencesWithCache? get _prefs => ref.read(sharedPreferencesProvider);

  @override
  bool build() => _prefs?.getBool(largeTouchTargetsPrefsKey) ?? false;

  /// Enables or disables enlarged touch targets app-wide.
  void setEnabled({required bool enabled}) {
    state = enabled;
    unawaited(_prefs?.setBool(largeTouchTargetsPrefsKey, enabled));
  }
}

/// True while enlarged touch targets are being applied (full-screen loader).
final largeTouchTargetsTransitionProvider =
    NotifierProvider<AppLargeTouchTargetsTransition, bool>(AppLargeTouchTargetsTransition.new);

/// Applies [largeTouchTargetsProvider] after a frame so a loader can paint first.
class AppLargeTouchTargetsTransition extends Notifier<bool> {
  @override
  bool build() => false;

  /// Shows a blocking loader, then updates touch-target sizing.
  Future<void> apply({required bool enabled}) async {
    if (state) {
      return;
    }
    if (ref.read(largeTouchTargetsProvider) == enabled) {
      return;
    }

    state = true;
    await SchedulerBinding.instance.endOfFrame;
    ref.read(largeTouchTargetsProvider.notifier).setEnabled(enabled: enabled);
    await SchedulerBinding.instance.endOfFrame;
    await SchedulerBinding.instance.endOfFrame;
    state = false;
  }
}
