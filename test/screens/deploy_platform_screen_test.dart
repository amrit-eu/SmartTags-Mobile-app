import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_tags/database/db.dart' hide Platform;
import 'package:smart_tags/database/db_connection.dart' as conn;
import 'package:smart_tags/models/platform.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/screens/deploy_platform_screen.dart';
import 'package:smart_tags/services/gateway_repository.dart';
import 'package:smart_tags/widgets/offline_status.dart';

import '../helpers/fake_auth_service.dart';

class MockErrorDatabase extends AppDatabase {
  /// A mock database that throws an error on update, used to test error handling in the UI.
  MockErrorDatabase() : super.executor(conn.inMemoryConnection());

  @override
  Future<void> updatePlatforms(List<PlatformsCompanion> platforms) async {
    throw Exception('Mocked database error');
  }
}

/// A fake [GatewayRepository] that always succeeds without touching auth or the network.
class _SucceedingGatewayRepository extends GatewayRepository {
  _SucceedingGatewayRepository() : super(authService: NoOpAuthService());

  @override
  Future<void> submitPassportEventJson(String body) async {}
}

/// A test notifier that simulates Wifi connectivity.
class _WifiConnectivityStatus extends ConnectivityStatus {
  @override
  FutureOr<ConnectivityResult?> build() async {
    return ConnectivityResult.wifi;
  }
}

/// A test notifier that simulates no connectivity.
class _NoConnectivityStatus extends ConnectivityStatus {
  @override
  FutureOr<ConnectivityResult?> build() async {
    return ConnectivityResult.none;
  }
}

/// A fake Platform to use in tests.
final testPlatform = Platform(
  platformRef: 'TEST-001',
  wigosId: 'test-0001-wigosid',
  platformCategory: 'test-category',
  model: 'Model 1',
  network: 'Network 1',
  latestPosition: const LatLng(0, 0),
  operationLocation: const LatLng(0, 0),
  status: PlatformStatus.operational,
  operationalStatus: OperationalStatus.deployed,
  lastUpdated: DateTime(2025),
);

