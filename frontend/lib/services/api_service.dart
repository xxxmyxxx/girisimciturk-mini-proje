import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../config/app_config.dart';

/// API servisi - Backend ile iletişim
class ApiService {
  static String get baseUrl => AppConfig.fullApiUrl;
  
  /// Login işlemi
  static Future<User?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final apiResponse = jsonDecode(response.body);
        // Yeni API response format: {success, message, data, timestamp}
        if (apiResponse['data'] != null) {
          return User.fromJson(apiResponse['data']);
        }
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
