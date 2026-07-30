import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/main.dart';
import 'package:smart_tags/models/initial_sync_status.dart';
import 'package:smart_tags/models/platforms_sync_phase.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/map_providers.dart';
import 'package:smart_tags/providers/platforms_refresh_provider.dart';
import 'package:smart_tags/providers/platforms_sync_phase_provider.dart';
import '../helpers/static_initial_sync_notifier.dart';
import '../helpers/test_main_navigation_pages.dart';

class _PaintedMapMarkersNotifier extends MapMarkersPaintedNotifier {
  @override
  bool build() => true;
}

class _PhaseNotifier extends PlatformsSyncPhaseNotifier {
  _PhaseNotifier(this.fixedPhase);

  final PlatformsSyncPhase fixedPhase;

  @override
  PlatformsSyncPhase build() => fixedPhase;
}

class _ErrorRefreshNotifier extends PlatformsRefreshNotifier {
  int refreshCount = 0;

  @override
  Future<void> build() async {
    throw StateError('Could not refresh platforms');
  }

  @override
  Future<void> refresh() async {
    refreshCount++;
    state = const AsyncValue.data(null);
  }
}

void main() {
  testWidgets('shows global loading banner during initial sync', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialSyncProvider.overrideWith(StaticInitialSyncNotifier.loading),
          platformsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: MaterialApp(
          home: MainNavigation(pages: testMainNavigationPages()),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Downloading platforms…'), findsOneWidget);
  });

  testWidgets('shows offline banner when sync skipped and database is empty', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialSyncProvider.overrideWith(
            () => StaticInitialSyncNotifier(InitialSyncStatus.skippedOffline),
          ),
          platformsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: MaterialApp(
          home: MainNavigation(pages: testMainNavigationPages()),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('No local data. Connect to the internet to download platforms.'), findsOneWidget);
  });

  testWidgets('does not show sync banner when local database already has data', (tester) async {
    final platform = Platform(
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialSyncProvider.overrideWith(
            () => StaticInitialSyncNotifier(InitialSyncStatus.notNeeded),
          ),
          platformsStreamProvider.overrideWith((ref) => Stream.value([platform])),
          mapMarkersPaintedProvider.overrideWith(_PaintedMapMarkersNotifier.new),
        ],
        child: MaterialApp(
          home: MainNavigation(pages: testMainNavigationPages()),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Downloading platforms…'), findsNothing);
    expect(find.text('Displaying platforms…'), findsNothing);
    expect(find.text('No local data. Connect to the internet to download platforms.'), findsNothing);
  });

  testWidgets('hides error banner when platforms loaded despite sync error state', (tester) async {
    final platform = Platform(
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialSyncProvider.overrideWith(
            () => StaticInitialSyncNotifier.error(Exception('failed')),
          ),
          platformsStreamProvider.overrideWith((ref) => Stream.value([platform])),
          mapMarkersPaintedProvider.overrideWith(_PaintedMapMarkersNotifier.new),
        ],
        child: MaterialApp(
          home: MainNavigation(pages: testMainNavigationPages()),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Could not load platforms'), findsNothing);
  });

  testWidgets('shows displaying banner after sync until markers are painted', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialSyncProvider.overrideWith(
            () => StaticInitialSyncNotifier(InitialSyncStatus.completed),
          ),
          platformsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: MaterialApp(
          home: MainNavigation(pages: testMainNavigationPages()),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Displaying platforms…'), findsOneWidget);
    expect(find.text('Downloading platforms…'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('shows refresh error banner with working Retry', (tester) async {
    final refreshNotifier = _ErrorRefreshNotifier();
    final platform = Platform(
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialSyncProvider.overrideWith(
            () => StaticInitialSyncNotifier(InitialSyncStatus.notNeeded),
          ),
          platformsStreamProvider.overrideWith((ref) => Stream.value([platform])),
          mapMarkersPaintedProvider.overrideWith(_PaintedMapMarkersNotifier.new),
          platformsRefreshProvider.overrideWith(() => refreshNotifier),
        ],
        child: MaterialApp(
          home: MainNavigation(pages: testMainNavigationPages()),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Could not refresh platforms'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(refreshNotifier.refreshCount, 1);
    expect(find.text('Could not refresh platforms'), findsNothing);
  });

  testWidgets('shows loading banner while sync phase is downloading', (tester) async {
    final platform = Platform(
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialSyncProvider.overrideWith(
            () => StaticInitialSyncNotifier(InitialSyncStatus.notNeeded),
          ),
          platformsStreamProvider.overrideWith((ref) => Stream.value([platform])),
          mapMarkersPaintedProvider.overrideWith(_PaintedMapMarkersNotifier.new),
          platformsSyncPhaseProvider.overrideWith(
            () => _PhaseNotifier(PlatformsSyncPhase.downloading),
          ),
        ],
        child: MaterialApp(
          home: MainNavigation(pages: testMainNavigationPages()),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Downloading platforms…'), findsOneWidget);
  });
}
