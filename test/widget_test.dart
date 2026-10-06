import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab1/main.dart';

void main() {
  testWidgets(
    'Counter and input smoke test',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.text('0'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    },
  );
}
