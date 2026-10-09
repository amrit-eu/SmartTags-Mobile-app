import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_tags/config/gateway_config.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/database/db_connection.dart' as conn;
import 'package:smart_tags/models/user.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/qr_passport_lookup_provider.dart';
import 'package:smart_tags/screens/platform_detail_screen.dart';
import 'package:smart_tags/screens/qr_scan_screen.dart';
import 'package:smart_tags/services/auth_service.dart';
import 'package:smart_tags/services/gateway_repository.dart';

import '../utils/test_user.dart';

class _Connection extends ConnectivityStatus {
  _Connection(this.result);

  ConnectivityResult result;

  @override
  FutureOr<ConnectivityResult?> build() => result;

  void setResult(ConnectivityResult value) {
    result = value;
    state = AsyncValue.data(value);
  }
}

class _Auth extends AuthService {
  _Auth(AppDatabase database, {this.signedIn = true}) : super(authDao: database.authDao);

  final bool signedIn;

  @override
  Future<User?> getAuthenticatedUser() async => signedIn ? createTestUser() : null;

  @override
  Future<String?> getAccessToken() async => signedIn ? 'test-token' : null;
}

class _Camera extends MobileScannerPlatform {
  MobileScannerException? startError;

  @override
  Stream<BarcodeCapture?> get barcodesStream => const Stream.empty();

  @override
  Stream<TorchState> get torchStateStream => const Stream.empty();

  @override
  Stream<double> get zoomScaleStateStream => const Stream.empty();

  @override
  Widget buildCameraView() => const SizedBox.expand();

  @override
  Future<MobileScannerViewAttributes> start(StartOptions startOptions) async {
    if (startError != null) throw startError!;
    return const MobileScannerViewAttributes(
      cameraDirection: CameraFacing.back,
      currentTorchMode: TorchState.off,
      size: Size(640, 480),
      numberOfCameras: 1,
    );
  }

