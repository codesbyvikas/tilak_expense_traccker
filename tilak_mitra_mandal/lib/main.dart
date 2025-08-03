import 'package:flutter/material.dart';
import 'package:tilak_mitra_mandal/Screens/homepage.dart';
import 'package:tilak_mitra_mandal/Screens/loginpage.dart';

void main() {
  runApp(GanpatiTrackerApp());
}

class GanpatiTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ganpati Expense Tracker',
      theme: ThemeData(
        primaryColor: Color(0xFFD32F2F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFFF5722),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Color(0xFFFAFAFA),
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
      home: HomeScreen(),
    );
  }
}
