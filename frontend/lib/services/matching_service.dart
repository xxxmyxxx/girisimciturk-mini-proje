import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/live_lesson_request.dart';

/// Canlı ders eşleştirme servisi (Uber mantığı)
class MatchingService {
  static String get baseUrl => AppConfig.fullApiUrl;

  /// Canlı ders talebi oluştur
  Future<Map<String, dynamic>> requestLiveLesson(int userId, int courseId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/matching/request-lesson'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'courseId': courseId,
        }),
      );

      if (response.statusCode == 200) {
        final apiResponse = jsonDecode(response.body);
        final data = apiResponse['data'];
        return {
          'success': true,
          'message': apiResponse['message'] ?? 'Eğitmen atandı!',
          'instructorName': data['instructorName'] ?? 'Eğitmeniniz',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Şu anda müsait eğitmen bulunamadı.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
      };
    }
  }

  /// Kullanıcının canlı ders taleplerini getir
  Future<List<LiveLessonRequest>> getUserRequests(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/matching/my-requests/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final apiResponse = jsonDecode(response.body);
        final List<dynamic> data = apiResponse['data'];
        return data.map((json) => LiveLessonRequest.fromJson(json)).toList();
      } else {
        throw Exception('Talepler yüklenemedi');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  /// Eğitmenin canlı ders taleplerini getir
  Future<List<LiveLessonRequest>> getInstructorRequests(int instructorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/matching/instructor-requests/$instructorId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final apiResponse = jsonDecode(response.body);
        final List<dynamic> data = apiResponse['data'];
        return data.map((json) => LiveLessonRequest.fromJson(json)).toList();
      } else {
        throw Exception('Talepler yüklenemedi');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  /// Eğitmenin dashboard verilerini getir
  Future<Map<String, dynamic>> getInstructorDashboard(int instructorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/matching/instructor-dashboard/$instructorId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final apiResponse = jsonDecode(response.body);
        final data = apiResponse['data'];
        
        List<dynamic> coursesJson = data['courses'] ?? [];
        
        return {
          'lessonRequests': data['lessonRequests'] ?? [],
          'courses': coursesJson,
          'totalRequests': data['totalRequests'] ?? 0,
          'pendingRequests': data['pendingRequests'] ?? 0,
          'confirmedRequests': data['confirmedRequests'] ?? 0,
        };
      } else {
        throw Exception('Dashboard verileri yüklenemedi');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }
}