void main() {
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
        (widget) => widget is TextFormField && widget.initialValue == testPlatform.wigosId && !widget.enabled,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is TextFormField && widget.initialValue == testPlatform.platformCategory && !widget.enabled,
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
        (widget) => widget is TextFormField && widget.initialValue == testPlatform.wigosId && !widget.enabled,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is TextFormField && widget.initialValue == testPlatform.platformCategory && !widget.enabled,
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextFormField, 'Latitude'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Longitude'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Recovery Time (UTC)'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Notes'), findsOneWidget);
  });
  testWidgets('Deploy Platform has correct buttons', (tester) async {
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
    expect(find.widgetWithText(ElevatedButton, 'Cancel'), findsOneWidget);
  });
  testWidgets('Recover Platform has correct buttons', (tester) async {
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
    expect(find.widgetWithText(ElevatedButton, 'Cancel'), findsOneWidget);
  });

  testWidgets('Segmented control is visible above the position row with Deploy and Recover options', (tester) async {
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

    expect(find.byType(SegmentedButton<DeployAction>), findsOneWidget);
    final segmentedButton = find.byType(SegmentedButton<DeployAction>);
    expect(find.descendant(of: segmentedButton, matching: find.text('Deploy')), findsOneWidget);
    expect(find.descendant(of: segmentedButton, matching: find.text('Recover')), findsOneWidget);

    // The segmented control must appear above the Latitude/Longitude row.
    final controlY = tester.getTopLeft(segmentedButton).dy;
    final latitudeY = tester.getTopLeft(find.widgetWithText(TextFormField, 'Latitude')).dy;
    expect(controlY, lessThan(latitudeY));
  });

  testWidgets('Toggling the segmented control flips the save button label', (tester) async {
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

    final segmentedButton = find.byType(SegmentedButton<DeployAction>);
    await tester.tap(find.descendant(of: segmentedButton, matching: find.text('Recover')));
    await tester.pump();

    expect(find.widgetWithText(ElevatedButton, 'Recover Platform'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Deploy Platform'), findsNothing);

    await tester.tap(find.descendant(of: segmentedButton, matching: find.text('Deploy')));
    await tester.pump();

    expect(find.widgetWithText(ElevatedButton, 'Deploy Platform'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Recover Platform'), findsNothing);
  });

  testWidgets('Toggling the segmented control flips the visible other fields', (tester) async {
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

    expect(find.widgetWithText(DropdownButtonFormField<String>, 'Method'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Max Water Depth (m)'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Elevation (m)'), findsOneWidget);
    expect(find.widgetWithText(DropdownButtonFormField<String>, 'Ending Cause'), findsNothing);
    expect(find.widgetWithText(TextFormField, 'Ship IMO Number'), findsOneWidget);

    await tester.tap(
      find.descendant(of: find.byType(SegmentedButton<DeployAction>), matching: find.text('Recover')),
    );
    await tester.pump();

    expect(find.widgetWithText(DropdownButtonFormField<String>, 'Method'), findsNothing);
    expect(find.widgetWithText(TextFormField, 'Max Water Depth (m)'), findsNothing);
    expect(find.widgetWithText(TextFormField, 'Elevation (m)'), findsNothing);
    expect(find.widgetWithText(DropdownButtonFormField<String>, 'Ending Cause'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Ship IMO Number'), findsOneWidget);
  });

  testWidgets('Toggling the segmented control flips the event-type wording', (tester) async {
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

    expect(find.widgetWithText(TextFormField, 'Deployment Time (UTC)'), findsOneWidget);

    await tester.tap(
      find.descendant(of: find.byType(SegmentedButton<DeployAction>), matching: find.text('Recover')),
    );
    await tester.pump();

    expect(find.widgetWithText(TextFormField, 'Recovery Time (UTC)'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Deployment Time (UTC)'), findsNothing);
  });

  testWidgets('Submitting after toggling to Recover uses the newly selected action, not the original one', (
    tester,
  ) async {
    final platform = Platform(
      ptfId: '123',
      platformRef: 'TEST-001',
      model: 'Model 1',
      network: 'Network 1',
      latestPosition: const LatLng(0, 0),
      operationLocation: const LatLng(0, 0),
      status: PlatformStatus.operational,
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
            status: platform.status.apiName,
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
          checkConnectionProvider.overrideWith(
            _WifiConnectivityStatus.new,
          ),
          gatewayRepositoryProvider.overrideWith((ref) => _SucceedingGatewayRepository()),
        ],
        child: MaterialApp(
          home: Navigator(
            pages: [
              MaterialPage(child: Scaffold(body: Container())),
              MaterialPage(
                // Screen is opened for a Deploy, but the operator will toggle it to Recover in-form.
                child: DeployPlatformScreen(
                  platform: platform,
                  action: DeployAction.deploy,
                ),
              ),
            ],
            onDidRemovePage: (page) {},
          ),
        ),
      ),
    );
    await tester.pump();

    // Toggle from Deploy to Recover before filling in the form.
    await tester.tap(
      find.descendant(of: find.byType(SegmentedButton<DeployAction>), matching: find.text('Recover')),
    );
    await tester.pump();

    // Fill in the form fields
    await tester.enterText(find.widgetWithText(TextFormField, 'Latitude'), '12.345');
    await tester.enterText(find.widgetWithText(TextFormField, 'Longitude'), '67.890');

    // Use datepicker for Recovery Time
    await tester.tap(find.widgetWithText(TextFormField, 'Recovery Time (UTC)'));
    await tester.pumpAndSettle();
    // Select date
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    // Confirm date picker (OK button)
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    // use .last to get the time picker's input field
    await tester.enterText(find.byType(TextField).last, '12:00');
    await tester.pumpAndSettle();
    // use .last to get the dialog's OK button
    await tester.tap(find.text('OK').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Notes'), 'Recovered successfully');

    // The save button label must reflect the toggled action, not the constructor-provided one.
    expect(find.widgetWithText(ElevatedButton, 'Recover Platform'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Deploy Platform'), findsNothing);

    // Tap the submit button
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Recover Platform'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Recover Platform'));
    await tester.pumpAndSettle();

    // Verify that the success SnackBar reflects the toggled action.
    expect(find.text('Recovery successful! Changes have been saved and synced.'), findsOneWidget);

    // Verify that the platform record in the database was updated as a recovery, not a deployment.
    final updatedPlatform = await (db.select(
      db.platforms,
    )..where((tbl) => tbl.ref.equals(platform.platformRef))).getSingle();

    expect(updatedPlatform.operationalStatus, 'Recovered');
    expect(updatedPlatform.latestOperationType, 'Recovered');

    // Clean up the database
    await db.close();
  });

  testWidgets('Submitting the form updates the corresponding platform record in the database (online)', (tester) async {
    final platform = Platform(
      ptfId: '123',
      platformRef: 'TEST-001',
      model: 'Model 1',
      network: 'Network 1',
      latestPosition: const LatLng(0, 0),
      operationLocation: const LatLng(0, 0),
      status: PlatformStatus.operational,
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
            status: platform.status.apiName,
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
          checkConnectionProvider.overrideWith(
            _WifiConnectivityStatus.new,
          ),
          gatewayRepositoryProvider.overrideWith((ref) => _SucceedingGatewayRepository()),
        ],
        child: MaterialApp(
          home: Navigator(
            pages: [
              MaterialPage(child: Scaffold(body: Container())),
              MaterialPage(
                child: DeployPlatformScreen(
                  platform: platform,
                  action: DeployAction.recover,
                ),
              ),
            ],
            onDidRemovePage: (page) {},
          ),
        ),
      ),
    );
    await tester.pump();

    // Fill in the form fields
    await tester.enterText(find.widgetWithText(TextFormField, 'Latitude'), '12.345');
    await tester.enterText(find.widgetWithText(TextFormField, 'Longitude'), '67.890');

    // Use datepicker for Recovery Time
    await tester.tap(find.widgetWithText(TextFormField, 'Recovery Time (UTC)'));
    await tester.pumpAndSettle();
    // Select date
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    // Confirm date picker (OK button)
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    // use .last to get the time picker's input field
    await tester.enterText(find.byType(TextField).last, '12:00');
    await tester.pumpAndSettle();
    // use .last to get the dialog's OK button
    await tester.tap(find.text('OK').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Notes'), 'Recovered successfully');

    // Tap the submit button
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Recover Platform'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Recover Platform'));
    await tester.pumpAndSettle();

    // Verify that a success SnackBar is shown
    expect(find.text('Recovery successful! Changes have been saved and synced.'), findsOneWidget);

    // Verify that the platform record in the database has been updated with the new values
    final updatedPlatform = await (db.select(
      db.platforms,
    )..where((tbl) => tbl.ref.equals(platform.platformRef))).getSingle();

    // Unchanged
    expect(updatedPlatform.ref, platform.platformRef);
    expect(updatedPlatform.model, platform.model);
    expect(updatedPlatform.network, platform.network);
    expect(updatedPlatform.status, 'OPERATIONAL');

    // Updated
    expect(updatedPlatform.operationLat, 12.345);
    expect(updatedPlatform.operationLon, 67.890);
    expect(updatedPlatform.operationalStatus, 'Recovered');
    expect(updatedPlatform.operationNotes, 'Recovered successfully');

    // Clean up the database
    await db.close();
  });
  testWidgets('Submitting the form updates the corresponding platform record in the database (offline)', (
    tester,
  ) async {
    final platform = Platform(
      ptfId: '123',
      platformRef: 'TEST-001',
      model: 'Model 1',
      network: 'Network 1',
      latestPosition: const LatLng(0, 0),
      operationLocation: const LatLng(0, 0),
      status: PlatformStatus.operational,
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
            status: platform.status.apiName,
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
          checkConnectionProvider.overrideWith(
            _NoConnectivityStatus.new,
          ),
        ],
        child: MaterialApp(
          home: Navigator(
            pages: [
              MaterialPage(child: Scaffold(body: Container())),
              MaterialPage(
                child: DeployPlatformScreen(
                  platform: platform,
                  action: DeployAction.recover,
                ),
              ),
            ],
            onDidRemovePage: (page) {},
          ),
        ),
      ),
    );
    await tester.pump();

    // Fill in the form fields
    await tester.enterText(find.widgetWithText(TextFormField, 'Latitude'), '12.345');
    await tester.enterText(find.widgetWithText(TextFormField, 'Longitude'), '67.890');

    // Use datepicker for Recovery Time
    await tester.tap(find.widgetWithText(TextFormField, 'Recovery Time (UTC)'));
    await tester.pumpAndSettle();
    // Select date
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    // Confirm date picker (OK button)
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    // use .last to get the time picker's input field
    await tester.enterText(find.byType(TextField).last, '12:00');
    await tester.pumpAndSettle();
    // use .last to get the dialog's OK button
    await tester.tap(find.text('OK').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Notes'), 'Recovered successfully');

    // Tap the submit button
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Recover Platform'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Recover Platform'));
    await tester.pumpAndSettle();

    // Verify that a success SnackBar is shown
    expect(
      find.text('Recovery successful! Changes have been saved locally and queued for sync.'),
      findsOneWidget,
    );

    // Verify that the platform record in the database has been updated with the new values
    final updatedPlatform = await (db.select(
      db.platforms,
    )..where((tbl) => tbl.ref.equals(platform.platformRef))).getSingle();

    // Unchanged
    expect(updatedPlatform.ref, platform.platformRef);
    expect(updatedPlatform.model, platform.model);
    expect(updatedPlatform.network, platform.network);
    expect(updatedPlatform.status, 'OPERATIONAL');

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
      ptfId: '123',
      platformRef: 'TEST-001',
      model: 'Model 1',
      network: 'Network 1',
      latestPosition: const LatLng(0, 0),
      operationLocation: const LatLng(0, 0),
      status: PlatformStatus.operational,
      operationalStatus: OperationalStatus.deployed,
      lastUpdated: DateTime(2025),
    );

    // Set up mocked db that will error on update.
    final db = MockErrorDatabase();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          // Avoid depending on the real connectivity_plus platform channel,
          // which never resolves in a widget test and would otherwise hang
          // enqueueOrSend until its 5s connectivity-check timeout.
          checkConnectionProvider.overrideWith(_NoConnectivityStatus.new),
        ],
        child: MaterialApp(
          home: Navigator(
            pages: [
              MaterialPage(child: Scaffold(body: Container())),
              MaterialPage(
                child: DeployPlatformScreen(
                  platform: platform,
                  action: DeployAction.recover,
                ),
              ),
            ],
            onDidRemovePage: (page) {},
          ),
        ),
      ),
    );
    await tester.pump();

    // Fill in the form fields
    await tester.enterText(find.widgetWithText(TextFormField, 'Latitude'), '12.345');
    await tester.enterText(find.widgetWithText(TextFormField, 'Longitude'), '67.890');
    // Use datepicker for Recovery Time
    await tester.tap(find.widgetWithText(TextFormField, 'Recovery Time (UTC)'));
    await tester.pumpAndSettle();
    // Select date: Jan 1, 2025
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    // Confirm date picker (OK button)
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    // use .last to get the time picker's input field
    await tester.enterText(find.byType(TextField).last, '12:00');
    await tester.pumpAndSettle();
    // use .last to get the dialog's OK button
    await tester.tap(find.text('OK').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Notes'), 'Recovered successfully');

    // Tap the submit button
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Recover Platform'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Recover Platform'));
    await tester.pumpAndSettle();

    // Verify that an error SnackBar is shown
    expect(find.text('Failed to update platform.'), findsOneWidget);
  });
  testWidgets('Live location updates the lat/lon and time fields when enabled.', (tester) async {
    final platform = Platform(
      platformRef: 'TEST-001',
      model: 'Model 1',
      network: 'Network 1',
      latestPosition: const LatLng(0, 0),
      operationLocation: const LatLng(0, 0),
      status: PlatformStatus.operational,
      operationalStatus: OperationalStatus.deployed,
      lastUpdated: DateTime(2025),
    );

    // Create mock streams for testing
    final positionController = StreamController<Position>();
    final statusController = StreamController<ServiceStatus>();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DeployPlatformScreen(
            platform: platform,
            action: DeployAction.deploy,
            positionStream: positionController.stream,
            serviceStatusStream: statusController.stream,
          ),
        ),
      ),
    );
    await tester.pump();

    // Tap the location icon button to enable live location updates
    await tester.tap(find.byIcon(Icons.my_location));
    await tester.pump();

    // Emit a position update
    final mockPosition = Position(
      latitude: 12.345,
      longitude: 67.890,
      timestamp: DateTime(2026, 1, 1, 12),
      accuracy: 10,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
    positionController.add(mockPosition);
    await tester.pump();

    // Make sure that the latitude and longitude fields are updated
    final latField = tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Latitude'));
    final lonField = tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Longitude'));
    expect(latField.controller?.text, '12.345000');
    expect(lonField.controller?.text, '67.890000');

    // Make sure that the time field is updated
    final timeField = tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Deployment Time (UTC)'));
    final timeValue = timeField.controller?.text;
    expect(timeValue, 'Jan 01, 2026, 12:00 PM');

    // Clean up
    unawaited(positionController.close());
    unawaited(statusController.close());
  });
  testWidgets('Live location stops when location services are disabled.', (tester) async {
    final platform = Platform(
      platformRef: 'TEST-001',
      model: 'Model 1',
      network: 'Network 1',
      latestPosition: const LatLng(0, 0),
      operationLocation: const LatLng(0, 0),
      status: PlatformStatus.operational,
      operationalStatus: OperationalStatus.deployed,
      lastUpdated: DateTime(2025),
    );

    // Create mock streams for testing
    final positionController = StreamController<Position>();
    final statusController = StreamController<ServiceStatus>();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DeployPlatformScreen(
            platform: platform,
            action: DeployAction.deploy,
            positionStream: positionController.stream,
            serviceStatusStream: statusController.stream,
          ),
        ),
      ),
    );
    await tester.pump();

    // Tap the location icon button to enable live location updates
    await tester.tap(find.byIcon(Icons.my_location));
    await tester.pump();

    // Emit a ServiceStatus.disabled event
    statusController.add(ServiceStatus.disabled);

    // Allow time for callback and the snackbar to appear
    await tester.pumpAndSettle();

    // Make sure that the expected SnackBar is shown
    expect(find.text('Location services disabled. Live updates stopped.'), findsOneWidget);

    // Clean up
    unawaited(positionController.close());
    unawaited(statusController.close());
  });
  testWidgets('Form validation shows error messages for non-numeric lat/lon input', (tester) async {
    final platform = Platform(
      platformRef: 'TEST-001',
      model: 'Model 1',
      network: 'Network 1',
      latestPosition: const LatLng(0, 0),
      operationLocation: const LatLng(0, 0),
      status: PlatformStatus.operational,
      operationalStatus: OperationalStatus.deployed,
      lastUpdated: DateTime(2025),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DeployPlatformScreen(
            platform: platform,
            action: DeployAction.deploy,
          ),
        ),
      ),
    );
    await tester.pump();

    // Enter invalid latitude and longitude
    await tester.enterText(find.widgetWithText(TextFormField, 'Latitude'), 'abc');
    await tester.enterText(find.widgetWithText(TextFormField, 'Longitude'), 'def');

    // Tap the submit button
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Deploy Platform'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Deploy Platform'));
    await tester.pumpAndSettle();

    // Verify that error messages are shown for the latitude and longitude fields
    expect(find.text('Latitude must be a valid number'), findsOneWidget);
    expect(find.text('Longitude must be a valid number'), findsOneWidget);
  });
  testWidgets('Form validation shows error message for invalid lat/lon values', (tester) async {
    final platform = Platform(
      platformRef: 'TEST-001',
      model: 'Model 1',
      network: 'Network 1',
      latestPosition: const LatLng(0, 0),
      operationLocation: const LatLng(0, 0),
      status: PlatformStatus.operational,
      operationalStatus: OperationalStatus.deployed,
      lastUpdated: DateTime(2025),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DeployPlatformScreen(
            platform: platform,
            action: DeployAction.deploy,
          ),
        ),
      ),
    );
    await tester.pump();

    // Enter out-of-range latitude and longitude
    await tester.enterText(find.widgetWithText(TextFormField, 'Latitude'), '100');
    await tester.enterText(find.widgetWithText(TextFormField, 'Longitude'), '-200');

    // Tap the submit button
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Deploy Platform'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Deploy Platform'));
    await tester.pumpAndSettle();

    // Verify that error messages are shown for the latitude and longitude fields
    expect(find.text('Latitude must be between -90 and 90'), findsOneWidget);
    expect(find.text('Longitude must be between -180 and 180'), findsOneWidget);
  });
  testWidgets('Form validation shows error message for missing required fields', (tester) async {
    final platform = Platform(
      platformRef: 'TEST-001',
      model: 'Model 1',
      network: 'Network 1',
      latestPosition: const LatLng(0, 0),
      operationLocation: const LatLng(0, 0),
      status: PlatformStatus.operational,
      operationalStatus: OperationalStatus.deployed,
      lastUpdated: DateTime(2025),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DeployPlatformScreen(
            platform: platform,
            action: DeployAction.deploy,
          ),
        ),
      ),
    );
    await tester.pump();

    // Tap the submit button
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Deploy Platform'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Deploy Platform'));
    await tester.pumpAndSettle();

    // Verify that error messages are shown for the latitude and longitude fields
    expect(find.text('Latitude is required'), findsOneWidget);
    expect(find.text('Longitude is required'), findsOneWidget);
    expect(find.text('Deployment Time is required'), findsOneWidget);
  });
  testWidgets('Offline status shows when the device is offline.', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkConnectionProvider.overrideWith(
            _NoConnectivityStatus.new,
          ),
        ],
        child: MaterialApp(
          home: DeployPlatformScreen(
            platform: testPlatform,
            action: DeployAction.deploy,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that the expected offline widget is shown.
    expect(find.byType(OfflineStatus), findsOneWidget);
  });
  testWidgets('Offline status does not show when the device is online.', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkConnectionProvider.overrideWith(
            _WifiConnectivityStatus.new,
          ),
        ],
        child: MaterialApp(
          home: DeployPlatformScreen(
            platform: testPlatform,
            action: DeployAction.deploy,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that the expected offline widget is not shown.
    expect(find.byType(OfflineStatus), findsNothing);
  });
}
