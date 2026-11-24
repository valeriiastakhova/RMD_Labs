import 'package:flutter/material.dart';
import 'package:lab1/data/repositories/remote_auth_repository.dart';
import 'package:lab1/data/repositories/remote_plant_repository.dart';
import 'package:lab1/data/services/network_service.dart';
import 'package:lab1/domain/repositories/i_auth_repository.dart';
import 'package:lab1/domain/repositories/i_plant_repository.dart';
import 'package:lab1/ui/screens/dashboard_screen.dart';
import 'package:lab1/ui/screens/login_screen.dart';
import 'package:lab1/ui/screens/profile_screen.dart';
import 'package:lab1/ui/screens/registration_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final IAuthRepository authRepo = RemoteAuthRepository();
  final IPlantRepository plantRepo = RemotePlantRepository();
  final savedEmail = await authRepo.getCurrentEmail();
  final isOnline = await NetworkService().hasConnection();

  runApp(
    SmartPlantApp(
      initialRoute: savedEmail != null ? '/dashboard' : '/login',
      startedOffline: !isOnline,
      authRepository: authRepo,
      plantRepository: plantRepo,
    ),
  );
}

class SmartPlantApp extends StatelessWidget {
  final String initialRoute;
  final bool startedOffline;
  final IAuthRepository authRepository;
  final IPlantRepository plantRepository;

  const SmartPlantApp({
    required this.initialRoute,
    required this.startedOffline,
    required this.authRepository,
    required this.plantRepository,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Plant Care',
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => LoginScreen(authRepository: authRepository),
        '/register': (context) =>
            RegistrationScreen(authRepository: authRepository),
        '/dashboard': (context) => DashboardScreen(
          plantRepository: plantRepository,
          startedOffline: startedOffline,
        ),
        '/profile': (context) => ProfileScreen(authRepository: authRepository),
      },
    );
  }
}
