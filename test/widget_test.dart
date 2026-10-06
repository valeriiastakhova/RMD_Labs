import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab1/main.dart'; // Переконайтеся, що шлях відповідає назві вашого проєкту

void main() {
  testWidgets('Counter and input field smoke test', (WidgetTester tester) async {
    // Будуємо наш застосунок
    await tester.pumpWidget(const MyApp());

    // Перевіряємо, що лічильник починається з 0 (або відповідно до вашої початкової логіки)
    expect(find.text('0'), findsOneWidget);

    // Перевіряємо наявність поля введення (TextField)
    expect(find.byType(TextField), findsOneWidget);
  });
}
