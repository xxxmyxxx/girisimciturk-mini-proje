// Web için dart:html import
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/course_provider.dart';
import '../../providers/user_provider.dart';
import '../courses/course_list_screen.dart';
import '../courses/my_courses_screen.dart';
import '../live_lesson/live_lesson_request_screen.dart';
import '../live_lesson/my_live_lesson_requests_screen.dart';

/// Kullanıcı Dashboard'u
/// Normal kullanıcılar için ana ekran
class UserDashboard extends StatefulWidget {
  final int initialTab;
  
  const UserDashboard({super.key, this.initialTab = 0});

  @override
  State<UserDashboard> createState() =>
      _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
    // Kursları yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final courseProvider = Provider.of<CourseProvider>(
        context,
        listen: false,
      );
      courseProvider.loadAllCourses();
    });
  }

  /// Çıkış yap
  Future<void> _logout() async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    await userProvider.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  /// Tab değiştiğinde URL'yi güncelle
  void _updateUrlForTab(int index) {
    if (!kIsWeb) return;

    try {
      String newPath;
      switch (index) {
        case 0:
          newPath = '/dashboard';
          break;
        case 1:
          newPath = '/courses';
          break;
        case 2:
          newPath = '/my-courses';
          break;
        case 3:
          newPath = '/my-live-lessons';
          break;
        default:
          newPath = '/dashboard';
      }

      // replaceState kullanarak history'ye yeni entry eklememek
      html.window.history.replaceState(null, '', newPath);
    } catch (e) {
      // Hata durumunda sessiz devam et
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> pages = [
      _buildHomeTab(user),
      const CourseListScreen(),
      const MyCoursesScreen(),
      const MyLiveLessonRequestsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GirisimciTurk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          _updateUrlForTab(index);
        },
        selectedItemColor: const Color(0xFF6366F1),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Kurslar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Kurslarım',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_call),
            label: 'Taleplerim',
          ),
        ],
      ),
    );
  }

  /// Ana sayfa tab içeriği
  Widget _buildHomeTab(user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hoş geldin kartı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6366F1),
                  Color(0xFF8B5CF6),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.waving_hand,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Hoş geldin, ${user.fullName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Öğrenmeye devam et!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Özellikler
          const Text(
            'Özellikler',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  icon: Icons.school,
                  title: 'Kurslar',
                  description: 'Yüzlerce kurs',
                  color: Colors.blue,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                    _updateUrlForTab(1);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeatureCard(
                  icon: Icons.video_call,
                  title: 'Canlı Ders',
                  description: 'Birebir eğitim',
                  color: Colors.green,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const LiveLessonRequestScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Özellik kartı widget'ı
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
