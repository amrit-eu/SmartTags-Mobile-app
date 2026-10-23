import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/widgets/common/container.dart';

void main() {
  group('SectionContainer', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionContainer(
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('applies full width when width is not specified', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionContainer(
              child: SizedBox.expand(),
            ),
          ),
        ),
      );

      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);

      final containerWidget = tester.widget<Container>(containerFinder);
      expect(containerWidget.constraints, isNotNull);
      expect(containerWidget.constraints!.maxWidth, double.infinity);
    });

    testWidgets('applies custom height and width', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionContainer(
              width: 200,
              height: 150,
              child: Text('Sized Child'),
            ),
          ),
        ),
      );

      expect(find.text('Sized Child'), findsOneWidget);
      expect((tester.widget(find.byType(Container)) as Container).constraints!.maxHeight, 150);
      expect((tester.widget(find.byType(Container)) as Container).constraints!.maxWidth, 200);
    });
  });

  group('ContainerRow', () {
    testWidgets('displays label and value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ContainerRow(
              label: 'Name',
              value: 'John Doe',
            ),
          ),
        ),
      );

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('applies custom color to value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ContainerRow(
              label: 'Status',
              value: 'Active',
              valueColor: Colors.green,
            ),
          ),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
      expect((tester.widget(find.text('Active')) as Text).style!.color, Colors.green);
    });

    testWidgets('arranges children in column layout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ContainerRow(
              label: 'Label',
              value: 'Value',
            ),
          ),
        ),
      );

      final column = find.byType(Column);
      expect(column, findsOneWidget);
    });
  });
}
