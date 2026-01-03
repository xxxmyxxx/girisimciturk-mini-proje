import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Kullanıcı durumunu yöneten Provider
/// Login, logout ve kullanıcı bilgilerini tutar
/// Session persistence ile sayfa yenilendiğinde de session korunur
class UserProvider with ChangeNotifier {
  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  bool _isInitialized = false;

  // Getter'lar
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isInitialized => _isInitialized;

  /// Session'u yükle (app başlangıcında çağrılmalı)
  Future<void> loadSession() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      final token = prefs.getString('token');

      if (userJson != null && token != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        _currentUser = User.fromJson(userMap);
        _token = token;
        notifyListeners();
      }
    } catch (e) {
      await clearSession();
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Session'u kaydet
  Future<void> _saveSession(User user, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode({
        'userId': user.id,
        'username': user.username,
        'fullName': user.fullName,
        'email': user.email,
        'role': user.role.toString().split('.').last.toUpperCase(),
      }));
      await prefs.setString('token', token);
    } catch (e) {
      // Hata durumunda sessiz devam et
    }
  }

  /// Session'u temizle
  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      await prefs.remove('token');
    } catch (e) {
      // Hata durumunda sessiz devam et
    }
  }

  /// Loading durumunu değiştir
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Kullanıcı girişi yap
  Future<void> login(User user, String token) async {
    _currentUser = user;
    _token = token;
    await _saveSession(user, token);
    notifyListeners();
  }

  /// Kullanıcı çıkışı yap
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    await clearSession();
    notifyListeners();
  }

  /// Kullanıcının rolünü kontrol et
  bool hasRole(Role role) {
    return _currentUser?.role == role;
  }

  /// Kullanıcı admin mi?
  bool get isAdmin => hasRole(Role.admin);

  /// Kullanıcı eğitmen mi?
  bool get isInstructor => hasRole(Role.instructor);

  /// Kullanıcı normal kullanıcı mı?
  bool get isUser => hasRole(Role.user);
}
