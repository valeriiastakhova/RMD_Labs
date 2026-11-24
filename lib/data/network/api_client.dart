import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

typedef HeadersMap = Map<String, String>;

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiClient {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String tokenKey = 'auth_jwt_token';
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<HeadersMap> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path) async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl$path'), headers: await _headers())
          .timeout(const Duration(seconds: 6));
      return _parse(res);
    } on SocketException {
      throw ApiException('Немає з\'єднання з сервером');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Помилка запиту: $e');
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final res = await _client
          .post(
            Uri.parse('$baseUrl$path'),
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 6));
      return _parse(res);
    } on SocketException {
      throw ApiException('Немає з\'єднання з сервером');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Помилка відправки: $e');
    }
  }

  dynamic _parse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }
    throw ApiException('HTTP помилка ${res.statusCode}', res.statusCode);
  }
}
