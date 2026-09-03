import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/main.dart';
import 'package:smart_tags/models/initial_sync_status.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/map_providers.dart';
import '../helpers/static_initial_sync_notifier.dart';
import '../helpers/test_main_navigation_pages.dart';

class _FixedConnectivity extends ConnectivityStatus {
  _FixedConnectivity(this.result);

  final ConnectivityResult? result;

  @override
  FutureOr<ConnectivityResult?> build() async => result;
}

Platform _samplePlatform() {
  return Platform(
    id: 1,
    ref: 'PLT-001',
    model: 'Test',
    network: 'Net',
    lat: 0,
    lon: 0,
    status: 'OPERATIONAL',
    operationalStatus: 'Deployed',
    lastUpdated: DateTime.utc(2025),
    operationLat: 0,
    operationLon: 0,
    hasLatestObservation: false,
  );
}

class _PaintedMapMarkersNotifier extends MapMarkersPaintedNotifier {
  @override
  bool build() => true;
}

void main() {
  testWidgets('shows offline banner when offline and local data exists', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkConnectionProvider.overrideWith(() => _FixedConnectivity(ConnectivityResult.none)),
          initialSyncProvider.overrideWith(
            () => StaticInitialSyncNotifier(InitialSyncStatus.notNeeded),
          ),
          platformsStreamProvider.overrideWith((ref) => Stream.value([_samplePlatform()])),
          mapMarkersPaintedProvider.overrideWith(_PaintedMapMarkersNotifier.new),
        ],
        child: MaterialApp(
          home: MainNavigation(pages: testMainNavigationPages()),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Offline — showing local data'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('hides offline banner when back online', (tester) async {
    final connectivity = _FixedConnectivity(ConnectivityResult.wifi);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkConnectionProvider.overrideWith(() => connectivity),
          initialSyncProvider.overrideWith(
            () => StaticInitialSyncNotifier(InitialSyncStatus.notNeeded),
          ),
          platformsStreamProvider.overrideWith((ref) => Stream.value([_samplePlatform()])),
          mapMarkersPaintedProvider.overrideWith(_PaintedMapMarkersNotifier.new),
        ],
        child: MaterialApp(
          home: MainNavigation(pages: testMainNavigationPages()),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Offline — showing local data'), findsNothing);
  });
}
