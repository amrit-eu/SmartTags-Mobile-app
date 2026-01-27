import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/database/db_connection.dart' as conn;
import 'package:smart_tags/main.dart';
import 'package:smart_tags/providers.dart';
import 'package:smart_tags/screens/qr_scan_screen.dart';

void main() {
  testWidgets('Should be able to navigate to QR Scanner page', (
    WidgetTester tester,
  ) async {
    final db = AppDatabase.executor(conn.inMemoryConnection());
    await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: MyApp(),
          ),
        )
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Scan'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.qr_code_scanner_outlined));
    await tester.pump();

    expect(find.text('Scan QR Code'), findsOneWidget);
    // Unmount widget before closing the database to ensure StreamBuilder
    // listeners are disposed and the DB can close cleanly.
    await tester.pumpWidget(const SizedBox.shrink());
    // Allow the widget tree to process disposal and cancel streams.
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
  });

  // testWidgets('QR scanner can resolve a valid OceanTags URL from QR code', (
  //   WidgetTester tester,
  // ) async {
  //   await tester.pumpWidget(
  //     const MaterialApp(
  //       home: QrScanScreen(),
  //     ),
  //   );
  //   await tester.pump();
  //
  //   final scanner = tester.widget<MobileScanner>(
  //     find.byType(MobileScanner),
  //   );
  //   const fakeBarcode = Barcode(
  //     rawValue: 'https://www.ocean-ops.org/oceantags/RFHCZ3S',
  //     format: BarcodeFormat.qrCode,
  //   );
  //   scanner.onDetect!(
  //     const BarcodeCapture(barcodes: [fakeBarcode]),
  //   );
  //   await tester.pump();
  //   expect(find.text('Weather Sensor'), findsOneWidget);
  //   expect(find.text('RFHCZ3S'), findsOneWidget);
  // });

  testWidgets('QR scanner alerts about invalid QR code', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: QrScanScreen(),
      ),
    );
    await tester.pump();

    final scanner = tester.widget<MobileScanner>(
      find.byType(MobileScanner),
    );
    const fakeBarcode = Barcode(
      rawValue: 'https://example.com/ref=ABC123',
      format: BarcodeFormat.qrCode,
    );
    scanner.onDetect!(
      const BarcodeCapture(barcodes: [fakeBarcode]),
    );
    await tester.pump();
    expect(find.text('Invalid QR Code format'), findsOneWidget);
  });
}
