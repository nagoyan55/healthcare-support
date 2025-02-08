import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/patient_provider.dart';
import 'chat_tab_screen.dart';
import 'profile_tab_screen.dart';
import 'todo_tab_screen.dart';

class PatientDetailScreen extends ConsumerStatefulWidget {
  const PatientDetailScreen({super.key});

  @override
  ConsumerState<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends ConsumerState<PatientDetailScreen> {
  @override
  void initState() {
    super.initState();
    // 画面表示時に引数から患者情報を取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        ref.read(currentPatientProvider.notifier).setPatient(args);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final patient = ref.watch(currentPatientProvider) ?? {
      'id': 'A',
      'name': '読み込み中...',
      'room': '---',
      'bed': '-',
      'gender': '-',
    };

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(patient['name']!),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.pushNamed(context, '/my_page');
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.person),
                text: 'プロフィール',
              ),
              Tab(
                icon: Icon(Icons.chat),
                text: 'チャット',
              ),
              Tab(
                icon: Icon(Icons.checklist),
                text: 'TODO',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ProfileTabScreen(patient: patient),
            ChatTabScreen(patientId: patient['id']),
            TodoTabScreen(patientId: patient['id']),
          ],
        ),
      ),
    );
  }
}
