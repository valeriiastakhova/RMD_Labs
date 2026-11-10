import 'package:flutter/material.dart';

import 'package:lab1/data/repositories/shared_prefs_auth_repository.dart';
import 'package:lab1/domain/repositories/i_auth_repository.dart';
import 'package:lab1/ui/widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final IAuthRepository _authRepository = SharedPrefsAuthRepository();
  String _userName = 'Завантаження...';
  String _userEmail = 'Завантаження...';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await _authRepository.getCurrentUser();
    final email = await _authRepository.getCurrentEmail();
    if (!mounted) return;
    setState(() {
      _userName = name ?? 'Користувач';
      _userEmail = email ?? 'valeri@gmail.com';
    });
  }

  Future<void> _handleLogout() async {
    await _authRepository.logOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 50, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            _userName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _userEmail,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 40),
          _buildProfileOption(
            Icons.settings,
            'Налаштування системи',
            Colors.blueGrey,
          ),
          _buildProfileOption(
            Icons.notifications_active,
            'Сповіщення датчиків',
            Colors.orangeAccent,
          ),
          _buildProfileOption(
            Icons.security,
            'Безпека та приватність',
            Colors.teal,
          ),
          const SizedBox(height: 40),
          CustomButton(text: 'ВИЙТИ З АКАУНТУ', onPressed: _handleLogout),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () {},
      ),
    );
  }
}
