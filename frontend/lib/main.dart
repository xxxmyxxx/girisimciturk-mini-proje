import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'models/user.dart';
import 'providers/course_provider.dart';
import 'providers/user_provider.dart';
import 'screens/courses/course_detail_screen.dart';
import 'screens/courses/course_list_screen.dart';
import 'screens/courses/my_courses_screen.dart';
import 'screens/dashboard/admin_dashboard.dart';
import 'screens/dashboard/instructor_dashboard.dart';
import 'screens/dashboard/user_dashboard.dart';
import 'screens/landing_page.dart';
import 'screens/login_screen.dart';
import 'screens/payment/payment_cancel_screen.dart';
import 'screens/payment/payment_success_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = UserProvider();
            provider.loadSession();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => CourseProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'GirisimciTurk Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.light,
          ),
          fontFamily: 'Roboto',
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        onGenerateRoute: (settings) {
          final routeName = settings.name?.split('?').first ?? '/';
          
          // Eğer settings.name null ise, yeni bir RouteSettings oluştur
          final routeSettings = settings.name != null 
              ? settings 
              : RouteSettings(name: routeName, arguments: settings.arguments);
          
          if (routeName == '/payment-success') {
            return MaterialPageRoute(
              builder: (context) => const PaymentSuccessScreen(),
              settings: routeSettings,
            );
          }
          
          if (routeName == '/payment-cancel') {
            return MaterialPageRoute(
              builder: (context) => const PaymentCancelScreen(),
              settings: routeSettings,
            );
          }

          if (routeName.startsWith('/course/')) {
            final courseId = routeName.split('/').last;
            return MaterialPageRoute(
              builder: (context) => CourseDetailScreen(
                courseId: int.tryParse(courseId) ?? 0,
              ),
              settings: routeSettings,
            );
          }

          switch (routeName) {
            case '/landing':
              return MaterialPageRoute(
                builder: (context) => const LandingPage(),
                settings: routeSettings,
              );
            case '/login':
              return MaterialPageRoute(
                builder: (context) => const LoginScreen(),
                settings: routeSettings,
              );
            case '/courses':
              return MaterialPageRoute(
                builder: (context) => const CourseListScreen(showScaffold: true),
                settings: routeSettings,
              );
            case '/my-courses':
              return MaterialPageRoute(
                builder: (context) => const MyCoursesScreen(showScaffold: true),
                settings: routeSettings,
              );
            case '/dashboard':
              final uri = Uri.parse(settings.name ?? '/dashboard');
              final tabParam = uri.queryParameters['tab'];
              final initialTab = int.tryParse(tabParam ?? '0') ?? 0;
              
              return MaterialPageRoute(
                builder: (context) => UserDashboard(initialTab: initialTab),
                settings: routeSettings,
              );
            case '/admin-dashboard':
              return MaterialPageRoute(
                builder: (context) => const AdminDashboard(),
                settings: routeSettings,
              );
            case '/instructor-dashboard':
              return MaterialPageRoute(
                builder: (context) => const InstructorDashboard(),
                settings: routeSettings,
              );
            case '/':
            default:
              return MaterialPageRoute(
                builder: (context) => const AuthWrapper(),
                settings: routeSettings,
              );
          }
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (!userProvider.isInitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (userProvider.isLoggedIn) {
          switch (userProvider.currentUser!.role) {
            case Role.instructor:
              return const InstructorDashboard();
            case Role.admin:
              return const AdminDashboard();
            case Role.user:
              return const UserDashboard();
          }
        }

        return const LandingPage();
      },
    );
  }
}
