import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/providers/settings_providers.dart';
import 'package:smart_tags/widgets/common/settings_menu.dart';
import 'package:smart_tags/widgets/common/settings_transition_overlay.dart';

Future<void> settingsMenuTestSetup(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(),
          body: const Center(child: SettingsMenu()),
        ),
      ),
    ),
  );
}

Future<void> settingsMenuTestSetupWithConsumer(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: Consumer(
        builder: (context, ref, _) {
          final applyingTouchTargets = ref.watch(largeTouchTargetsTransitionProvider);
          return MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ref.watch(themeProvider),
            builder: (context, child) {
              var content = child!;
              if (applyingTouchTargets) {
                content = Stack(
                  fit: StackFit.expand,
                  children: [
                    content,
                    const SettingsTransitionOverlay(message: 'Updating display…'),
                  ],
                );
              }
              return content;
            },
            home: Scaffold(
              appBar: AppBar(),
              body: const Center(child: SettingsMenu()),
            ),
          );
        },
      ),
    ),
  );
}

Future<void> openSettingsMenu(WidgetTester tester, {bool withConsumer = false}) async {
  withConsumer
    ? await settingsMenuTestSetupWithConsumer(tester)
    : await settingsMenuTestSetup(tester);
  await tester.tap(find.byIcon(Icons.more_vert));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Settings menu can be opened from app bar and shows dark mode options', (tester) async {
    await settingsMenuTestSetup(tester);

    expect(find.text('Dark Mode'), findsNothing);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.text('Theme Mode: Use System Default'), findsOneWidget);
    expect(find.text('Larger buttons and links'), findsOneWidget);
    expect(find.text('Text Size: Use System Default'), findsNothing);
  });

  testWidgets('System theme is enabled by default', (tester) async {
    await openSettingsMenu(tester);

    expect(tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'Theme Mode: Use System Default')).value, true);
    expect(tester.widget<SwitchListTile>(find.widgetWithIcon(SwitchListTile, Icons.dark_mode)).onChanged, null);
    expect(tester.widget<SwitchListTile>(find.widgetWithIcon(SwitchListTile, Icons.dark_mode)).value, false);
  });

  testWidgets('Disabling system theme enables light mode', (tester) async {
    await openSettingsMenu(tester, withConsumer: true);
    final systemDefaultSwitch = find.widgetWithText(SwitchListTile, 'Theme Mode: Use System Default');
    await tester.tap(systemDefaultSwitch);
    await tester.pumpAndSettle();

    expect(tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'Dark Mode')).value, false);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SettingsMenu)),
    );
    expect(container.read(themeProvider), ThemeMode.light);
  });

  testWidgets('Dark mode can be toggled on', (tester) async {
    await openSettingsMenu(tester, withConsumer: true);
    final systemDefaultSwitch = find.widgetWithText(SwitchListTile, 'Theme Mode: Use System Default');
    await tester.tap(systemDefaultSwitch);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SwitchListTile, 'Dark Mode'));
    await tester.pumpAndSettle();

    expect(tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'Dark Mode')).value, true);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SettingsMenu)),
    );
    expect(container.read(themeProvider), ThemeMode.dark);
  });

  testWidgets('Larger buttons toggle persists in settings', (tester) async {
    await openSettingsMenu(tester, withConsumer: true);

    expect(find.text('Larger buttons and links'), findsOneWidget);
    final toggle = find.widgetWithText(SwitchListTile, 'Larger buttons and links');
    expect(tester.widget<SwitchListTile>(toggle).value, isFalse);

    await tester.tap(toggle);
    await tester.pump();
    expect(find.text('Updating display…'), findsOneWidget);

    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SettingsMenu)),
    );
    expect(container.read(largeTouchTargetsProvider), isTrue);
    expect(find.text('Updating display…'), findsNothing);
  });
}
