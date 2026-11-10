import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/error_notification_provider.dart';
import 'package:smart_tags/providers/map_focus_request_provider.dart';
import 'package:smart_tags/providers/passport_event_queue_provider.dart';
import 'package:smart_tags/providers/platforms_refresh_provider.dart';
import 'package:smart_tags/providers/settings_providers.dart';
import 'package:smart_tags/screens/catalogue_screen.dart';
import 'package:smart_tags/screens/map_screen.dart';
import 'package:smart_tags/screens/qr_scan_screen.dart';
import 'package:smart_tags/theme.dart';
import 'package:smart_tags/theme/touch_target_theme.dart';
import 'package:smart_tags/widgets/common/app_snack_bar.dart';
import 'package:smart_tags/widgets/common/settings_transition_overlay.dart';
import 'package:smart_tags/widgets/connectivity_banner.dart';
import 'package:smart_tags/widgets/initial_sync_shell.dart';
import 'package:smart_tags/widgets/pending_operations_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}

/// The root widget of the application.
class MyApp extends ConsumerWidget {
  /// Creates a [MyApp] widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref
      ..watch(initialSyncProvider)
      ..watch(initialSyncLifecycleProvider)
      ..watch(passportEventQueueLifecycleProvider)
      ..watch(platformsRefreshLifecycleProvider);

    final largeTouchTargets = ref.watch(largeTouchTargetsProvider);
    final lightTheme = TouchTargets.apply(AppTheme.lightTheme, large: largeTouchTargets);
    final darkTheme = TouchTargets.apply(AppTheme.darkTheme, large: largeTouchTargets);

    return MaterialApp(
      title: 'SmartTags',
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const MainNavigation(),
      themeMode: ref.watch(themeProvider),
      builder: (context, child) {
        final customTextScale = ref.watch(textScaleProvider);
        final applyingTouchTargets = ref.watch(largeTouchTargetsTransitionProvider);
        var content = child!;
        if (customTextScale != null) {
          final mediaQuery = MediaQuery.of(context);
          final systemTextScale = mediaQuery.textScaler.scale(1);
          content = MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(customTextScale * systemTextScale),
            ),
            child: content,
          );
        }
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
    );
  }
}

List<NavigationDestination> _mainNavigationDestinations(BuildContext context) {
  final navIconSize = context.touchTargetSizes.navigationIconSize;

  NavigationDestination tab({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    return NavigationDestination(
      icon: Icon(icon, size: navIconSize),
      selectedIcon: Icon(selectedIcon, size: navIconSize),
      label: label,
    );
  }

  return [
    tab(icon: Icons.map_outlined, selectedIcon: Icons.map, label: 'Map'),
    tab(icon: Icons.search_outlined, selectedIcon: Icons.search, label: 'Search'),
    tab(
      icon: Icons.qr_code_scanner_outlined,
      selectedIcon: Icons.qr_code_scanner,
      label: 'Scan',
    ),
  ];
}

/// Main navigation shell with bottom navigation bar.
class MainNavigation extends ConsumerStatefulWidget {
  /// Creates a [MainNavigation] widget.
  const MainNavigation({super.key, this.pages});

  /// Optional tab pages for tests.
  @visibleForTesting
  final List<Widget>? pages;

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  static const int _scanTabIndex = 2;

  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages =
        widget.pages ??
        <Widget>[
          const MapScreen(),
          CatalogueScreen(onScanAgain: () => _onItemTapped(2)),
          QrScanScreen(onValidCode: () => _onItemTapped(1)),
        ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<MapFocusRequest?>(mapFocusRequestProvider, (previous, next) {
      if (next != null && _selectedIndex != 0) {
        setState(() => _selectedIndex = 0);
      }
    });

    ref.listen<ErrorNotification?>(
      errorNotificationProvider,
      (previous, next) {
        if (next != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            buildAppSnackBar(
              context: context,
              message: next.message,
              severity: AppSnackBarSeverity.error,
            ),
          );
          Future.delayed(appSnackBarDuration, () {
            ref.read(errorNotificationProvider.notifier).clearError();
          });
        }
      },
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const InitialSyncShell(),
            const ConnectivityBanner(),
            const PendingOperationsBanner(),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _pages[0],
                  _pages[1],
                  // Keep the camera/scanner off until Scan is selected (#132 review).
                  if (_selectedIndex == _scanTabIndex)
                    _pages[_scanTabIndex]
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: _mainNavigationDestinations(context),
      ),
    );
  }
}
