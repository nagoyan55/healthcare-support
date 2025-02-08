import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tabs/profile_tab.dart';
import 'tabs/task_tab.dart';
import 'tabs/chat_tab.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIconIndex = 0;
  Color _selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('マイページ'),
          backgroundColor: _selectedColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, '/login');
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('サインアウトに失敗しました: $e')),
                  );
                }
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.person), text: 'プロフィール'),
              Tab(icon: Icon(Icons.task), text: 'タスク'),
              Tab(icon: Icon(Icons.chat), text: 'チャット'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // プロフィールタブ
            ProfileTab(
              selectedColor: _selectedColor,
              onColorChanged: (color) => setState(() => _selectedColor = color),
              selectedIconIndex: _selectedIconIndex,
              onIconChanged: (index) => setState(() => _selectedIconIndex = index),
            ),
            // タスクタブ
            const TaskTab(),
            // チャットタブ
            const ChatTab(),
          ],
        ),
      ),
    );
  }
}
