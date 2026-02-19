import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_tags/helpers/location/location_fetcher.dart';
import 'package:smart_tags/models/platform.dart';
import 'package:smart_tags/screens/deploy_platform_screen.dart';
import 'package:smart_tags/widgets/top_navigation.dart';

class FakeLocationFetcher extends LocationFetcher {
  FakeLocationFetcher(this.location);
  final LatLng? location;

  @override
  Future<LatLng?> getUserLocation() async => location;
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
}
