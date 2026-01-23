import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_amrit/helpers/location/location_fetcher.dart';
import 'package:flutter_amrit/screens/map_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

class FakeLocationFetcher extends LocationFetcher {
  FakeLocationFetcher(this.location);
  final LatLng location;

  @override
  Future<LatLng?> getUserLocation() async => location;
}

void main() {
  testWidgets('MapScreen has title', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MapScreen()));
    final titleFinder = find.text('SmartTags');
    expect(titleFinder, findsOneWidget);
  });
  testWidgets('MapScreen has find my location icon', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MapScreen()));
    final iconFinder = find.byIcon(Icons.my_location);
    expect(iconFinder, findsOneWidget);
  });
  testWidgets(
    'Find my location button updates co-ordinates to users location',
    (
      tester,
    ) async {
      const fakeLocation = LatLng(12.34, 56.78);

      // Use the test-only callback to observe when the map is centered
      final moved = Completer<LatLng>();

      await tester.pumpWidget(
        MaterialApp(
          home: MapScreen(
            // Use a fake LocationFetcher
            locationFetcher: FakeLocationFetcher(fakeLocation),
            // Check when the map is centered via the test callback
            onLocationCentered: (center) {
              if (!moved.isCompleted) moved.complete(center);
            },
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      // Tap the icon to center the map and wait for the test callback
      await tester.tap(find.byIcon(Icons.my_location));
      await tester.pump(const Duration(milliseconds: 200));

      // Wait for the callback
      final center = await moved.future.timeout(const Duration(seconds: 5));
      expect(center.latitude, fakeLocation.latitude);
      expect(center.longitude, fakeLocation.longitude);
    },
  );
}
