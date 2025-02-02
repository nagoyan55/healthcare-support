import 'package:flutter/material.dart';
import 'screens/ward_selection_screen.dart';
import 'screens/patient_selection_screen.dart';
import 'screens/patient_detail_screen.dart';
import 'screens/login_screen.dart';
import 'screens/my_page_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ほすさぽくん',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50), // メインカラーを緑系に変更
          primary: const Color(0xFF4CAF50),
          secondary: const Color(0xFF81C784),
          tertiary: const Color(0xFFC8E6C9),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/ward_selection': (context) => const WardSelectionScreen(),
        '/patient_selection': (context) => const PatientSelectionScreen(),
        '/patient_detail': (context) => const PatientDetailScreen(),
        '/my_page': (context) => const MyPageScreen(),
      },
    );
  }
}
