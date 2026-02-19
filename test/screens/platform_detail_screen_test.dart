import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/database/db.dart' hide AppDatabase;
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/screens/platform_detail_screen.dart';

const String testRef = 'TEST-001';

/// A fake Drift Platform row used to override the provider in tests.
final testDbPlatform = Platform(
  id: 1,
  ref: testRef,
  model: 'Model 1',
  network: 'Network 1',
  lat: 0,
  lon: 0,
  status: 'Active',
  operationalStatus: 'Deployed',
  lastUpdated: DateTime(2025),
  operationLat: 0,
  operationLon: 0,
);

/// Builds a [ProviderScope] with [platformByRefStreamProvider] overridden
/// to return [testDbPlatform] without hitting a real database.
Widget buildTestWidget() {
  return ProviderScope(
    overrides: [
      platformByRefStreamProvider(testRef).overrideWith(
        (ref) => Stream.value(testDbPlatform),
      ),
    ],
    child: const MaterialApp(
      home: PlatformDetailScreen(platformRef: testRef),
    ),
  );
}

void main() {
  testWidgets('Platform Detail has title', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pump();
    expect(find.text('Platform Details'), findsOneWidget);
  });

  testWidgets('Platform Details has map', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pump();
    expect(find.byType(FlutterMap), findsOneWidget);
  });

  testWidgets('Platform Details has marker on map', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pump();
    expect(find.byIcon(Icons.location_on), findsOneWidget);
  });

  testWidgets('Platform Details has back arrow', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pump();
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });
}
