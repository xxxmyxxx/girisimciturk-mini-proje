import 'package:flutter/material.dart';

/// Canlı Ders Talebi Modeli
/// Backend'deki LiveLessonRequest modelinin Flutter karşılığı
class LiveLessonRequest {
  final int id;
  final int userId;
  final String userName;
  final int courseId;
  final String courseName;
  
  // Öğrenci tercihleri
  final String? topic;
  final String? level;
  final DateTime? preferredDateTime;
  final bool instructorSuggestsTime;
  
  // Eşleştirme bilgileri
  final int? assignedInstructorId;
  final String? assignedInstructorName;
  final double? matchingScore;
  
  // Durum bilgileri
  final String status; // PENDING, MATCHED, TIME_SUGGESTED, CONFIRMED, COMPLETED, CANCELLED
  final DateTime requestDate;
  final DateTime? matchedDate;
  final DateTime? confirmedDate;

  LiveLessonRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.courseId,
    required this.courseName,
    this.topic,
    this.level,
    this.preferredDateTime,
    required this.instructorSuggestsTime,
    this.assignedInstructorId,
    this.assignedInstructorName,
    this.matchingScore,
    required this.status,
    required this.requestDate,
    this.matchedDate,
    this.confirmedDate,
  });

  factory LiveLessonRequest.fromJson(Map<String, dynamic> json) {
    return LiveLessonRequest(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'] ?? '',
      courseId: json['courseId'],
      courseName: json['courseName'] ?? '',
      topic: json['topic'],
      level: json['level'],
      preferredDateTime: json['preferredDateTime'] != null
          ? DateTime.parse(json['preferredDateTime'])
          : null,
      instructorSuggestsTime: json['instructorSuggestsTime'] ?? false,
      assignedInstructorId: json['assignedInstructorId'],
      assignedInstructorName: json['assignedInstructorName'],
      matchingScore: json['matchingScore']?.toDouble(),
      status: json['status'],
      requestDate: DateTime.parse(json['requestDate']),
      matchedDate: json['matchedDate'] != null
          ? DateTime.parse(json['matchedDate'])
          : null,
      confirmedDate: json['confirmedDate'] != null
          ? DateTime.parse(json['confirmedDate'])
          : null,
    );
  }

  /// Durum gösterimi için Türkçe metin
  String get statusText {
    switch (status) {
      case 'PENDING':
        return 'Beklemede';
      case 'MATCHED':
        return 'Eğitmen Atandı';
      case 'TIME_SUGGESTED':
        return 'Zaman Önerisi';
      case 'CONFIRMED':
        return 'Onaylandı';
      case 'COMPLETED':
        return 'Tamamlandı';
      case 'CANCELLED':
        return 'İptal Edildi';
      default:
        return status;
    }
  }

  /// Durum için renk
  get statusColor {
    switch (status) {
      case 'PENDING':
        return const Color(0xFFF59E0B); // Amber
      case 'MATCHED':
        return const Color(0xFF10B981); // Green
      case 'TIME_SUGGESTED':
        return const Color(0xFF3B82F6); // Blue
      case 'CONFIRMED':
        return const Color(0xFF10B981); // Green
      case 'COMPLETED':
        return const Color(0xFF6B7280); // Gray
      case 'CANCELLED':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }
}
