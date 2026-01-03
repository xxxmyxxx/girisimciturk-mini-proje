import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course.dart';
import '../config/app_config.dart';

/// Kurs işlemleri servisi
class CourseService {
  static String get baseUrl => AppConfig.fullApiUrl;
  /// Tüm kursları getir
  Future<List<Course>> getAllCourses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/courses'),
      );

      if (response.statusCode == 200) {
        final apiResponse = jsonDecode(response.body);
        // Yeni API response format: {success, message, data, timestamp}
        if (apiResponse['data'] != null) {
          final List<dynamic> data = apiResponse['data'];
          return data.map((json) => Course.fromJson(json)).toList();
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Kullanıcının satın aldığı kursları getir
  Future<List<Course>> getMyCourses(int userId) async {
    try {
      final url = '$baseUrl/courses/my-courses/$userId';
      
      final response = await http.get(
        Uri.parse(url),
      );
      
      if (response.statusCode == 200) {
        final apiResponse = jsonDecode(response.body);
        // Yeni API response format: {success, message, data, timestamp}
        if (apiResponse['data'] != null) {
          final List<dynamic> data = apiResponse['data'];
          return data.map((json) => Course.fromJson(json)).toList();
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