  @override
  Future<void> updateScanWindow(Rect? window) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

void _scan(WidgetTester tester, String value, {bool repeat = false}) {
  final onDetect = tester.widget<MobileScanner>(find.byType(MobileScanner)).onDetect!;
  final capture = BarcodeCapture(
    barcodes: [Barcode(rawValue: value, format: BarcodeFormat.qrCode)],
  );
  onDetect(capture);
  if (repeat) onDetect(capture);
}

Future<void> _openScanner(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Pair to QR Code'));
  await tester.tap(find.text('Pair to QR Code'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump();
}

void main() {
  late AppDatabase database;
  late _Camera camera;
  late MobileScannerPlatform originalCamera;
  late _Connection connection;
  var requests = 0;

  setUp(() {
    database = AppDatabase.executor(conn.inMemoryConnection());
    originalCamera = MobileScannerPlatform.instance;
    camera = _Camera();
    MobileScannerPlatform.instance = camera;
    connection = _Connection(ConnectivityResult.wifi);
    requests = 0;
  });

  tearDown(() {
    MobileScannerPlatform.instance = originalCamera;
  });

  void testPairing(String description, Future<void> Function(WidgetTester) body) {
    testWidgets(description, (tester) async {
      try {
        await body(tester);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 100));
        await database.close();
      }
    });
  }

  Future<void> mount(
    WidgetTester tester, {
    String? qrCode,
    String? ptfId = '1004967',
    bool signedIn = true,
    Future<http.Response> Function(http.Request)? response,
  }) async {
    await database.insertPlatforms([
      PlatformsCompanion.insert(
        ref: 'DEP-1',
        ptfId: Value(ptfId),
        qrCode: Value(qrCode),
        model: 'ARVOR',
        network: 'Argo',
        category: 'Subsurface Profiler',
        lat: 0,
        lon: 0,
        status: 'OPERATIONAL',
        operationalStatus: 'Deployed',
        lastUpdated: DateTime.utc(2026),
        operationLat: 0,
        operationLon: 0,
      ),
    ]);
    final auth = _Auth(database, signedIn: signedIn);
    final gateway = GatewayRepository(
      authService: auth,
      client: MockClient((request) {
        requests++;
        if (response == null) fail('Unexpected Gateway request');
        return response(request);
      }),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          authServiceProvider.overrideWithValue(auth),
          gatewayRepositoryProvider.overrideWithValue(gateway),
          checkConnectionProvider.overrideWith(() => connection),
        ],
        child: const MaterialApp(home: PlatformDetailScreen(platformRef: 'DEP-1')),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  for (final code in <String?>[null, '', '   ']) {
    testPairing('shows the pairing action for an unpaired QR value "$code"', (tester) async {
      await mount(tester, qrCode: code);
      expect(find.text('Not paired'), findsOneWidget);
      expect(find.text('Pair to QR Code'), findsOneWidget);
    });
  }

  testPairing('hides the pairing action when a QR code is already present', (tester) async {
    await mount(tester, qrCode: 'PAIRED');
    expect(find.text('PAIRED'), findsOneWidget);
    expect(find.text('Pair to QR Code'), findsNothing);
  });

  testPairing('pairs once, returns to details, persists the code and shows green feedback', (tester) async {
    final response = Completer<http.Response>();
    await mount(
      tester,
      response: (request) {
        expect(request.method, 'POST');
        expect(request.url, GatewayConfig.pairPlatformToQrCodeUri);
        expect(request.headers['Authorization'], 'Bearer test-token');
        expect(jsonDecode(request.body), {'ptfId': 1004967, 'qrCode': 'AbC/123'});
        return response.future;
      },
    );
    final container = ProviderScope.containerOf(tester.element(find.byType(PlatformDetailScreen)));
    await _openScanner(tester);
    expect(find.byType(QrScanScreen), findsOneWidget);
    expect(tester.widget<QrScanScreen>(find.byType(QrScanScreen)).isPairing, isTrue);
    _scan(tester, 'https://www.ocean-ops.org/tracking/?code=AbC%2F123', repeat: true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(QrScanScreen), findsNothing);
    expect(find.byType(PlatformDetailScreen), findsOneWidget);
    expect(find.text('Platform: ARVOR\nReference: DEP-1\n\nQR code: AbC/123'), findsOneWidget);
    expect(requests, 0);
    await tester.tap(find.text('Pair'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(requests, 1);
    expect(find.text('Pairing...'), findsOneWidget);
    expect(tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed, isNull);
    expect(container.read(qrPassportLookupProvider).phase, QrLookupPhase.idle);

    response.complete(http.Response('{"passportsUpToDate":false}', 201));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect((await database.getPlatformByRef('DEP-1')).single.qrCode, 'AbC/123');
    expect(find.text('AbC/123'), findsOneWidget);
    expect(find.text('Pair to QR Code'), findsNothing);
    expect(find.text('Platform paired to QR code successfully.'), findsOneWidget);
    expect(tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor, Colors.green);

    await database.updatePlatforms([const PlatformsCompanion(ref: Value('DEP-1'), qrCode: Value(null))]);
    await tester.pump();
    expect(find.text('AbC/123'), findsOneWidget);
    expect(find.text('Pair to QR Code'), findsNothing);
  });

  testPairing('offline taps show the required message without opening the scanner', (tester) async {
    connection = _Connection(ConnectivityResult.none);
    await mount(tester);
    await _openScanner(tester);
    expect(find.byType(QrScanScreen), findsNothing);
    expect(find.text('Pairing functionality disabled: Offline'), findsOneWidget);
    expect(requests, 0);
  });

  testPairing('cancelling confirmation leaves the platform unpaired without a POST', (tester) async {
    await mount(tester);
    await _openScanner(tester);
    _scan(tester, 'https://www.ocean-ops.org/tracking/?code=AbC');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Pairing cancelled.'), findsOneWidget);
    expect((await database.getPlatformByRef('DEP-1')).single.qrCode, isNull);
    expect(requests, 0);
  });

  testPairing('losing connectivity during confirmation prevents the POST', (tester) async {
    await mount(tester);
    await _openScanner(tester);
    _scan(tester, 'https://www.ocean-ops.org/tracking/?code=AbC');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(AlertDialog), findsOneWidget);
    connection.setResult(ConnectivityResult.none);
    await tester.tap(find.text('Pair'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Pairing functionality disabled: Offline'), findsOneWidget);
    expect(requests, 0);
  });

  testPairing('losing connectivity while scanning prevents the POST', (tester) async {
    await mount(tester);
    await _openScanner(tester);
    connection.setResult(ConnectivityResult.none);
    _scan(tester, 'https://www.ocean-ops.org/tracking/?code=AbC');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(QrScanScreen), findsNothing);
    expect(find.text('Pairing functionality disabled: Offline'), findsOneWidget);
    expect(requests, 0);
  });

  testPairing('invalid scans return to details with red feedback and no POST', (tester) async {
    await mount(tester);
    await _openScanner(tester);
    _scan(tester, 'https://example.com/?code=AbC');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(QrScanScreen), findsNothing);
    expect(find.text('Invalid QR Code format'), findsOneWidget);
    expect(tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor, Colors.red);
    expect(requests, 0);
  });

  testPairing('cancelling returns to details without submitting', (tester) async {
    await mount(tester);
    await _openScanner(tester);
    await tester.pageBack();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(QrScanScreen), findsNothing);
    expect(find.text('Pairing cancelled.'), findsOneWidget);
    expect(requests, 0);
  });

  testPairing('camera permission errors return to details without submitting', (tester) async {
    camera.startError = const MobileScannerException(errorCode: MobileScannerErrorCode.permissionDenied);
    await mount(tester);
    await _openScanner(tester);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(QrScanScreen), findsNothing);
    expect(find.text('Camera permission is required to pair a QR code.'), findsOneWidget);
    expect(requests, 0);
  });

  for (final status in [401, 500]) {
    testPairing('a Gateway $status response leaves the platform unpaired with red feedback', (tester) async {
      await mount(tester, response: (_) async => http.Response('Failed', status));
      await _openScanner(tester);
      _scan(tester, 'https://www.ocean-ops.org/tracking/?code=AbC');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Pair'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(QrScanScreen), findsNothing);
      expect((await database.getPlatformByRef('DEP-1')).single.qrCode, isNull);
      expect(find.text('Pair to QR Code'), findsOneWidget);
      expect(tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor, Colors.red);
      expect(
        find.text(
          status == 401 ? 'Session expired. Please log in again.' : 'Failed to pair platform to QR code (Status 500)',
        ),
        findsOneWidget,
      );
    });
  }

  testPairing('a missing platform ID prevents scanning', (tester) async {
    await mount(tester, ptfId: null);
    await _openScanner(tester);
    expect(find.byType(QrScanScreen), findsNothing);
    expect(find.text('Platform ID is unavailable. Refresh platform data and try again.'), findsOneWidget);
    expect(requests, 0);
  });

  testPairing('logged out users receive login feedback before scanning', (tester) async {
    await mount(tester, signedIn: false);
    await _openScanner(tester);
    expect(find.byType(QrScanScreen), findsNothing);
    expect(find.text('Log in to pair this platform to a QR code.'), findsOneWidget);
    expect(requests, 0);
  });
}
