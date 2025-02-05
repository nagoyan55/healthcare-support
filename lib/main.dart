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
          seedColor: const Color(0xFF2E7D32), // より濃い緑に変更
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF66BB6A),
          tertiary: const Color(0xFFA5D6A7),
          background: const Color(0xFFF5F5F5),
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onTertiary: Colors.black87,
          onBackground: Colors.black,
          onSurface: Colors.black87,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.black87, fontSize: 14),
          titleLarge: TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
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
