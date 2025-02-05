import 'package:flutter/material.dart';
import 'chat_tab_screen.dart';
import 'profile_tab_screen.dart';
import 'todo_tab_screen.dart';

class PatientDetailScreen extends StatelessWidget {
  const PatientDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> patient =
        (ModalRoute.of(context)?.settings.arguments as Map<String, String>?) ??
            {
              'id': 'A',
              'name': '山田 太郎',
              'room': '101',
              'bed': 'A',
              'gender': 'M',
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
            const ChatTabScreen(),
            const TodoTabScreen(),
          ],
        ),
      ),
    );
  }
}
