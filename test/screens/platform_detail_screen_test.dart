import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_tags/models/platform.dart';
import 'package:smart_tags/screens/platform_detail_screen.dart';

Platform testPlatform = Platform(
  id: '1',
  model: 'Model 1',
  latestPosition: const LatLng(0, 0),
  network: 'Network 1',
  status: PlatformStatus.active,
  operationalStatus: OperationalStatus.deployed,
  lastUpdated: DateTime.now(),
  operationLocation: const LatLng(0, 0),
);

void main() {
  testWidgets('Platform Detail has title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PlatformDetailScreen(platform: testPlatform),
      ),
    );
    final titleFinder = find.text('Platform details');
    expect(titleFinder, findsOneWidget);
  });

  testWidgets('Platform Details has map', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PlatformDetailScreen(platform: testPlatform),
      ),
    );
    final mapFinder = find.byType(FlutterMap);
    expect(mapFinder, findsOneWidget);
  });

  testWidgets('Platform Details has marker on map', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PlatformDetailScreen(platform: testPlatform),
      ),
    );
    final markerFinder = find.byIcon(Icons.location_on);
    expect(markerFinder, findsOneWidget);
  });

  testWidgets('Platform Details has back arrow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PlatformDetailScreen(platform: testPlatform),
      ),
    );
    final backArrowFinder = find.byIcon(Icons.arrow_back);
    expect(backArrowFinder, findsOneWidget);
  });
}
