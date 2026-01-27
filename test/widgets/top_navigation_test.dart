import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/widgets/common/user_icon_button.dart';
import 'package:smart_tags/widgets/top_navigation.dart';

void main() {
  group('TopNavigation', () {
    testWidgets('TopNavigation displays default title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: TopNavigation(),
          ),
        ),
      );

      expect(find.text('Smart Tags'), findsOneWidget);
    });

    testWidgets('TopNavigation displays custom title', (tester) async {
      const customTitle = 'Custom Title';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: TopNavigation(title: const Text(customTitle)),
          ),
        ),
      );

      expect(find.text(customTitle), findsOneWidget);
      expect(find.text('Smart Tags'), findsNothing);
    });

    testWidgets('TopNavigation displays UserIconButton by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: TopNavigation(),
          ),
        ),
      );

      expect(find.byType(UserIconButton), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('TopNavigation displays custom actions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: TopNavigation(
              actions: [
                IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byType(UserIconButton), findsNothing);
    });

    testWidgets('TopNavigation displays leading widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: TopNavigation(leading: const BackButton()),
          ),
        ),
      );

      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('TopNavigation displays custom title with leading widget', (tester) async {
      const customTitle = 'Details Screen';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: TopNavigation(
              title: const Text(customTitle),
              leading: const BackButton(),
            ),
          ),
        ),
      );

      expect(find.text(customTitle), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('TopNavigation displays custom title with custom actions', (tester) async {
      const customTitle = 'Search Screen';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: TopNavigation(
              title: const Text(customTitle),
              actions: [
                IconButton(icon: const Icon(Icons.search), onPressed: () {}),
              ],
            ),
          ),
        ),
      );

      expect(find.text(customTitle), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byType(UserIconButton), findsNothing);
    });

    testWidgets('TopNavigation displays empty actions list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: TopNavigation(actions: const []),
          ),
        ),
      );

      expect(find.byType(UserIconButton), findsNothing);
      expect(find.byIcon(Icons.person), findsNothing);
    });
  });
}
