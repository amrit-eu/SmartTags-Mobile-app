// Tests for connection checking.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/helpers/connection/connection_checking.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Widget testWidget = ProviderScope(
  child: MaterialApp(
    scaffoldMessengerKey: scaffoldMessengerKey,
    home: const Scaffold()
  )
);

void main() {

  testWidgets('Check that a connectivity result of none creates the correct SnackBar message.',
    (WidgetTester tester) async {
      final controller = StreamController<List<ConnectivityResult>>();

      final checker = CheckConnection(
        scaffoldMessengerKey: scaffoldMessengerKey,
        connectivityStream: controller.stream
      );

      await tester.pumpWidget(testWidget);
      checker.init();
      controller.add([ConnectivityResult.none]);
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Network connection lost'), findsOne);

      await tester.runAsync(() async {
        await checker.stop();
        await controller.close();
      });
    }
  );

  testWidgets('Check that a connectivity result of wifi creates the correct SnackBar message.',
    (WidgetTester tester) async {
      final controller = StreamController<List<ConnectivityResult>>();

      final checker = CheckConnection(
        scaffoldMessengerKey: scaffoldMessengerKey,
        connectivityStream: controller.stream
      );

      await tester.pumpWidget(testWidget);
      checker.init();
      controller.add([ConnectivityResult.wifi]);
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Network connection available (WiFi)'), findsOne);

      await tester.runAsync(() async {
        await checker.stop();
        await controller.close();
      });
    }
  );

  testWidgets('Check that no connectivity result creates the correct SnackBar message.',
    (WidgetTester tester) async {
      final controller = StreamController<List<ConnectivityResult>>();

      final checker = CheckConnection(
        scaffoldMessengerKey: scaffoldMessengerKey,
        connectivityStream: controller.stream
      );

      await tester.pumpWidget(testWidget);
      checker.init();
      controller.add([]);
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Connection status is not known.'), findsOne);

      await tester.runAsync(() async {
        await checker.stop();
        await controller.close();
      });
    }
  );


}
