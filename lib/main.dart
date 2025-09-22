import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Utils
import 'utils/app_colors.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/dashboard_screen.dart';

// Services
import 'services/db_helper.dart';

// Database packages
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Handle database setup based on platform
  if (kIsWeb) {
    // Web → skip database (sqflite not supported)
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    // Desktop → use sqflite_common_ffi
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // ✅ Initialize local SQLite database
  final dbHelper = DBHelper();

  await dbHelper.database;
  await dbHelper.seedUsers();

  runApp(const BlwAttendEase());
}

class BlwAttendEase extends StatelessWidget {
  const BlwAttendEase({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLW AttendEase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
        useMaterial3: true,
      ),

      // ✅ App starts at LoginScreen
      initialRoute: '/login',

      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          case '/home':
            return MaterialPageRoute(builder: (_) => const HomeScreen());

          case '/attendance':
            final userId = settings.arguments as int? ?? 1; // fallback
            return MaterialPageRoute(
              builder: (_) => AttendanceScreen(userId: userId),
            );

          case '/dashboard':
            return MaterialPageRoute(builder: (_) => const DashboardScreen());

          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}
