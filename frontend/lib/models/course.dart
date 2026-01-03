/// Kurs modeli
class Course {
  final int id;
  final String title;
  final String description;
  final int instructorId;
  final String instructorName;
  final double price;
  final String imageUrl;
  final int duration;
  final String level;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructorId,
    required this.instructorName,
    required this.price,
    required this.imageUrl,
    required this.duration,
    required this.level,
  });

  /// JSON'dan Course nesnesi oluştur
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      instructorId: json['instructorId'],
      instructorName: json['instructorName'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      duration: json['duration'] ?? 0,
      level: json['level'] ?? 'Başlangıç',
    );
  }
}
