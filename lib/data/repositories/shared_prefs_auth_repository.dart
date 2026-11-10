import 'dart:convert';

import 'package:lab1/domain/repositories/i_auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsAuthRepository implements IAuthRepository {
  static const _usersDbKey = 'users_database';
  static const _currentEmailKey = 'current_user_email';

  Future<Map<String, dynamic>> _getUsersMap(SharedPreferences prefs) async {
    final String? usersJson = prefs.getString(_usersDbKey);
    if (usersJson == null) return {};
    return jsonDecode(usersJson) as Map<String, dynamic>;
  }

  @override
  Future<bool> signUp(String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedEmail = email.trim().toLowerCase();
    final usersMap = await _getUsersMap(prefs);

    if (usersMap.containsKey(normalizedEmail)) {
      return false;
    }

    usersMap[normalizedEmail] = {
      'name': name,
      'email': normalizedEmail,
      'password': password,
    };

    await prefs.setString(_usersDbKey, jsonEncode(usersMap));
    await prefs.setString(_currentEmailKey, normalizedEmail);
    return true;
  }

  @override
  Future<bool> signIn(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedEmail = email.trim().toLowerCase();
    final usersMap = await _getUsersMap(prefs);

    if (!usersMap.containsKey(normalizedEmail)) return false;

    final userData = usersMap[normalizedEmail] as Map<String, dynamic>;
    if (userData['password'] == password) {
      await prefs.setString(_currentEmailKey, normalizedEmail);
      return true;
    }
    return false;
  }

  @override
  Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentEmail = prefs.getString(_currentEmailKey);
    if (currentEmail == null) return null;

    final usersMap = await _getUsersMap(prefs);
    final userData = usersMap[currentEmail] as Map<String, dynamic>?;
    return userData?['name'] as String?;
  }

  @override
  Future<String?> getCurrentEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentEmailKey);
  }

  @override
  Future<void> logOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentEmailKey);
  }
}
