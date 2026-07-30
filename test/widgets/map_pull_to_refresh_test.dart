import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/widgets/map_pull_to_refresh.dart';
import 'package:smart_tags/widgets/platforms_loading_banner.dart';

void main() {
  testWidgets('shows refresh arrow while pulling before fetch starts', (tester) async {
    final refreshStarted = Completer<void>();
    final refreshFinished = Completer<void>();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: MapPullToRefresh(
              onRefresh: () async {
                refreshStarted.complete();
                await refreshFinished.future;
              },
              child: const ColoredBox(
                color: Colors.blueGrey,
                child: SizedBox.expand(
                  child: Text('content'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(const Offset(200, 24));
    await gesture.moveBy(const Offset(0, 180));
    await tester.pump();

    // Still pulling — arrow only, no loading banner yet.
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byType(PlatformsLoadingBanner), findsNothing);

    await gesture.up();
    await tester.pump();
    await refreshStarted.future;
    await tester.pump();

    // Fetch triggered — arrow clears; loading banner is owned by InitialSyncShell.
    expect(find.byIcon(Icons.refresh), findsNothing);
    expect(find.byType(PlatformsLoadingBanner), findsNothing);

    refreshFinished.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('does not refresh when pull starts away from the top edge', (tester) async {
    var refreshed = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: MapPullToRefresh(
              onRefresh: () async {
                refreshed = true;
              },
              child: const ColoredBox(
                color: Colors.blueGrey,
                child: SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(const Offset(200, 200));
    await gesture.moveBy(const Offset(0, 180));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(refreshed, isFalse);
    expect(find.byIcon(Icons.refresh), findsNothing);
  });
}
