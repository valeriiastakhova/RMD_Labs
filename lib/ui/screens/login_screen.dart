import 'package:flutter/material.dart';
import 'package:lab1/data/services/network_service.dart';
import 'package:lab1/domain/repositories/i_auth_repository.dart';
import 'package:lab1/ui/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  final IAuthRepository authRepository;
  const LoginScreen({required this.authRepository, super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final NetworkService _networkService = NetworkService();
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
    if (!await _networkService.hasConnection()) {
      if (!mounted) return;
      _showSnackBar('Відсутнє інтернет-з\'єднання! Вхід заблоковано.');
      return;
    }
    setState(() => _isLoading = true);
    final success = await widget.authRepository.signIn(email, password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (r) => false);
    } else {
      _showSnackBar('Помилка авторизації на сервері!');
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  InputDecoration _deco(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Colors.white,
  );

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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.eco, size: 96, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  'Smart Plant Care',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _deco('Електронна пошта', Icons.email_outlined),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _deco('Пароль', Icons.lock_outline),
                ),
                const SizedBox(height: 28),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  CustomButton(text: 'УВІЙТИ', onPressed: _handleLogin),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text(
                    'Немає акаунту? Зареєструватися',
                    style: TextStyle(color: Colors.green),
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
