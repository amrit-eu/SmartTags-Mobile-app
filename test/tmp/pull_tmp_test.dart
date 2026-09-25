import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/widgets/map_pull_to_refresh.dart';

void main() {
  testWidgets('pull on appbar title', (tester) async {
    var called = 0;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SafeArea(
              bottom: false,
              child: PullToRefresh(
                edgeStartMaxY: kToolbarHeight + 100,
                onRefresh: () async => called++,
                child: Column(
                  children: [
                    SizedBox(
                      height: kToolbarHeight,
                      child: AppBar(title: const Text('Alerts'), leading: const BackButton()),
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.drag(find.text('Alerts'), const Offset(0, 200));
    await tester.pumpAndSettle();
    expect(called, 1);
  });
}
