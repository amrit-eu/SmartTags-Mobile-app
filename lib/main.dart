import 'package:flutter/material.dart';
import 'package:flutter_amrit/database/db.dart';
import 'package:flutter_amrit/screens/map_screen.dart';
import 'package:flutter_amrit/screens/qr_scan_screen.dart';
import 'package:flutter_amrit/services/oceanops_repository.dart';
import 'package:flutter_amrit/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();

  // Initial data synchronization
  final repository = OceanOpsRepository();
  try {
    final platforms = await repository.fetchPlatforms();
    await database.syncPlatforms(platforms);
  } on Exception catch (e) {
    debugPrint('Failed to sync data: $e');
  }

  runApp(MyApp(database: database));
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  /// Creates a [MyApp] widget.
  const MyApp({required this.database, super.key});

  /// The global database instance.
  final AppDatabase database;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartTags',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: MainNavigation(database: database),
    );
  }
}

/// Main navigation shell with bottom navigation bar.
class MainNavigation extends StatefulWidget {
  /// Creates a [MainNavigation] widget.
  const MainNavigation({required this.database, super.key});

  /// The global database instance.
  final AppDatabase database;

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      MapScreen(database: widget.database),
      const _PlaceholderPage(title: 'Search', icon: Icons.search),
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
    return Scaffold(
      body: _pages[_selectedIndex],
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

/// A placeholder page for non-implemented navigation destinations.
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              '$title Page',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
