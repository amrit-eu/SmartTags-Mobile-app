import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/database/db_connection.dart' as conn;
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/qr_passport_lookup_provider.dart';
import 'package:smart_tags/screens/catalogue_screen.dart';
import 'package:smart_tags/services/auth_service.dart';
import 'package:smart_tags/services/gateway_repository.dart';
import 'package:smart_tags/widgets/platform_card.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.executor(conn.inMemoryConnection());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> populateDb() async {
    await db.insertPlatforms([
      PlatformsCompanion.insert(
        ref: 'PLT-001',
        model: 'Argo Float',
        network: 'Argo',
        lat: 10,
        lon: 10,
        status: 'OPERATIONAL',
        operationalStatus: 'Deployed',
        lastUpdated: DateTime.now(),
        operationLat: 10,
        operationLon: 10,
        category: 'Profiling Float',
      ),
      PlatformsCompanion.insert(
        ref: 'PLT-002',
        model: 'Drifting Buoy',
        network: 'DBCP',
        lat: 20,
        lon: 20,
        status: 'INACTIVE',
        operationalStatus: 'Recovered',
        lastUpdated: DateTime.now(),
        operationLat: 20,
        operationLon: 20,
        category: 'Profiling Float',
      ),
    ]);
  }

  Future<ProviderContainer> pumpScannedCatalogue(
    WidgetTester tester,
    Future<http.Response> Function(http.Request) respond, {
    VoidCallback? onScanAgain,
  }) async {
    final gateway = GatewayRepository(
      client: MockClient(respond),
      authService: AuthService(authDao: db.authDao),
    );
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        qrPassportLookupRepositoryProvider.overrideWithValue(
          QrPassportLookupRepository(
            database: db,
            gateway: gateway,
            connectivity: () async => ConnectivityResult.wifi,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: CatalogueScreen(onScanAgain: onScanAgain)),
      ),
    );
    return container;
  }

  testWidgets('CatalogueScreen shows prompt initially', (tester) async {
    await populateDb();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(
          home: CatalogueScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Enter a platform ID or model to search'), findsOneWidget);
    expect(find.byType(PlatformCard), findsNothing);
  });

  testWidgets('CatalogueScreen filters platforms by text', (tester) async {
    await populateDb();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(
          home: CatalogueScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('Enter a platform ID or model to search'), findsOneWidget);

    // Enter search text
    await tester.enterText(find.byType(TextField), 'Argo Float');
    await tester.pumpAndSettle();

    // Verify results show one PlatformCard
    expect(find.byType(PlatformCard), findsOneWidget);
    expect(find.text('Drifting Buoy'), findsNothing);

    // Cleanup
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();
  });

  testWidgets('CatalogueScreen shows no results message', (tester) async {
    await populateDb();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(
          home: CatalogueScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Enter search text that matches nothing
    await tester.enterText(find.byType(TextField), 'NonExistent');
    await tester.pumpAndSettle();

    expect(find.text('No results found'), findsOneWidget);
    expect(find.byType(PlatformCard), findsNothing);

    // Cleanup
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();
  });

  testWidgets('scanned catalogue shows loading while the lookup is pending', (tester) async {
    final response = Completer<http.Response>();
    final container = await pumpScannedCatalogue(tester, (_) => response.future);

    final lookup = container.read(qrPassportLookupProvider.notifier).lookup('AbC');
    await tester.pump();
    expect(find.text('Results for scanned QR code'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    response.complete(http.Response('{"items":[]}', 200));
    await lookup;
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('scanned catalogue shows empty state and scan again button', (tester) async {
    var scanAgainCalled = false;
    final container = await pumpScannedCatalogue(
      tester,
      (_) async => http.Response('{"items":[]}', 200),
      onScanAgain: () => scanAgainCalled = true,
    );

    await container.read(qrPassportLookupProvider.notifier).lookup('AbC');
    await tester.pump();
    expect(find.text('No passports available for this QR code'), findsOneWidget);
    await tester.tap(find.text('Scan again'));
    await tester.pump();
    expect(scanAgainCalled, isTrue);
    expect(find.text('Enter a platform ID or model to search'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('scanned catalogue shows error and retries the same QR reference', (tester) async {
    var calls = 0;
    final container = await pumpScannedCatalogue(tester, (_) async {
      calls++;
      if (calls == 1) return http.Response('Server error', 500);
      return http.Response('{"items":[{"reference":"DEP-1","passport":{"identification":{"qrCode":"AbC"}}}]}', 200);
    });

    await container.read(qrPassportLookupProvider.notifier).lookup('AbC');
    await tester.pump();
    expect(find.text('Retry lookup'), findsOneWidget);
    expect(find.byType(PlatformCard), findsNothing);

    await tester.tap(find.text('Retry lookup'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(calls, 2);
    expect(find.byType(PlatformCard), findsOneWidget);
    expect(tester.widget<PlatformCard>(find.byType(PlatformCard)).platform.ref, 'DEP-1');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('scanned catalogue filters results and restores them when the filter is cleared', (tester) async {
    final container = await pumpScannedCatalogue(
      tester,
      (_) async => http.Response(
        '{"items":['
        '{"reference":"DEP-1","passport":{"identification":{"qrCode":"AbC"}}},'
        '{"reference":"DEP-2","passport":{"identification":{"qrCode":"AbC"}}}'
        ']}',
        200,
      ),
    );

    await container.read(qrPassportLookupProvider.notifier).lookup('AbC');
    await tester.pump();
    expect(find.byType(PlatformCard), findsNWidgets(2));

    await tester.enterText(find.byType(TextField), 'DEP-1');
    await tester.pump();
    expect(tester.widget<PlatformCard>(find.byType(PlatformCard)).platform.ref, 'DEP-1');
    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    expect(find.byType(PlatformCard), findsNWidgets(2));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
