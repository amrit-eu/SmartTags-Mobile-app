import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smart_tags/providers/settings_providers.dart';

Future<SharedPreferencesWithCache> _openPrefs([Map<String, Object> initial = const {}]) async {
  SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.withData(initial);
  return await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );
}

ProviderContainer _containerFor(SharedPreferencesWithCache prefs) {
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('themeProvider', () {
    test('defaults to system when nothing is stored', () async {
      final container = _containerFor(await _openPrefs());

      expect(container.read(themeProvider), ThemeMode.system);
    });

    test('works in memory when no preferences store is provided', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(themeProvider.notifier).useDark();

      expect(container.read(themeProvider), ThemeMode.dark);
    });

    test('restores the saved theme on the next launch', () async {
      final prefs = await _openPrefs();
      _containerFor(prefs).read(themeProvider.notifier).useDark();

      // New container over the same store simulates closing and reopening the app.
      expect(_containerFor(prefs).read(themeProvider), ThemeMode.dark);
    });

    test('persists every mode', () async {
      final prefs = await _openPrefs();
      final notifier = _containerFor(prefs).read(themeProvider.notifier)..useLight();
      expect(_containerFor(prefs).read(themeProvider), ThemeMode.light);

      notifier.useSystem();
      expect(_containerFor(prefs).read(themeProvider), ThemeMode.system);
    });

    test('falls back to system when the stored value is invalid', () async {
      final prefs = await _openPrefs({themeModePrefsKey: 'neon'});

      expect(_containerFor(prefs).read(themeProvider), ThemeMode.system);
    });
  });

  group('textScaleProvider', () {
    test('defaults to the system size when nothing is stored', () async {
      final container = _containerFor(await _openPrefs());

      expect(container.read(textScaleProvider), isNull);
    });

    test('restores the saved scale on the next launch', () async {
      final prefs = await _openPrefs();
      _containerFor(prefs).read(textScaleProvider.notifier).set(1.4);

      expect(_containerFor(prefs).read(textScaleProvider), closeTo(1.4, 1e-9));
    });

    test('useCustom persists a scale of 1.0', () async {
      final prefs = await _openPrefs();
      _containerFor(prefs).read(textScaleProvider.notifier).useCustom();

      expect(_containerFor(prefs).read(textScaleProvider), 1.0);
    });

    test('useSystem removes the stored scale', () async {
      final prefs = await _openPrefs();
      final notifier = _containerFor(prefs).read(textScaleProvider.notifier)..set(1.6);
      expect(prefs.containsKey(textScalePrefsKey), isTrue);

      notifier.useSystem();

      expect(prefs.containsKey(textScalePrefsKey), isFalse);
      expect(_containerFor(prefs).read(textScaleProvider), isNull);
    });

    test('snaps and clamps an out-of-range stored value', () async {
      final prefs = await _openPrefs({textScalePrefsKey: 5.0});

      expect(_containerFor(prefs).read(textScaleProvider), AppTextScale.max);
    });

    test('ignores a non-finite stored value', () async {
      final prefs = await _openPrefs({textScalePrefsKey: double.nan});

      expect(_containerFor(prefs).read(textScaleProvider), isNull);
    });
  });
}
