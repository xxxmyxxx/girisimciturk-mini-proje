import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../services/user_service.dart';

/// Login ekranı - Kullanıcı girişi
/// Animasyonlu ve responsive tasarım
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userService = UserService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  List<Map<String, dynamic>> _instructors = [];
  bool _showInstructors = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeIn,
          ),
        );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOut,
          ),
        );

    _animationController.forward();
    _loadInstructors();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Eğitmenleri yükle
  Future<void> _loadInstructors() async {
    try {
      final instructors = await _userService
          .getInstructors();
      if (mounted) {
        setState(() {
          _instructors = instructors;
        });
      }
    } catch (e) {
      // Hata durumunda sessiz devam et
    }
  }

  /// Login işlemini gerçekleştir
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      );
      final user = await ApiService.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (user != null) {
        await userProvider.login(
          user,
          'dummy-token-${user.id}',
        );

        // Role'e göre dashboard'a yönlendir
        String route;
        switch (user.role) {
          case Role.instructor:
            route = '/instructor-dashboard';
            break;
          case Role.admin:
            route = '/admin-dashboard';
            break;
          case Role.user:
            route = '/dashboard';
            break;
        }

        Navigator.of(context).pushReplacementNamed(route);
      } else {
        _showErrorDialog('Kullanıcı adı veya şifre hatalı');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Bağlantı hatası: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Hata dialog'unu göster
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata'),
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

  /// Demo kullanıcı satırı oluştur
  Widget _buildDemoUserRow(
    String username,
    String label,
    IconData icon, {
    bool isSmall = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: isSmall ? 12 : 14,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 6),
          Text(
            username,
            style: TextStyle(
              fontSize: isSmall ? 11 : 12,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '($label)',
            style: TextStyle(
              fontSize: isSmall ? 10 : 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo
                            Container(
                              padding: const EdgeInsets.all(
                                16,
                              ),
                              decoration: BoxDecoration(
                                gradient:
                                    const LinearGradient(
                                      colors: [
                                        Color(0xFF6366F1),
                                        Color(0xFF8B5CF6),
                                      ],
                                    ),
                                borderRadius:
                                    BorderRadius.circular(
                                      16,
                                    ),
                              ),
                              child: const Icon(
                                Icons.rocket_launch,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Hoş Geldiniz',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hesabınıza giriş yapın',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Kullanıcı adı
                            TextFormField(
                              controller:
                                  _usernameController,
                              decoration: InputDecoration(
                                labelText: 'Kullanıcı Adı',
                                prefixIcon: const Icon(
                                  Icons.person_outline,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                        12,
                                      ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'Lütfen kullanıcı adınızı girin';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Şifre
                            TextFormField(
                              controller:
                                  _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Şifre',
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons
                                              .visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword =
                                          !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                        12,
                                      ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'Lütfen şifrenizi girin';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Eğitmenler butonu
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(
                                  () => _showInstructors =
                                      !_showInstructors,
                                );
                              },
                              icon: Icon(
                                _showInstructors
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                              ),
                              label: Text(
                                _showInstructors
                                    ? 'Eğitmenleri Gizle'
                                    : 'Eğitmenleri Gör (${_instructors.length})',
                              ),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                              ),
                            ),

                            if (_showInstructors &&
                                _instructors
                                    .isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                constraints:
                                    const BoxConstraints(
                                      maxHeight: 300,
                                    ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors
                                        .grey
                                        .shade300,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                        12,
                                      ),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount:
                                      _instructors.length,
                                  itemBuilder: (context, index) {
                                    final instructor =
                                        _instructors[index];
                                    final profile =
                                        instructor['instructorProfile'];
                                    return InkWell(
                                      onTap: () {
                                        _usernameController
                                                .text =
                                            instructor['username'];
                                        _passwordController
                                                .text =
                                            '123';
                                        setState(
                                          () =>
                                              _showInstructors =
                                                  false,
                                        );
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.all(
                                              12,
                                            ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 24,
                                              backgroundImage:
                                                  NetworkImage(
                                                    instructor['photoUrl'] ??
                                                        'https://ui-avatars.com/api/?name=${instructor['fullName']}',
                                                  ),
                                            ),
                                            const SizedBox(
                                              width: 12,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  Text(
                                                    instructor['fullName'],
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    profile?['title'] ??
                                                        'Eğitmen',
                                                    style: TextStyle(
                                                      fontSize:
                                                          12,
                                                      color:
                                                          Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize:
                                                  MainAxisSize
                                                      .min,
                                              children: [
                                                const Icon(
                                                  Icons
                                                      .star,
                                                  size: 16,
                                                  color: Colors
                                                      .amber,
                                                ),
                                                const SizedBox(
                                                  width: 4,
                                                ),
                                                Text(
                                                  '${profile?['rating']?.toStringAsFixed(1) ?? '5.0'}',
                                                  style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),

                            // Demo kullanıcılar bilgisi
                            Container(
                              padding: const EdgeInsets.all(
                                12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius:
                                    BorderRadius.circular(
                                      8,
                                    ),
                                border: Border.all(
                                  color:
                                      Colors.blue.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 16,
                                        color: Colors
                                            .blue
                                            .shade700,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      const Text(
                                        'Demo Kullanıcılar (Şifre: 123)',
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDemoUserRow(
                                    'user',
                                    'Öğrenci',
                                    Icons.person,
                                  ),
                                  _buildDemoUserRow(
                                    'admin',
                                    'Admin',
                                    Icons
                                        .admin_panel_settings,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Giriş butonu
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(
                                        0xFF6366F1,
                                      ),
                                  foregroundColor:
                                      Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                          12,
                                        ),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child:
                                            CircularProgressIndicator(
                                              color: Colors
                                                  .white,
                                              strokeWidth:
                                                  2,
                                            ),
                                      )
                                    : const Text(
                                        'Giriş Yap',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
