import 'package:flutter/material.dart';
import 'package:lab1/screens/dashboard_screen.dart';
import 'package:lab1/screens/login_screen.dart';
import 'package:lab1/screens/profile_screen.dart';
import 'package:lab1/screens/registration_screen.dart';

void main() {
  runApp(const SmartPlantApp());
}

class SmartPlantApp extends StatelessWidget {
  const SmartPlantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Plant Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.green.shade50,
      ),
      // Налаштування базової маршрутизації
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        // Тут згодом додамо інші екрани:
        '/register': (context) => const RegistrationScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
