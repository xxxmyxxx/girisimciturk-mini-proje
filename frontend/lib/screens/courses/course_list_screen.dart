import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/course.dart';
import '../../providers/course_provider.dart';

/// Kurs listesi ekranı - Modern tasarım
/// Liste görünümü ile tüm kursları gösterir
/// Not: Bu ekran UserDashboard içinde tab olarak kullanıldığında Scaffold YOK
/// Standalone olarak kullanıldığında (route ile) Scaffold VAR
class CourseListScreen extends StatefulWidget {
  final bool showScaffold;

  const CourseListScreen({
    super.key,
    this.showScaffold = false,
  });

  @override
  State<CourseListScreen> createState() =>
      _CourseListScreenState();
}

class _CourseListScreenState
    extends State<CourseListScreen> {

  @override
  void initState() {
    super.initState();
    // İlk yüklemede kurslar yüklü değilse yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final courseProvider = Provider.of<CourseProvider>(
        context,
        listen: false,
      );
      if (courseProvider.allCourses.isEmpty) {
        courseProvider.loadAllCourses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        if (courseProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (courseProvider.error != null) {
          return _buildErrorWidget(courseProvider);
        }

        final allCourses = courseProvider.allCourses;

        if (allCourses.isEmpty) {
          return const Center(
            child: Text('Henüz kurs bulunmuyor'),
          );
        }

        return _buildListView(allCourses);
      },
    );

    // Eğer standalone kullanılıyorsa (route ile), Scaffold ekle
    if (widget.showScaffold) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Kurslar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F2937),
          elevation: 0,
        ),
        body: content,
      );
    }

    // Dashboard içinde tab olarak kullanılıyorsa, sadece content döndür
    return content;
  }

  /// Liste görünümü
  Widget _buildListView(List<Course> courses) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return _buildListCard(context, courses[index]);
      },
    );
  }

  /// Liste kartı - Detaylı bilgi içeren kart
  Widget _buildListCard(
    BuildContext context,
    Course course,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(context, course),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCourseImage(
              course,
              width: 120,
              height: 160,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    _buildInstructorRow(course),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPriceTag(course.price),
                        _buildDurationTag(course.duration),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kurs görseli widget'ı
  Widget _buildCourseImage(
    Course course, {
    double? width,
    double? height,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        course.imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: Icon(
              Icons.school,
              size: 40,
              color: Colors.grey[400],
            ),
          );
        },
      ),
    );
  }

  /// Eğitmen bilgisi satırı
  Widget _buildInstructorRow(Course course) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundImage: NetworkImage(course.imageUrl),
          backgroundColor: Colors.grey[300],
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            course.instructorName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Fiyat etiketi
  Widget _buildPriceTag(double price) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(
          0xFF6366F1,
        ).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '₺${price.toStringAsFixed(2)}',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6366F1),
        ),
      ),
    );
  }

  /// Süre etiketi
  Widget _buildDurationTag(int duration) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          '$duration saat',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Hata widget'ı
  Widget _buildErrorWidget(CourseProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Bir hata oluştu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error ?? 'Bilinmeyen hata',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.loadAllCourses(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Detay sayfasına yönlendirme - Named route kullanarak
  void _navigateToDetail(
    BuildContext context,
    Course course,
  ) {
    Navigator.pushNamed(context, '/course/${course.id}');
  }
}
