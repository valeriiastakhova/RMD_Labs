import 'package:flutter/material.dart';
import 'package:lab1/data/repositories/shared_prefs_auth_repository.dart';
import 'package:lab1/data/services/network_service.dart';
import 'package:lab1/ui/screens/dashboard_screen.dart';
import 'package:lab1/ui/screens/login_screen.dart';
import 'package:lab1/ui/screens/profile_screen.dart';
import 'package:lab1/ui/screens/registration_screen.dart';

void main() async {
  // Обов'язково для роботи асинхронних плагінів до runApp
  WidgetsFlutterBinding.ensureInitialized();

  final authRepository = SharedPrefsAuthRepository();
  final networkService = NetworkService();

  // Перевіряємо збережену сесію та наявність інтернету
  final currentEmail = await authRepository.getCurrentEmail();
  final hasInternet = await networkService.hasConnection();

  final bool isLoggedIn = currentEmail != null && currentEmail.isNotEmpty;

  runApp(
    SmartPlantApp(
      initialRoute: isLoggedIn ? '/dashboard' : '/login',
      startedOffline: isLoggedIn && !hasInternet,
    ),
  );
}

class SmartPlantApp extends StatelessWidget {
  final String initialRoute;
  final bool startedOffline;

  const SmartPlantApp({
    super.key,
    this.initialRoute = '/login',
    this.startedOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Plant Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/dashboard': (context) =>
            DashboardScreen(startedOffline: startedOffline),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
