import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_tags/database/db.dart' hide Platform;
import 'package:smart_tags/database/db_connection.dart' as conn;
import 'package:smart_tags/helpers/location/location_fetcher.dart';
import 'package:smart_tags/models/platform.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/screens/deploy_platform_screen.dart';
import 'package:smart_tags/widgets/top_navigation.dart';

class FakeLocationFetcher extends LocationFetcher {
  FakeLocationFetcher(this.location);
  final LatLng? location;

  @override
  Future<LatLng?> getUserLocation() async => location;
}

class MockAppDatabase extends AppDatabase {
  MockAppDatabase() : super.executor(conn.inMemoryConnection());

  @override
  Future<void> updatePlatforms(List<PlatformsCompanion> platforms) async {
    throw Exception('Mocked database error');
  }
}

/// A fake Platform to use in tests.
final testPlatform = Platform(
  platformRef: 'TEST-001',
  model: 'Model 1',
  network: 'Network 1',
  latestPosition: const LatLng(0, 0),
  operationLocation: const LatLng(0, 0),
  status: PlatformStatus.active,
  operationalStatus: OperationalStatus.deployed,
  lastUpdated: DateTime(2025),
);

void main() {
  testWidgets('Deploy Platform has correct title', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DeployPlatformScreen(
            platform: testPlatform,
            action: DeployAction.deploy,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.widgetWithText(TopNavigation, 'Deploy Platform'), findsOneWidget);
  });
  testWidgets('Recover Platform has correct title', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DeployPlatformScreen(
            platform: testPlatform,
            action: DeployAction.recover,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.widgetWithText(TopNavigation, 'Recover Platform'), findsOneWidget);
  });
  testWidgets('Deploy Platform has correct fields', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DeployPlatformScreen(
            platform: testPlatform,
            action: DeployAction.deploy,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(
      find.byWidgetPredicate(
        (widget) => widget is TextFormField && widget.initialValue == testPlatform.platformRef && !widget.enabled,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is TextFormField && widget.initialValue == testPlatform.model && !widget.enabled,
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextFormField, 'Latitude'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Longitude'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Deployment Time (UTC)'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Notes'), findsOneWidget);
  });
  testWidgets('Recover Platform has correct fields', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DeployPlatformScreen(
            platform: testPlatform,
            action: DeployAction.recover,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(
      find.byWidgetPredicate(
        (widget) => widget is TextFormField && widget.initialValue == testPlatform.platformRef && !widget.enabled,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is TextFormField && widget.initialValue == testPlatform.model && !widget.enabled,
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextFormField, 'Latitude'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Longitude'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Recovery Time (UTC)'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Notes'), findsOneWidget);
  });
  testWidgets('Deploy Platform has correct button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DeployPlatformScreen(
            platform: testPlatform,
            action: DeployAction.deploy,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.widgetWithText(ElevatedButton, 'Deploy Platform'), findsOneWidget);
  });
  testWidgets('Recover Platform has correct button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DeployPlatformScreen(
            platform: testPlatform,
            action: DeployAction.recover,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.widgetWithText(ElevatedButton, 'Recover Platform'), findsOneWidget);
  });
  testWidgets('Tapping location icon auto-populates lat/lon', (tester) async {
    const fakeLocation = LatLng(12.345, 67.890);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DeployPlatformScreen(
            platform: testPlatform,
            action: DeployAction.deploy,
            locationFetcher: FakeLocationFetcher(fakeLocation),
          ),
        ),
      ),
    );
    await tester.pump();
    // Tap the location icon button
    await tester.tap(find.byIcon(Icons.my_location));
    await tester.pumpAndSettle();
    // Verify that the latitude and longitude fields are populated with the fake location
    expect(find.widgetWithText(TextFormField, 'Latitude'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Longitude'), findsOneWidget);
    final latField = tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Latitude'));
    final lonField = tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Longitude'));
    expect(latField.controller?.text, fakeLocation.latitude.toStringAsFixed(6));
    expect(lonField.controller?.text, fakeLocation.longitude.toStringAsFixed(6));
  });
  testWidgets('Tapping location icon shows toast when location is not found', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DeployPlatformScreen(
            platform: testPlatform,
            action: DeployAction.deploy,
            locationFetcher: FakeLocationFetcher(null), // Simulate location fetch failure
          ),
        ),
      ),
    );
    await tester.pump();
    // Tap the location icon button
    await tester.tap(find.byIcon(Icons.my_location));
    await tester.pumpAndSettle();
    // Verify that a SnackBar is shown with the expected message
    expect(find.text('Failed to fetch location. Please enter manually.'), findsOneWidget);
  });
  testWidgets('Submitting the form updates the corresponding platform record in the database', (tester) async {
    final platform = Platform(
      platformRef: 'TEST-001',
      model: 'Model 1',
      network: 'Network 1',
      latestPosition: const LatLng(0, 0),
      operationLocation: const LatLng(0, 0),
      status: PlatformStatus.active,
      operationalStatus: OperationalStatus.deployed,
      lastUpdated: DateTime(2025),
    );

    // Set up platform-aware in-memory database
    final db = AppDatabase.executor(conn.inMemoryConnection());
    await db
        .into(db.platforms)
        .insert(
          PlatformsCompanion.insert(
            ref: platform.platformRef,
            model: platform.model,
            network: platform.network,
            lat: platform.latestPosition.latitude,
            lon: platform.latestPosition.longitude,
            status: platform.status == PlatformStatus.active ? 'Active' : 'Inactive',
            operationalStatus: platform.operationalStatus == OperationalStatus.deployed ? 'Deployed' : 'Recovered',
            lastUpdated: platform.lastUpdated,
            operationLat: platform.operationLocation.latitude,
            operationLon: platform.operationLocation.longitude,
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp(
          home: DeployPlatformScreen(
            platform: platform,
            action: DeployAction.recover,
          ),
        ),
      ),
    );
    await tester.pump();
    // Fill in the form fields
    await tester.enterText(find.widgetWithText(TextFormField, 'Latitude'), '12.345');
    await tester.enterText(find.widgetWithText(TextFormField, 'Longitude'), '67.890');
    await tester.enterText(find.widgetWithText(TextFormField, 'Recovery Time (UTC)'), '2025-01-01 12:00:00');
    await tester.enterText(find.widgetWithText(TextFormField, 'Notes'), 'Recovered successfully');

    // Tap the submit button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Recover Platform'));
    await tester.pumpAndSettle();

    // Verify that a success SnackBar is shown
    expect(find.text('Recovery successful!'), findsOneWidget);

    // Verify that the platform record in the database has been updated with the new values
    final updatedPlatform = await (db.select(
      db.platforms,
    )..where((tbl) => tbl.ref.equals(platform.platformRef))).getSingle();

    // Unchanged
    expect(updatedPlatform.ref, platform.platformRef);
    expect(updatedPlatform.model, platform.model);
    expect(updatedPlatform.network, platform.network);
    expect(updatedPlatform.status, 'Active');

    // Updated
    expect(updatedPlatform.operationLat, 12.345);
    expect(updatedPlatform.operationLon, 67.890);
    expect(updatedPlatform.operationalStatus, 'Recovered');
    expect(updatedPlatform.operationNotes, 'Recovered successfully');

    // Clean up the database
    await db.close();
  });
  testWidgets('Submitting the form with failure of database update shows error in the UI.', (tester) async {
    final platform = Platform(
      platformRef: 'TEST-001',
      model: 'Model 1',
      network: 'Network 1',
      latestPosition: const LatLng(0, 0),
      operationLocation: const LatLng(0, 0),
      status: PlatformStatus.active,
      operationalStatus: OperationalStatus.deployed,
      lastUpdated: DateTime(2025),
    );

    // Set up mocked db that will error on update.
    final db = MockAppDatabase();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp(
          home: DeployPlatformScreen(
            platform: platform,
            action: DeployAction.recover,
          ),
        ),
      ),
    );
    await tester.pump();
    // Fill in the form fields
    await tester.enterText(find.widgetWithText(TextFormField, 'Latitude'), '12.345');
    await tester.enterText(find.widgetWithText(TextFormField, 'Longitude'), '67.890');
    await tester.enterText(find.widgetWithText(TextFormField, 'Recovery Time (UTC)'), '2025-01-01 12:00:00');
    await tester.enterText(find.widgetWithText(TextFormField, 'Notes'), 'Recovered successfully');

    // Tap the submit button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Recover Platform'));
    await tester.pumpAndSettle();

    // Verify that an error SnackBar is shown
    expect(find.text('Failed to update platform.'), findsOneWidget);
  });
}
