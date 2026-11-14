import 'package:flutter/material.dart';

import 'package:lab1/data/repositories/shared_prefs_auth_repository.dart';
import 'package:lab1/domain/repositories/i_auth_repository.dart';
import 'package:lab1/ui/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final IAuthRepository _authRepository = SharedPrefsAuthRepository();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Заповніть усі поля!');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _showSnackBar('Некоректний формат пошти!');
      return;
    }

    setState(() => _isLoading = true);

    final success = await _authRepository.signIn(email, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
        (route) => false,
      );
    } else {
      _showSnackBar('Невірний email або пароль!');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.eco, size: 100, color: Colors.green),
                const SizedBox(height: 24),
                const Text(
                  'Smart Plant Care',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Увійдіть, щоб дбати про свої рослини',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Електронна пошта',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  CustomButton(text: 'УВІЙТИ', onPressed: _handleLogin),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text(
                    'Немає акаунту? Зареєструватися',
                    style: TextStyle(color: Colors.green, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
