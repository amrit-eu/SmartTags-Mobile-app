import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/main.dart';
import 'package:smart_tags/models/initial_sync_status.dart';
import 'package:smart_tags/providers/db_providers.dart';
import '../helpers/static_initial_sync_notifier.dart';

void main() {
  testWidgets('shows global loading banner during initial sync', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialSyncProvider.overrideWith(StaticInitialSyncNotifier.loading),
          platformsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const MaterialApp(home: MainNavigation()),
      ),
    );

    await tester.pump();

    expect(find.text('Loading platforms…'), findsOneWidget);
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
        child: const MaterialApp(home: MainNavigation()),
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
        ],
        child: const MaterialApp(home: MainNavigation()),
      ),
    );

    await tester.pump();

    expect(find.text('Loading platforms…'), findsNothing);
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
        ],
        child: const MaterialApp(home: MainNavigation()),
      ),
    );

    await tester.pump();

    expect(find.text('Could not load platforms'), findsNothing);
  });
}
