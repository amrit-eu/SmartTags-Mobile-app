import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/database/db_connection.dart' as conn;
import 'package:smart_tags/helpers/location/location_fetcher.dart';
import 'package:smart_tags/providers.dart';
import 'package:smart_tags/screens/map_screen.dart';

class FakeLocationFetcher extends LocationFetcher {
  FakeLocationFetcher(this.location);
  final LatLng? location;

  @override
  Future<LatLng?> getUserLocation() async => location;
}

void main() {
  testWidgets('MapScreen has title', (tester) async {
    final db = AppDatabase.executor(conn.inMemoryConnection());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(
          home: MapScreen(),
        ),
      )
    );
    final titleFinder = find.text('SmartTags');
    expect(titleFinder, findsOneWidget);
    await db.close();
  });
  testWidgets('MapScreen has "Find my location" icon', (tester) async {
    final db = AppDatabase.executor(conn.inMemoryConnection());
    await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: MapScreen(),
          ),
        )
    );
    final iconFinder = find.byIcon(Icons.my_location);
    expect(iconFinder, findsOneWidget);
    await db.close();
  });
  testWidgets(
    'Find my location button updates co-ordinates to users location',
    (
      tester,
    ) async {
      final db = AppDatabase.executor(conn.inMemoryConnection());
      const fakeLocation = LatLng(12.34, 56.78);

      // Use the test-only callback to observe when the map is centered
      final moved = Completer<LatLng>();
      await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseProvider.overrideWithValue(db),
            ],
            child: MaterialApp(
              home: MapScreen(
                // Use a fake LocationFetcher
                locationFetcher: FakeLocationFetcher(fakeLocation),
                // Check when the map is centered via the test callback
                onLocationCentered: (center) {
                  if (!moved.isCompleted) moved.complete(center);
                },
              ),
            ),
          )
      );

      await tester.pump(const Duration(milliseconds: 500));
      // Tap the icon to center the map and wait for the test callback
      await tester.tap(find.byIcon(Icons.my_location));
      await tester.pump(const Duration(milliseconds: 200));

      // Wait for the callback
      final center = await moved.future.timeout(const Duration(seconds: 5));
      expect(center.latitude, fakeLocation.latitude);
      expect(center.longitude, fakeLocation.longitude);
      // Unmount widget before closing the database to ensure StreamBuilder
      // listeners are disposed and the DB can close cleanly.
      await tester.pumpWidget(const SizedBox.shrink());
      // Allow the widget tree to process disposal and cancel streams.
      await tester.pump(const Duration(milliseconds: 100));
      await db.close();
    },
  );
  testWidgets(
    'Toast displays when current location is unavailable.',
    (
      tester,
    ) async {
      final db = AppDatabase.executor(conn.inMemoryConnection());

      await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseProvider.overrideWithValue(db),
            ],
            child: MaterialApp(
              home: MapScreen(
                // Use a fake LocationFetcher
                locationFetcher: FakeLocationFetcher(null),
              ),
            ),
          )
      );

      await tester.pump(const Duration(milliseconds: 500));
      // Tap the icon to center the map and wait for the test callback
      await tester.tap(find.byIcon(Icons.my_location));
      await tester.pump(const Duration(milliseconds: 200));

      final toastFinder = find.byType(SnackBar);
      final errorTextFinder = find.text('Unable to fetch current location');
      final toastActionFinder = find.byType(SnackBarAction);
      
      // Assert toast is found
      expect(toastFinder, findsOneWidget);
      expect(errorTextFinder, findsOne);
      expect(toastActionFinder, findsOneWidget);

      // Unmount widget before closing the database to ensure StreamBuilder
      // listeners are disposed and the DB can close cleanly.
      await tester.pumpWidget(const SizedBox.shrink());
      // Allow the widget tree to process disposal and cancel streams.
      await tester.pump(const Duration(milliseconds: 100));
      await db.close();
    },
  );
}
