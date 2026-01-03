import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../services/course_service.dart';

/// Kurs durumunu yöneten Provider
/// Kurs listesi ve satın alınan kursları yönetir
class CourseProvider with ChangeNotifier {
  final CourseService _courseService = CourseService();

  List<Course> _allCourses = [];
  List<Course> _myCourses = [];
  bool _isLoading = false;
  String? _error;

  // Getter'lar
  List<Course> get allCourses => _allCourses;
  List<Course> get myCourses => _myCourses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Tüm kursları yükle
  Future<void> loadAllCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allCourses = await _courseService.getAllCourses();
      _error = null;
    } catch (e) {
      _error = 'Kurslar yüklenirken hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Kullanıcının satın aldığı kursları yükle
  Future<void> loadMyCourses(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myCourses = await _courseService.getMyCourses(
        userId,
      );
      _error = null;
    } catch (e) {
      _error = 'Kurslarınız yüklenirken hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Kursu satın alınan listesine ekle
  void addToMyCourses(Course course) {
    if (!_myCourses.any((c) => c.id == course.id)) {
      _myCourses.add(course);
      notifyListeners();
    }
  }

  /// Kursu ID'ye göre bul
  Course? getCourseById(int id) {
    try {
      return _allCourses.firstWhere(
        (course) => course.id == id,
      );
    } catch (e) {
      return null;
    }
  }
}
