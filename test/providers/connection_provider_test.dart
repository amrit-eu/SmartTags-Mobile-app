// Test for connection provider.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/database/connection/native.dart' as conn;
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/main.dart';
import 'package:smart_tags/models/initial_sync_status.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/map_providers.dart';
import '../helpers/static_initial_sync_notifier.dart';
import '../helpers/test_main_navigation_pages.dart';

class TestConnectivityStatus extends ConnectivityStatus {
  ConnectivityResult? _testValue;
  @override
  FutureOr<ConnectivityResult?> build() async {
    return _testValue;
  }

  void set(ConnectivityResult? value) {
    _testValue = value;
    state = AsyncValue.data(value);
  }
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
  );
}

class _PaintedMapMarkersNotifier extends MapMarkersPaintedNotifier {
  @override
  bool build() => true;
}

void main() {
  testWidgets('does not show connectivity snackbar on network changes', (
    WidgetTester tester,
  ) async {
    final testNotifier = TestConnectivityStatus();
    final mockDatabase = AppDatabase.executor(conn.inMemoryConnection());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkConnectionProvider.overrideWith(() => testNotifier),
          initialSyncProvider.overrideWith(
            () => StaticInitialSyncNotifier(InitialSyncStatus.notNeeded),
          ),
          databaseProvider.overrideWithValue(mockDatabase),
          platformsStreamProvider.overrideWith((ref) => Stream.value([_samplePlatform()])),
          mapMarkersPaintedProvider.overrideWith(_PaintedMapMarkersNotifier.new),
        ],
        child: MaterialApp(
          home: MainNavigation(pages: testMainNavigationPages()),
        ),
      ),
    );

    testNotifier.set(ConnectivityResult.wifi);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(SnackBar), findsNothing);
  });
}
