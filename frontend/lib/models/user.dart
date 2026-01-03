/// Kullanıcı rolleri
enum Role {
  user,
  instructor,
  admin;

  /// String'den Role'e çevirme
  static Role fromString(String role) {
    switch (role.toUpperCase()) {
      case 'USER':
        return Role.user;
      case 'INSTRUCTOR':
        return Role.instructor;
      case 'ADMIN':
        return Role.admin;
      default:
        return Role.user;
    }
  }
}

/// Kullanıcı modeli
class User {
  final int id;
  final String username;
  final String fullName;
  final String email; // Email alanı eklendi
  final Role role;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.role,
  });

  /// JSON'dan User nesnesi oluştur
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userId'],
      username: json['username'],
      fullName: json['fullName'],
      email: json['email'] ?? '${json['username']}@example.com', // Fallback email
      role: Role.fromString(json['role']),
    );
  }
  
  /// Getter - name olarak fullName döndür (uyumluluk için)
  String get name => fullName;
}
