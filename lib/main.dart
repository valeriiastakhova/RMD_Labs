import 'package:flutter/material.dart';

import 'package:lab1/ui/screens/dashboard_screen.dart';
import 'package:lab1/ui/screens/login_screen.dart';
import 'package:lab1/ui/screens/profile_screen.dart';
import 'package:lab1/ui/screens/registration_screen.dart';

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
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
