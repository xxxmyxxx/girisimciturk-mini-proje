import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/course_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/payment_service.dart';

/// Ödeme Başarılı Ekranı
///
/// Stripe checkout'tan döndükten sonra gösterilir ve başarı dialogu gösterir
class PaymentSuccessScreen extends StatefulWidget {
  final String? sessionId;

  const PaymentSuccessScreen({super.key, this.sessionId});

  @override
  State<PaymentSuccessScreen> createState() =>
      _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processPaymentSuccess();
    });
  }

  /// Ödeme işlemini tamamla ve başarı dialogu göster
  Future<void> _processPaymentSuccess() async {
    if (_dialogShown) {
      return;
    }
    _dialogShown = true;

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) {
      return;
    }

    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    int attempts = 0;
    while (!userProvider.isInitialized && attempts < 30) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    if (userProvider.currentUser == null) {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
      return;
    }

    final uri = Uri.base;
    final userId = uri.queryParameters['userId'];
    final courseId = uri.queryParameters['courseId'];

    if (userId != null && courseId != null) {
      try {
        final paymentService = PaymentService();
        await paymentService.assignCourseManually(
          userId: int.parse(userId),
          courseId: int.parse(courseId),
        );
      } catch (e) {
        // Hata durumunda sessiz devam et
      }
    }

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      final courseProvider = Provider.of<CourseProvider>(
        context,
        listen: false,
      );
      await courseProvider.loadMyCourses(
        userProvider.currentUser!.id,
      );
    }

    if (mounted) {
      _showSuccessDialog();
    }
  }

  /// Modern başarı dialogu göster
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade400,
                      Colors.green.shade600,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Ödeme Başarılı! 🎉',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Satın alma işleminiz başarıyla tamamlandı.\nKurs hesabınıza eklendi ve öğrenmeye başlayabilirsiniz.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Dashboard'a git ve Kurslarım sekmesini aç (tab=2)
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/dashboard?tab=2',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.school),
                  label: const Text(
                    'Kurslarıma Git',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/dashboard',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home_outlined),
                  label: const Text(
                    'Ana Sayfaya Dön',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade400,
                          Colors.green.shade600,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  '🎉 Ödeme İşleniyor...',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Lütfen bekleyin, işleminiz tamamlanıyor...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                const CircularProgressIndicator(
                  color: Color(0xFF6366F1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
