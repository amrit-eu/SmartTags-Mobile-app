import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/providers/settings_providers.dart';
import 'package:smart_tags/widgets/common/settings_menu.dart';

class TextScaleWrapper extends ConsumerWidget {
  const TextScaleWrapper({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customTextScale = ref.watch(textScaleProvider);
    final mediaQuery = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: customTextScale != null
            ? TextScaler.linear(customTextScale)
            : mediaQuery.textScaler.clamp(
          minScaleFactor: AppTextScale.min,
          maxScaleFactor: AppTextScale.max,
        ),
      ),
      child: child,
    );
  }
}

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
          return MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ref.watch(themeProvider),
            builder: (context, child) => TextScaleWrapper(child: child!),
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
  // Tap the ellipsis icon button and wait for menu to open
  await tester.tap(find.byIcon(Icons.more_vert));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Settings menu can be opened from app bar and shows dark mode options', (tester) async {
    await settingsMenuTestSetup(tester);

    // Ensure menu is closed
    expect(find.text('Dark Mode'), findsNothing);

    // Tap the ellipsis icon button and wait for menu to open
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // Verify menu has opened
    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.text('Theme Mode: Use System Default'), findsOneWidget);
  });

  testWidgets('System theme is enabled by default', (tester) async {
    await openSettingsMenu(tester);

    // Verify system theme switch is enabled
    expect(tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'Theme Mode: Use System Default')).value, true);
    // Verify dark mode switch is off and disabled if system theme is in use
    expect(tester.widget<SwitchListTile>(find.widgetWithIcon(SwitchListTile, Icons.dark_mode)).onChanged, null);
    expect(tester.widget<SwitchListTile>(find.widgetWithIcon(SwitchListTile, Icons.dark_mode)).value, false);
  });

  testWidgets('Disabling system theme enables light mode', (tester) async {
    await openSettingsMenu(tester, withConsumer: true);
    final systemDefaultSwitch = find.widgetWithText(SwitchListTile, 'Theme Mode: Use System Default');
    // Tap switch to disable
    await tester.tap(systemDefaultSwitch);
    await tester.pumpAndSettle();

    // Verify dark mode is turned off
    expect(tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'Dark Mode')).value, false);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SettingsMenu)),
    );
    expect(container.read(themeProvider), ThemeMode.light);
  });

  testWidgets('Dark mode can be toggled on', (tester) async {
    await openSettingsMenu(tester, withConsumer: true);
    final systemDefaultSwitch = find.widgetWithText(SwitchListTile, 'Theme Mode: Use System Default');
    // Tap switch to disable
    await tester.tap(systemDefaultSwitch);
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

  testWidgets('Settings menu shows text size options', (tester) async {
    await settingsMenuTestSetup(tester);

    // Ensure menu is closed
    expect(find.text('Text Size'), findsNothing);

    // Tap the ellipsis icon button and wait for menu to open
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // Verify menu has opened
    expect(find.text('Text Size: Use System Default'), findsOneWidget);
    expect(find.byKey(const Key('textSizeSlider')), findsOneWidget);
  });

  testWidgets('System font size is enabled by default', (tester) async {
    await openSettingsMenu(tester);

    // Verify system text size is enabled
    expect(tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'Text Size: Use System Default')).value, true);
    // Verify text size slider is set to system font size and disabled
    expect(tester.widget<Slider>(find.byKey(const Key('textSizeSlider'))).onChanged, null);
    expect(tester.widget<Slider>(find.byKey(const Key('textSizeSlider'))).value, 1);
  });

  testWidgets('Disabling system font size enables slider', (tester) async {
    await openSettingsMenu(tester);

    final systemDefaultSwitch = find.widgetWithText(SwitchListTile, 'Text Size: Use System Default');

    // Tap switch to disable
    await tester.tap(systemDefaultSwitch);
    await tester.pumpAndSettle();

    // Verify slider is enabled
    expect(tester.widget<Slider>(find.byKey(const Key('textSizeSlider'))).onChanged, isNot(null));
  });

  testWidgets('Text size can be changed using settings slider', (tester) async {
    await openSettingsMenu(tester, withConsumer: true);
    final systemDefaultSwitch = find.widgetWithText(SwitchListTile, 'Text Size: Use System Default');

    // Tap switch to disable system default
    await tester.tap(systemDefaultSwitch);
    await tester.pumpAndSettle();

    final textSizeBefore = MediaQuery.textScalerOf(
      tester.element(find.byType(SettingsMenu)),
    ).scale(10);
    expect(textSizeBefore, 10);

    // Drag text size slider
    await tester.drag(find.byKey(const Key('textSizeSlider')), Offset(500, 0));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SettingsMenu)),
    );
    final scale = container.read(textScaleProvider);
    expect(scale, 2);
    expect(scale, AppTextScale.max);

    final textSizeAfter = MediaQuery.textScalerOf(
      tester.element(find.byType(SettingsMenu)),
    ).scale(10);

    expect(textSizeAfter, greaterThan(textSizeBefore));
    expect(textSizeAfter, 20);
  });
}
