import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Kullanıcı işlemleri servisi
class UserService {
  static String get baseUrl => AppConfig.fullApiUrl;
  /// Tüm eğitmenleri getir
  Future<List<Map<String, dynamic>>> getInstructors() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/instructors'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final apiResponse = jsonDecode(response.body);
        final List<dynamic> data = apiResponse['data'];
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Müsait eğitmenleri getir
  Future<List<Map<String, dynamic>>> getAvailableInstructors() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/instructors/available'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final apiResponse = jsonDecode(response.body);
        final List<dynamic> data = apiResponse['data'];
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
