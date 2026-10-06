import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Lab 1',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CounterScreen(),
    );
  }
}

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _counter = 0;
  final TextEditingController _controller = TextEditingController();

  void _processInput() {
    final String input = _controller.text.trim();

    // Сценарій 2: Термінальна команда обнулення
    if (input == 'Avada Kedavra') {
      setState(() {
        _counter = 0;
      });
      _controller.clear();
      return;
    }

    // Сценарій 1: Математична операція
    final int? parsedValue = int.tryParse(input);

    if (parsedValue != null) {
      setState(() {
        _counter += parsedValue;
      });
      _controller.clear();
    } else {
      // Сценарій 3: Обробка виключень
      // Розбито на кілька рядків, щоб не перевищувати ліміт у 80 символів
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Помилка: Введіть ціле число або "Avada Kedavra"',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Інтерактивний лічильник'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16), // Виправлено: 16 замість 16.0
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Поточне значення:',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '$_counter',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Введіть число або команду',
              ),
              onSubmitted: (_) => _processInput(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _processInput,
              child: const Text('Застосувати'),
            ),
          ],
        ),
      ),
    );
  }
}
