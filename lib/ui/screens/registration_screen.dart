import 'package:flutter/material.dart';

import 'package:lab1/data/repositories/shared_prefs_auth_repository.dart';
import 'package:lab1/domain/repositories/i_auth_repository.dart';
import 'package:lab1/ui/widgets/custom_button.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final IAuthRepository _authRepository = SharedPrefsAuthRepository();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Заповніть усі поля!');
      return;
    }

    if (RegExp(r'[0-9]').hasMatch(name)) {
      _showSnackBar('Ім\'я не повинно містити цифр!');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _showSnackBar('Некоректний формат електронної пошти!');
      return;
    }

    if (password.length < 8) {
      _showSnackBar('Пароль має бути не менше 8 символів!');
      return;
    }

    setState(() => _isLoading = true);

    final success = await _authRepository.signUp(name, email, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!success) {
      _showSnackBar('Користувач з таким email вже існує!');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Реєстрація успішна! Увійдіть в акаунт.'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.person_add_alt_1,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Реєстрація',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Ім\'я',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
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
                    labelText: 'Пароль (мін. 8 символів)',
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
                  CustomButton(
                    text: 'ЗАРЕЄСТРУВАТИСЯ',
                    onPressed: _handleRegister,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
