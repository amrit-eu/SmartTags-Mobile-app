import 'package:flutter/material.dart';
import 'package:flutter_amrit/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Should be able to navigate to QR Scanner page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Scan'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.qr_code_scanner_outlined));
    await tester.pump();

    expect(find.text('Scan QR Code'), findsOneWidget);
  });
}

