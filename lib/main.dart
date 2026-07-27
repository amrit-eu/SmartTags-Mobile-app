import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/providers/error_notification_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/settings_providers.dart';
import 'package:smart_tags/screens/catalogue_screen.dart';
import 'package:smart_tags/screens/map_screen.dart';
import 'package:smart_tags/screens/qr_scan_screen.dart';
import 'package:smart_tags/theme.dart';
import 'package:smart_tags/widgets/connectivity_banner.dart';
import 'package:smart_tags/widgets/initial_sync_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: MyApp()));
}

/// The root widget of the application.
class MyApp extends ConsumerWidget {
  /// Creates a [MyApp] widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref
      ..watch(initialSyncProvider)
      ..watch(initialSyncLifecycleProvider);
    return MaterialApp(
      title: 'SmartTags',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const MainNavigation(),
      themeMode: ref.watch(themeProvider),
    );
  }
}

/// Main navigation shell with bottom navigation bar.
class MainNavigation extends ConsumerStatefulWidget {
  /// Creates a [MainNavigation] widget.
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      const MapScreen(),
      const CatalogueScreen(),
      const QrScanScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ErrorNotification?>(
      errorNotificationProvider,
      (previous, next) {
        if (next != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(next.message),
              ),
            );
            Future.delayed(const Duration(seconds: 4), () {
              ref.read(errorNotificationProvider.notifier).clearError();
            });
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
            Expanded(child: _pages[_selectedIndex]),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
        ],
      ),
    );
  }
}
