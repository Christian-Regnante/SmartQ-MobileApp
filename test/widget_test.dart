import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartq_mobile_app/core/widgets/neumorphic_button.dart';
import 'package:smartq_mobile_app/core/widgets/neumorphic_card.dart';

void main() {
  group('SmartQ UI Widget Tests', () {
    testWidgets('1. NeumorphicButton renders text and triggers onPressed callback', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeumorphicButton(
              text: 'Join Queue',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Join Queue'), findsOneWidget);

      await tester.tap(find.byType(NeumorphicButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('2. NeumorphicButton displays progress indicator when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeumorphicButton(
              text: 'Submit',
              isLoading: true,
              onPressed: null,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('3. NeumorphicCard renders child widget properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeumorphicCard(
              child: Text('Card Content Test'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content Test'), findsOneWidget);
    });
  });
}
