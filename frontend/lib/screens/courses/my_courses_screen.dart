import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/course_provider.dart';
import '../../providers/user_provider.dart';

/// Kullanıcının satın aldığı kurslar ekranı
/// Not: Bu ekran UserDashboard içinde tab olarak kullanıldığında Scaffold YOK
/// Standalone olarak kullanıldığında (route ile) Scaffold VAR
class MyCoursesScreen extends StatefulWidget {
  final bool showScaffold;

  const MyCoursesScreen({
    super.key,
    this.showScaffold = false,
  });

  @override
  State<MyCoursesScreen> createState() =>
      _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false; // State'i cache'leme, her seferinde yenile

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMyCourses();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _loadMyCourses() async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacementNamed('/login');
      }
      return;
    }

    final courseProvider = Provider.of<CourseProvider>(
      context,
      listen: false,
    );
    await courseProvider.loadMyCourses(currentUser.id);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin için gerekli
    
    final content = _buildContent();

    // Eğer standalone kullanılıyorsa (route ile), Scaffold ekle
    if (widget.showScaffold) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Kurslarım',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F2937),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadMyCourses,
              tooltip: 'Yenile',
            ),
          ],
        ),
        body: content,
      );
    }

    // Dashboard içinde tab olarak kullanılıyorsa, sadece content döndür
    return content;
  }

  Widget _buildContent() {
    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        if (courseProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6366F1),
            ),
          );
        }

        final myCourses = courseProvider.myCourses;

        if (myCourses.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Henüz Kurs Satın Almadınız',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Kurslar sayfasından istediğiniz kursu\nsatın alabilirsiniz',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadMyCourses,
          color: const Color(0xFF6366F1),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myCourses.length,
            itemBuilder: (context, index) {
              final course = myCourses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pushNamed('/course/${course.id}');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Kurs görseli
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(8),
                          child: Image.network(
                            course.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (
                                  context,
                                  error,
                                  stackTrace,
                                ) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.school,
                                      size: 40,
                                      color:
                                          Colors.grey[400],
                                    ),
                                  );
                                },
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Kurs bilgileri
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      course.instructorName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors
                                            .grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow
                                          .ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${course.duration} saat',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Satın alındı badge
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.green[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Satın Alındı',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight:
                                      FontWeight.w600,
                                  fontSize: 12,
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
            },
          ),
        );
      },
    );
  }
}
