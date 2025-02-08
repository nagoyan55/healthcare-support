import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/theme_provider.dart';
import 'screens/ward_selection_screen.dart';
import 'screens/patient_selection_screen.dart';
import 'screens/patient_detail_screen.dart';
import 'screens/login_screen.dart';
import 'screens/my_page_screen.dart';

const firebaseOptions = FirebaseOptions(
  apiKey: 'demo-api-key',
  appId: 'demo-app-id',
  messagingSenderId: 'demo-sender-id',
  projectId: 'demo-healthcare-support',
  authDomain: 'demo-healthcare-support.firebaseapp.com',
  storageBucket: 'demo-healthcare-support.appspot.com',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);

  // 開発時はエミュレータに接続
  const useEmulator = true; // 本番環境では false に設定
  if (useEmulator) {
    await _connectToEmulator();
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

Future<void> _connectToEmulator() async {
  const localhost = 'localhost';

  FirebaseFirestore.instance.settings = const Settings(
    host: '$localhost:8080',
    sslEnabled: false,
    persistenceEnabled: false,
  );

  await FirebaseAuth.instance.useAuthEmulator(localhost, 9099);
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: 'ほすさぽくん',
      theme: theme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ユーザーがログインしていない場合はログイン画面を表示
          if (!snapshot.hasData) {
            return const LoginScreen();
          }

          // ログイン済みの場合は病棟選択画面を表示
          return const WardSelectionScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/ward_selection': (context) => const WardSelectionScreen(),
        '/patient_selection': (context) => const PatientSelectionScreen(),
        '/patient_detail': (context) => const PatientDetailScreen(
              key: ValueKey('patient_detail'),
            ),
        '/my_page': (context) => const MyPageScreen(),
      },
    );
  }
}
