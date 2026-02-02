import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/providers/settings_providers.dart';
import 'package:smart_tags/widgets/common/settings_menu.dart';

void main() {
  testWidgets('Settings menu can be opened from app bar and shows dark mode options', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(),
            body: const Center(child: SettingsMenu()),
          ),
        ),
      )
    );

    // Ensure menu is closed
    expect(find.text('Dark Mode'), findsNothing);

    // Tap the ellipsis icon button and wait for menu to open
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // Verify menu has opened
    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.text('Use system default'), findsOneWidget);
  });

  testWidgets('System theme is enabled by default', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(),
            body: const Center(child: SettingsMenu()),
          ),
        ),
      )
    );

    // Tap the ellipsis icon button and wait for menu to open
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // Verify system theme checkbox is ticked
    expect(tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, 'Use system default')).value, true);
    // Verify dark mode switch is off and disabled if system theme is in use
    expect(tester.widget<SwitchListTile>(find.widgetWithIcon(SwitchListTile, Icons.dark_mode)).onChanged, null);
    expect(tester.widget<SwitchListTile>(find.widgetWithIcon(SwitchListTile, Icons.dark_mode)).value, false);
  });

  testWidgets('Disabling system theme enables light mode', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            return MaterialApp(
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: ref.watch(themeProvider),
              home: Scaffold(
                appBar: AppBar(),
                body: const Center(child: SettingsMenu()),
              ),
            );
          },
        ),
      ),
    );
    final systemDefaultCheckbox = find.widgetWithText(CheckboxListTile, 'Use system default');
    // Tap the ellipsis icon button and wait for menu to open
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    // Tap checkbox to disable
    await tester.tap(systemDefaultCheckbox);
    await tester.pumpAndSettle();

    // Verify dark mode is turned off
    expect(tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'Dark Mode')).value, false);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SettingsMenu)),
    );
    expect(container.read(themeProvider), ThemeMode.light);
  });

  testWidgets('Dark mode can be toggled on', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            return MaterialApp(
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: ref.watch(themeProvider),
              home: Scaffold(
                appBar: AppBar(),
                body: const Center(child: SettingsMenu()),
              ),
            );
          },
        ),
      ),
    );
    final systemDefaultCheckbox = find.widgetWithText(CheckboxListTile, 'Use system default');
    // Tap the ellipsis icon button and wait for menu to open
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    // Tap checkbox to disable
    await tester.tap(systemDefaultCheckbox);
    await tester.pumpAndSettle();
    // Turn on dark mode
    await tester.tap(find.widgetWithText(SwitchListTile, 'Dark Mode'));
    await tester.pumpAndSettle();

    // Verify dark mode is turned on
    expect(tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'Dark Mode')).value, true);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SettingsMenu)),
    );
    expect(container.read(themeProvider), ThemeMode.dark);
  });
}
