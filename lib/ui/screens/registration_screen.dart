import 'package:flutter/material.dart';
import 'package:lab1/data/services/network_service.dart';
import 'package:lab1/domain/repositories/i_auth_repository.dart';
import 'package:lab1/ui/widgets/custom_button.dart';

class RegistrationScreen extends StatefulWidget {
  final IAuthRepository authRepository;
  const RegistrationScreen({required this.authRepository, super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _networkService = NetworkService();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _validate(String name, String email, String pass) {
    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      return 'Заповніть усі поля!';
    }
    if (RegExp(r'[0-9]').hasMatch(name)) {
      return 'Ім\'я не повинно містити цифр!';
    }
    if (!email.contains('@') || !email.contains('.')) {
      return 'Некоректний формат електронної пошти!';
    }
    if (pass.length < 8) return 'Пароль має бути не менше 8 символів!';
    return null;
  }

  Future<void> _handleRegister() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final err = _validate(name, email, pass);
    if (err != null) return _showSnackBar(err, Colors.red);

    if (!await _networkService.hasConnection()) {
      if (!mounted) return;
      return _showSnackBar('Відсутнє інтернет-з\'єднання!', Colors.red);
    }

    setState(() => _isLoading = true);
    final ok = await widget.authRepository.signUp(name, email, pass);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!ok) return _showSnackBar('Помилка реєстрації!', Colors.red);
    _showSnackBar('Реєстрація успішна! Увійдіть в акаунт.', Colors.green);
    Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
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
                  controller: _nameCtrl,
                  decoration: _deco('Ім\'я', Icons.person_outline),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _deco('Електронна пошта', Icons.email_outlined),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration:
                      _deco('Пароль (мін. 8 символів)', Icons.lock_outline),
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
