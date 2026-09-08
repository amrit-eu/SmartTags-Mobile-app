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
  lat: 12.345,
  lon: 67.89,
  status: 'OPERATIONAL',
  operationalStatus: 'Deployed',
  lastUpdated: DateTime.utc(2025, 6, 8, 23, 54, 33),
  operationLat: 0,
  operationLon: 0,
);

final testDbPlatformPassport = Platform(
  id: 1,
  ref: testRef,
  model: 'PROVOR_MT',
  network: 'Argo',
  lat: 33.815,
  lon: 149.765,
  status: 'OPERATIONAL',
  operationalStatus: 'Deployed',
  lastUpdated: DateTime.utc(2002, 6, 8, 23, 54, 33),
  operationLat: 33.999,
  operationLon: 143.993,
  platformCategory: 'Float',
  wigosId: '2900314',
  observingNetwork: 'Argo',
);

/// Builds a [ProviderScope] with [platformByRefStreamProvider] overridden
/// to return [testDbPlatform] without hitting a real database.
Widget buildTestWidget({Platform? platform}) {
  final row = platform ?? testDbPlatform;
  return ProviderScope(
    overrides: [
      platformByRefStreamProvider(testRef).overrideWith(
        (ref) => Stream.value(row),
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

  testWidgets('Platform summary shows passport metadata (#97)', (tester) async {
    await tester.pumpWidget(buildTestWidget(platform: testDbPlatformPassport));
    await tester.pump();

    expect(find.text('Float'), findsOneWidget);
    expect(find.text('PROVOR_MT'), findsOneWidget);
    expect(find.text('WIGOS ID'), findsOneWidget);
    expect(find.text('2900314'), findsOneWidget);
    expect(find.text('Latest observation'), findsWidgets);
    expect(find.text('33.815°N, 149.765°E'), findsOneWidget);
    expect(find.text('Observing network'), findsOneWidget);
    expect(find.text('Argo'), findsOneWidget);
    expect(find.text('Deployed'), findsOneWidget);
  });

  testWidgets('Platform summary shows dash for missing passport fields (#97)', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pump();

    expect(find.text('WIGOS ID'), findsOneWidget);
    expect(find.text('-'), findsWidgets);
  });
}
