import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/database/db_connection.dart' as conn;
import 'package:smart_tags/main.dart';
import 'package:smart_tags/models/initial_sync_status.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/screens/platform_detail_screen.dart';
import 'package:smart_tags/screens/qr_scan_screen.dart';
import 'package:smart_tags/services/auth_service.dart';
import 'package:smart_tags/services/gateway_repository.dart';
import 'package:smart_tags/widgets/platform_card.dart';

import 'helpers/static_initial_sync_notifier.dart';

class _Online extends ConnectivityStatus {
  @override
  FutureOr<ConnectivityResult?> build() => ConnectivityResult.wifi;
}

void scan(WidgetTester tester, String value) {
  final scanner = tester.widget<MobileScanner>(find.byType(MobileScanner));
  scanner.onDetect!(
    BarcodeCapture(
      barcodes: [
        Barcode(rawValue: value, format: BarcodeFormat.qrCode),
      ],
    ),
  );
}

void main() {
  testWidgets('valid tracking scan starts one lookup, opens catalogue and keeps results on return', (tester) async {
    final db = AppDatabase.executor(conn.inMemoryConnection());
    final response = Completer<http.Response>();
    var calls = 0;
    final gateway = GatewayRepository(
      client: MockClient((request) {
        calls++;
        if (calls == 1) {
          expectSync(jsonDecode(request.body), {
            'paginationEnabled': false,
            'filters': {'qrCode': 'AbC'},
          });
          return response.future;
        }
        expectSync(jsonDecode(request.body), {
          'paginationEnabled': false,
          'filters': {'qrCode': 'Def'},
        });
        return Future.value(
          http.Response(
            jsonEncode({
              'items': [
                {
                  'reference': 'DEP-3',
                  'passport': {
                    'identification': {'qrCode': 'Def'},
                  },
                },
              ],
            }),
            200,
          ),
        );
      }),
      authService: AuthService(authDao: db.authDao),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          gatewayRepositoryProvider.overrideWithValue(gateway),
          checkConnectionProvider.overrideWith(_Online.new),
          initialSyncProvider.overrideWith(() => StaticInitialSyncNotifier(InitialSyncStatus.notNeeded)),
          platformsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byIcon(Icons.qr_code_scanner_outlined));
    await tester.pump();

    scan(tester, 'https://www.ocean-ops.org/tracking/?code=AbC&source=sticker');
    scan(tester, 'https://www.ocean-ops.org/tracking/?code=AbC&source=sticker');
    await tester.pump();
    expect(find.text('Results for scanned QR code'), findsOneWidget);

    response.complete(
      http.Response(
        jsonEncode({
          'items': [
            {
              'reference': 'DEP-1',
              'passport': {
                'identification': {'qrCode': 'AbC'},
                'status': {
                  'reportingStatus': {'name': 'OPERATIONAL'},
                },
              },
            },
            {
              'reference': 'DEP-2',
              'passport': {
                'identification': {'qrCode': 'AbC'},
                'status': {
                  'reportingStatus': {'name': 'INACTIVE'},
                },
              },
            },
          ],
        }),
        200,
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(calls, 1);
    expect(find.byType(PlatformCard), findsNWidgets(2));

    final selectedRef = tester.widget<PlatformCard>(find.byType(PlatformCard).last).platform.ref;
    await tester.tap(find.byType(PlatformCard).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(PlatformDetailScreen), findsOneWidget);
    expect(tester.widget<PlatformDetailScreen>(find.byType(PlatformDetailScreen)).platformRef, selectedRef);
    await tester.pageBack();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(PlatformCard), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.qr_code_scanner_outlined));
    await tester.pump();
    scan(tester, 'https://www.ocean-ops.org/tracking/?code=Def');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    expect(calls, 2);
    expect(find.byType(PlatformCard), findsOneWidget);
    expect(tester.widget<PlatformCard>(find.byType(PlatformCard)).platform.ref, 'DEP-3');

    await tester.tap(find.text('Clear scan'));
    await tester.pump();
    expect(find.text('Enter a platform ID or model to search'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
  });

  testWidgets('invalid URL format error stays visible while the scanner is open', (tester) async {
    final db = AppDatabase.executor(conn.inMemoryConnection());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: Scaffold(body: QrScanScreen())),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    scan(tester, 'https://www.ocean-ops.org/tracking/?code=A&code=B');
    await tester.pump();
    expect(find.text('Invalid QR Code format'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Invalid QR Code format'), findsOneWidget);
    scan(tester, 'https://www.ocean-ops.org/tracking/?code=A&code=B');
    await tester.pump();
    expect(find.text('Invalid QR Code format'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await db.close();
  });

  testWidgets('invalid scan message stays on scanner and clears for a valid scan', (tester) async {
    final db = AppDatabase.executor(conn.inMemoryConnection());
    final gateway = GatewayRepository(
      client: MockClient((_) async => http.Response('{"items":[]}', 200)),
      authService: AuthService(authDao: db.authDao),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          gatewayRepositoryProvider.overrideWithValue(gateway),
          checkConnectionProvider.overrideWith(_Online.new),
          initialSyncProvider.overrideWith(() => StaticInitialSyncNotifier(InitialSyncStatus.notNeeded)),
          platformsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byIcon(Icons.qr_code_scanner_outlined));
    await tester.pump();
    scan(tester, 'invalid');
    await tester.pump();
    expect(find.text('Invalid QR Code format'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.map_outlined));
    await tester.pump();
    expect(find.text('Invalid QR Code format'), findsNothing);

    await tester.tap(find.byIcon(Icons.qr_code_scanner_outlined));
    await tester.pump();
    scan(tester, 'invalid');
    await tester.pump();
    expect(find.text('Invalid QR Code format'), findsOneWidget);

    final scanner = tester.widget<MobileScanner>(find.byType(MobileScanner));
    scanner.onDetect!(
      const BarcodeCapture(
        barcodes: [
          Barcode(rawValue: 'invalid', format: BarcodeFormat.qrCode),
          Barcode(rawValue: 'https://www.ocean-ops.org/tracking/?code=AbC', format: BarcodeFormat.qrCode),
        ],
      ),
    );
    await tester.pump();
    expect(find.text('Results for scanned QR code'), findsOneWidget);
    expect(find.text('Invalid QR Code format'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
  });
}
