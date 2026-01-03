import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

/// Kullanıcı işlemleri servisi
class UserService {
  /// Tüm eğitmenleri getir
  Future<List<Map<String, dynamic>>> getInstructors() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/users/instructors'),
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
        Uri.parse('${ApiService.baseUrl}/users/instructors/available'),
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
