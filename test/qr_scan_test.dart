import 'package:flutter/material.dart';
import 'package:flutter_amrit/main.dart';
import 'package:flutter_amrit/screens/qr_scan_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  testWidgets('Should be able to navigate to QR Scanner page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Scan'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.qr_code_scanner_outlined));
    await tester.pump();

    expect(find.text('Scan QR Code'), findsOneWidget);
  });

  testWidgets('QR scanner can resolve a valid OceanTags URL from QR code', (
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
      rawValue: 'https://www.ocean-ops.org/oceantags/RFHCZ3S',
      format: BarcodeFormat.qrCode,
    );
    scanner.onDetect!(
      const BarcodeCapture(barcodes: [fakeBarcode]),
    );
    await tester.pump();
    expect(find.text('Platform Reference:'), findsOneWidget);
    expect(find.text('RFHCZ3S'), findsOneWidget);
  });

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
