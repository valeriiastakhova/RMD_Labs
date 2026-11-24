import 'package:flutter/material.dart';
import 'package:lab1/domain/repositories/i_auth_repository.dart';
import 'package:lab1/ui/widgets/custom_button.dart';

typedef ProfileData = Map<String, String>;

class ProfileScreen extends StatelessWidget {
  final IAuthRepository authRepository;
  const ProfileScreen({required this.authRepository, super.key});

  Future<ProfileData> _loadProfile() async {
    final name = await authRepository.getCurrentUser() ?? 'Користувач';
    final email = await authRepository.getCurrentEmail() ?? 'user@plant.app';
    return {'name': name, 'email': email};
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Підтвердження виходу'),
        content: const Text('Ви дійсно бажаєте вийти з облікового запису?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Вийти', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await authRepository.logOut();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3142)),
        title: const Text(
          'Мій профіль',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<ProfileData>(
        future: _loadProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data ?? {'name': 'Користувач', 'email': ''};
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 48, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Text(
                user['name']!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                user['email']!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 36),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const ListTile(
                  leading: Icon(Icons.verified_user, color: Colors.green),
                  title: Text('JWT-сесія активна'),
                  subtitle: Text('Дані профілю збережено в офлайн-кеші'),
                ),
              ),
              const SizedBox(height: 36),
              CustomButton(
                text: 'ВИЙТИ З АКАУНТУ',
                onPressed: () => _confirmLogout(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
