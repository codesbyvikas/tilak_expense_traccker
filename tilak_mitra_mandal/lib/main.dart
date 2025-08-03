import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tilak_mitra_mandal/Screens/homepage.dart';
import 'package:tilak_mitra_mandal/Screens/loginpage.dart';
import 'package:tilak_mitra_mandal/api/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.setupInterceptors();
  runApp(const GanpatiTrackerApp());
}

class GanpatiTrackerApp extends StatelessWidget {
  const GanpatiTrackerApp({super.key});

  // Check if user is logged in by checking token
  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ganpati Expense Tracker',
      theme: ThemeData(
        primaryColor: const Color(0xFFD32F2F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF5722),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        useMaterial3: true,
        fontFamily: 'Roboto',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: FutureBuilder<bool>(
        future: _isLoggedIn(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Navigate to HomePage if token exists, else LoginPage
          return snapshot.data == true ? const HomeScreen() : const LoginPage();
        },
      ),
    );
  }
}
