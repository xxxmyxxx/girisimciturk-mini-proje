import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Gelişmiş Ödeme Servisi (Stripe Entegrasyonlu)
class PaymentService {
  static String get baseUrl => AppConfig.fullApiUrl;
  /// Yeni sipariş oluştur ve Stripe Checkout URL al
  Future<Map<String, dynamic>> createOrder({
    required int userId,
    required int courseId,
    required String customerEmail,
    required String customerName,
    String? successUrl,
    String? cancelUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payment/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'courseId': courseId,
          'customerEmail': customerEmail,
          'customerName': customerName,
          'successUrl': successUrl ?? '$baseUrl/payment/success',
          'cancelUrl': cancelUrl ?? '$baseUrl/payment/cancel',
        }),
      );

      final apiResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && apiResponse['success'] == true) {
        // Yeni API response format: {success, message, data, timestamp}
        final data = apiResponse['data'];
        return {
          'success': true,
          'orderId': data['orderId'],
          'orderNumber': data['orderNumber'],
          'stripeCheckoutUrl': data['stripeCheckoutUrl'],
          'stripeSessionId': data['stripeSessionId'],
          'message': apiResponse['message'],
          'userId': userId,
          'courseId': courseId,
        };
      } else {
        return {
          'success': false,
          'message': apiResponse['message'] ?? 'Sipariş oluşturulamadı',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
      };
    }
  }

  /// Sipariş durumunu sorgula
  Future<Map<String, dynamic>> getOrderStatus(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payment/order/$orderId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final apiResponse = jsonDecode(response.body);
        return {
          'success': true,
          'order': apiResponse['data']
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Sipariş bulunamadı',
        };
      } else {
        return {
          'success': false,
          'message': 'Sipariş sorgulanamadı',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
      };
    }
  }

  /// TEST MODU: Manuel kurs atama
  Future<Map<String, dynamic>> assignCourseManually({
    required int userId,
    required int courseId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/courses/assign'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'courseId': courseId,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Kurs başarıyla atandı',
        };
      } else {
        return {
          'success': false,
          'message': 'Kurs atanamadı',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
      };
    }
  }
}
