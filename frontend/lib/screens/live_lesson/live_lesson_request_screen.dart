import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/course.dart';
import '../../providers/user_provider.dart';
import '../../services/course_service.dart';
import '../../services/matching_service.dart';

/// Canlı Ders Talebi Ekranı - Uber Benzeri Mantık
/// Kullanıcı kurs seçer, sistem en uygun eğitmeni atar
class LiveLessonRequestScreen extends StatefulWidget {
  const LiveLessonRequestScreen({super.key});

  @override
  State<LiveLessonRequestScreen> createState() =>
      _LiveLessonRequestScreenState();
}

class _LiveLessonRequestScreenState
    extends State<LiveLessonRequestScreen> {
  final MatchingService _matchingService =
      MatchingService();
  final CourseService _courseService = CourseService();

  List<Course> _courses = [];
  Course? _selectedCourse;
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;

  // Eşleştirme durumu
  String _matchingStatus =
      'idle'; // idle, searching, matched, failed
  String? _matchedInstructorName;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  /// Kursları yükle
  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final courses = await _courseService.getAllCourses();
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Canlı ders talebi oluştur - Uber mantığı
  Future<void> _requestLiveLesson() async {
    if (_selectedCourse == null) {
      _showSnackBar('Lütfen bir kurs seçin', isError: true);
      return;
    }

    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final user = userProvider.currentUser;

    if (user == null) {
      _showSnackBar(
        'Kullanıcı bilgisi bulunamadı',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _matchingStatus = 'searching';
    });

    try {
      // Eğitmen arama simülasyonu (Uber'deki gibi)
      await Future.delayed(const Duration(seconds: 2));

      final result = await _matchingService
          .requestLiveLesson(user.id, _selectedCourse!.id);

      if (result['success']) {
        setState(() {
          _matchingStatus = 'matched';
          _matchedInstructorName = result['instructorName'];
        });

        // Ekranı otomatik kapatma - kullanıcı kendisi kapatacak
        // Future.delayed(const Duration(seconds: 3), () {
        //   if (mounted) {
        //     Navigator.pop(context);
        //     _showSnackBar('Eğitmeniniz atandı!');
        //   }
        // });
      } else {
        setState(() {
          _matchingStatus = 'failed';
        });
        _showSnackBar(
          result['message'] ?? 'Eşleştirme başarısız',
          isError: true,
        );
      }
    } catch (e) {
      setState(() {
        _matchingStatus = 'failed';
      });
      _showSnackBar('Bir hata oluştu: $e', isError: true);
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Canlı Ders Talebi'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      bottomNavigationBar: _matchingStatus == 'idle'
          ? _buildBottomButton()
          : null,
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _buildErrorWidget();
    }

    // Eşleştirme durumuna göre gösterim
    if (_matchingStatus == 'searching') {
      return _buildSearchingView();
    } else if (_matchingStatus == 'matched') {
      return _buildMatchedView();
    } else if (_matchingStatus == 'failed') {
      return _buildFailedView();
    }

    // Varsayılan: Kurs seçim ekranı
    return _buildCourseSelectionView();
  }

  /// Kurs seçim ekranı - İlk adım
  Widget _buildCourseSelectionView() {
    return Column(
      children: [
        // Başlık ve açıklama
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6366F1),
                const Color(0xFF8B5CF6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.live_tv,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'Canlı Ders Talebi',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hangi kurs için canlı ders almak istersiniz?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(
                    alpha: 0.9,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Kurs listesi
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 80, // Alt buton için boşluk
            ),
            itemCount: _courses.length,
            itemBuilder: (context, index) {
              final course = _courses[index];
              final isSelected =
                  _selectedCourse?.id == course.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCourse = course;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(
                            0xFF6366F1,
                          ).withValues(alpha: 0.1)
                        : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF6366F1)
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFF6366F1,
                              ).withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                        child: Image.network(
                          course.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.school,
                                  ),
                                );
                              },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? const Color(
                                        0xFF6366F1,
                                      )
                                    : Colors.black87,
                              ),
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF6366F1),
                          size: 28,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Eğitmen arama ekranı - Uber tarzı animasyonlu ekran
  Widget _buildSearchingView() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animasyonlu arama göstergesi
              Stack(
                alignment: Alignment.center,
                children: [
                  // Dış halka
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(
                          0xFF6366F1,
                        ).withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                  ),
                  // Orta halka
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(
                          0xFF6366F1,
                        ).withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                  ),
                  // İç daire
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(
                        0xFF6366F1,
                      ).withValues(alpha: 0.2),
                    ),
                    child: const Icon(
                      Icons.search,
                      size: 48,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              const Text(
                'Eğitmen Aranıyor...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Size en uygun eğitmen bulunuyor',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 48),
              // Seçilen kurs bilgisi
              if (_selectedCourse != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                        child: Image.network(
                          _selectedCourse!.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedCourse!.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Eşleştirme başarılı ekranı - Uber tarzı başarı göstergesi
  Widget _buildMatchedView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 24,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Başarı animasyonu
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Eğitmen Bulundu!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Eğitmeniniz başarıyla atandı',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Eğitmen bilgisi kartı
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.1,
                  ),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Eğitmen profil fotoğrafı
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF6366F1),
                  child: Text(
                    _getInitials(_matchedInstructorName ?? 'Eğitmen'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Eğitmen ismi
                Text(
                  _matchedInstructorName ?? 'Eğitmen',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Canlı Ders Eğitmeni',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      '4.9',
                      'Puan',
                      Icons.star,
                    ),
                    Container(
                      width: 1,
                      height: 35,
                      color: Colors.grey[300],
                    ),
                    _buildStatItem(
                      '250+',
                      'Ders',
                      Icons.school,
                    ),
                    Container(
                      width: 1,
                      height: 35,
                      color: Colors.grey[300],
                    ),
                    _buildStatItem(
                      '5 yıl',
                      'Tecrübe',
                      Icons.workspace_premium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Bilgilendirme
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[700],
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Eğitmeniniz size kısa süre içinde ulaşacak',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Kapat butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Tamam',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// İstatistik item widget'ı
  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF6366F1),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Eşleştirme başarısız ekranı
  Widget _buildFailedView() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.withValues(
                    alpha: 0.1,
                  ),
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Müsait Eğitmen Yok',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Şu anda tüm eğitmenler meşgul.\nLütfen daha sonra tekrar deneyin.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _matchingStatus = 'idle';
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Alt buton - Talep oluştur
  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                _selectedCourse == null || _isSearching
                ? null
                : _requestLiveLesson,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: _isSearching
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                    ),
                  )
                : const Text(
                    'Canlı Ders Talep Et',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// Hata widget'ı
  Widget _buildErrorWidget() {
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
            const Text(
              'Bir hata oluştu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Bilinmeyen hata',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadCourses,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  /// Snackbar göster
  void _showSnackBar(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red
            : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// İsimden baş harfleri al
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
