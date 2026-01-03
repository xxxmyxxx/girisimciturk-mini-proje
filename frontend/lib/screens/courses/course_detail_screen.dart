import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/course.dart';
import '../../providers/course_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/matching_service.dart';
import '../../widgets/payment_dialog.dart';

/// Kurs detay ekranı
/// Kurs bilgilerini gösterir ve satın alma/canlı ders işlemlerini yapar
class CourseDetailScreen extends StatefulWidget {
  final Course? course;
  final int? courseId;

  const CourseDetailScreen({
    super.key,
    this.course,
    this.courseId,
  }) : assert(
         course != null || courseId != null,
         'Either course or courseId must be provided',
       );

  @override
  State<CourseDetailScreen> createState() =>
      _CourseDetailScreenState();
}

class _CourseDetailScreenState
    extends State<CourseDetailScreen> {
  final MatchingService _matchingService =
      MatchingService();
  bool _isProcessing = false;
  Course? _course;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  /// Kursu yükle - ya direkt course objesi var ya da courseId ile yükle
  Future<void> _loadCourse() async {
    if (widget.course != null) {
      setState(() => _course = widget.course);
      return;
    }

    if (widget.courseId != null) {
      setState(() => _isLoading = true);
      try {
        final courseProvider = Provider.of<CourseProvider>(
          context,
          listen: false,
        );
        
        // Eğer kurslar yüklenmemişse yükle
        if (courseProvider.allCourses.isEmpty) {
          await courseProvider.loadAllCourses();
        }
        
        final foundCourse = courseProvider.allCourses
            .firstWhere((c) => c.id == widget.courseId);
        setState(() => _course = foundCourse);
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Kurs bulunamadı');
          Navigator.pop(context);
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  /// Ödeme dialog'unu göster
  void _showPaymentDialog() {
    if (_course == null) return;

    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      _showErrorDialog('Lütfen önce giriş yapın');
      return;
    }

    // Kullanıcının kurslarını kontrol et
    final courseProvider = Provider.of<CourseProvider>(
      context,
      listen: false,
    );
    
    // Kullanıcı bu kursu zaten satın almış mı?
    final alreadyPurchased = courseProvider.myCourses
        .any((c) => c.id == _course!.id);
    
    if (alreadyPurchased) {
      _showErrorDialog('Bu kursu zaten satın aldınız!');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible:
          false, // Dışarı tıklayarak kapanmasın
      builder: (context) => PaymentDialog(
        userId: currentUser.id,
        courseId: _course!.id,
        courseName: _course!.title,
        coursePrice: _course!.price,
        customerEmail: currentUser.email,
        customerName: currentUser.fullName,
        onSuccess: _handlePaymentSuccess,
      ),
    );
  }

  /// Ödeme başarılı callback
  void _handlePaymentSuccess() {
    if (_course == null) return;

    final courseProvider = Provider.of<CourseProvider>(
      context,
      listen: false,
    );
    courseProvider.addToMyCourses(_course!);

    _showSuccessDialog(
      'Ödeme başarılı! Kurs hesabınıza eklendi.',
    );
  }

  /// Canlı ders talebi oluştur
  Future<void> _handleRequestLiveLesson() async {
    if (_course == null) return;

    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final currentUser = userProvider.currentUser;
    
    if (currentUser == null) {
      _showErrorDialog('Lütfen önce giriş yapın');
      return;
    }

    // Kullanıcı bu kurs için zaten canlı ders talep etmiş mi kontrol et
    // (Bu bilgiyi backend'den almak daha iyi olur ama şimdilik basit tutalım)
    // TODO: Backend'den aktif talepleri çek ve kontrol et
    
    final userId = currentUser.id;

    setState(() => _isProcessing = true);

    try {
      final result = await _matchingService
          .requestLiveLesson(userId, _course!.id);

      if (!mounted) return;

      if (result['success']) {
        _showLiveLessonSuccessDialog(
          instructorName: result['instructorName'] ?? 'Eğitmeniniz',
        );
      } else {
        // Backend'den gelen hata mesajı (örn: "Zaten aktif bir talebiniz var")
        _showErrorDialog(result['message']);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Bir hata oluştu: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// Canlı ders talebi başarı dialog'u - Modern ve şık tasarım
  void _showLiveLessonSuccessDialog({required String instructorName}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 8,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başarı ikonu - animasyonlu
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              
              // Başlık
              const Text(
                'Talebiniz Oluşturuldu! 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Eğitmen bilgisi
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_outline,
                      color: Color(0xFF6366F1),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      instructorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Açıklama mesajı
              Text(
                'Canlı ders talebiniz başarıyla oluşturulmuştur. Eğitmeniniz '
                'en kısa sürede sizinle iletişime geçerek uygun zaman için '
                'görüşme ayarlayacaktır.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Bilgilendirme kutusu
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'E-posta ve bildirimlerinizi kontrol edin',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              
              // Tamam butonu - Gradient ve gölgeli
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Tamam',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Başarı dialog'u
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // Dışarı tıklayarak kapanmasın
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Başarılı'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  /// Hata dialog'u
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Hata'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  /// Kullanıcı bu kursu satın almış mı kontrol et
  bool _isCoursePurchased() {
    final courseProvider = Provider.of<CourseProvider>(context, listen: true);
    return courseProvider.myCourses.any((c) => c.id == _course?.id);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Kurs Detayı'),
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_course == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Kurs Detayı'),
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Kurs bulunamadı')),
      );
    }

    final isPurchased = _isCoursePurchased();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kurs Detayı'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kurs görseli
            Image.network(
              _course!.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 80),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Text(
                    _course!.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Eğitmen
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _course!.instructorName,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Süre
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text('${_course!.duration} saat'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Açıklama
                  const Text(
                    'Açıklama',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _course!.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Fiyat
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF6366F1,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Fiyat:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₺${_course!.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Satın Al / Zaten Satın Alındı butonu
                  if (isPurchased)
                    // Kurs zaten satın alınmış - Bilgi kartı
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kurs Satın Alındı',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Bu kursu zaten satın aldınız',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    // Kurs henüz satın alınmamış - Satın Al butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showPaymentDialog,
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text(
                          'Satın Al',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF6366F1,
                          ),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Canlı ders talebi butonu
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isProcessing
                          ? null
                          : _handleRequestLiveLesson,
                      icon: const Icon(Icons.video_call),
                      label: const Text(
                        'Canlı Ders Talebi Oluştur',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(
                          0xFF6366F1,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        side: const BorderSide(
                          color: Color(0xFF6366F1),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
