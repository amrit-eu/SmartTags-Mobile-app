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
  testWidgets('Find my location button updates co-ordinates to users location', (
    tester,
  ) async {
    LatLng? centered;
    const fakeLocation = LatLng(12.34, 56.78);

    await tester.pumpWidget(
      MaterialApp(
        home: MapScreen(
          // Inject a fake LocationFetcher.
          locationFetcher: FakeLocationFetcher(fakeLocation),
          // Observe when the map is centered.
          onLocationCentered: (latlng) => centered = latlng,
        ),
      ),
    );

    // Allow the injected location future to complete and the widget to rebuild.
    await tester.pump();

    await tester.tap(find.byIcon(Icons.my_location));
    await tester.pump();

    expect(centered, isNotNull);
    expect(centered!.latitude, closeTo(12.34, 0.0001));
    expect(centered!.longitude, closeTo(56.78, 0.0001));
  });
}
