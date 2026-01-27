import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/database/db_connection.dart' as conn;
import 'package:smart_tags/providers.dart';
import 'package:smart_tags/screens/catalogue_screen.dart';
import 'package:test_screenshot/test_screenshot.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.executor(conn.inMemoryConnection());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> populateDb() async {
    await db.insertPlatforms([
      PlatformsCompanion.insert(
        ref: 'PLT-001',
        model: 'Argo Float',
        network: 'Argo',
        lat: 10,
        lon: 10,
        status: 'Active',
        operationalStatus: 'Deployed',
        lastUpdated: DateTime.now(),
        operationLat: 10,
        operationLon: 10,
      ),
      PlatformsCompanion.insert(
        ref: 'PLT-002',
        model: 'Drifting Buoy',
        network: 'DBCP',
        lat: 20,
        lon: 20,
        status: 'Inactive',
        operationalStatus: 'Recovered',
        lastUpdated: DateTime.now(),
        operationLat: 20,
        operationLon: 20,
      ),
    ]);
  }

  testWidgets('CatalogueScreen shows prompt initially', (tester) async {
    await populateDb();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(
          home: CatalogueScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Enter a platform ID or model to search'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('CatalogueScreen filters platforms by text', (tester) async {
    await populateDb();

    await tester.screenshotWithImages(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: const Screenshotter(
            child: MaterialApp(
              home: CatalogueScreen(),
            ),
          ),
        ),
      );
    });
    await tester.pump(const Duration(seconds: 2));
    await tester.screenshot(
      path: 'test/screens/catalogue_screen_before_search.png',
    );
    // Verify initial state
    expect(find.text('Enter a platform ID or model to search'), findsOneWidget);

    // Enter search text
    await tester.enterText(find.byType(TextField), 'Argo Float');
    await tester.pump(const Duration(seconds: 5));
    await tester.screenshot(path: 'test/screens/catalogue_screen_filtered.png');

    // Verify filtered state
    expect(find.text('Argo Float'), findsOneWidget);
    expect(find.text('Drifting Buoy'), findsNothing);
  }, skip: true);

  testWidgets('CatalogueScreen shows no results message', (tester) async {
    await populateDb();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(
          home: CatalogueScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Enter search text that matches nothing
    await tester.enterText(find.byType(TextField), 'NonExistent');
    await tester.pumpAndSettle();

    expect(find.text('No results found'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  }, skip: true);
}
