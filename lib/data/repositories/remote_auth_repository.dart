import 'dart:convert';

import 'package:lab1/data/network/api_client.dart';
import 'package:lab1/data/repositories/shared_prefs_auth_repository.dart';
import 'package:lab1/domain/repositories/i_auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemoteAuthRepository implements IAuthRepository {
  final ApiClient _api;
  final SharedPrefsAuthRepository _cache;

  RemoteAuthRepository({ApiClient? api, SharedPrefsAuthRepository? cache})
    : _api = api ?? ApiClient(),
      _cache = cache ?? SharedPrefsAuthRepository();

  @override
  Future<bool> signUp(String name, String email, String password) async {
    try {
      await _api.post('/users', {'name': name, 'email': email});
      await _storeToken(email);
      return await _cache.signUp(name, email, password);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> signIn(String email, String password) async {
    try {
      await _api.post('/posts', {'email': email});
      await _storeToken(email);
      if (await _cache.signIn(email, password)) return true;
      return await _cache.signUp(email.split('@').first, email, password);
    } catch (_) {
      return false;
    }
  }

  Future<void> _storeToken(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = base64Url.encode(utf8.encode('{"sub":"$email"}'));
    await prefs.setString(
      ApiClient.tokenKey,
      'eyJhbGciOiJIUzI1NiJ9.$payload.sig',
    );
  }

  @override
  Future<String?> getCurrentUser() => _cache.getCurrentUser();

  @override
  Future<String?> getCurrentEmail() => _cache.getCurrentEmail();

  @override
  Future<void> logOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiClient.tokenKey);
    await _cache.logOut();
  }
}
