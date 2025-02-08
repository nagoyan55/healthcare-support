import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/todo_service.dart';
import '../services/chat_service.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _StaffTaskTab extends StatefulWidget {
  @override
  State<_StaffTaskTab> createState() => _StaffTaskTabState();
}

class _StaffTaskTabState extends State<_StaffTaskTab> {
  final TodoService _todoService = TodoService();
  List<Map<String, dynamic>> _todos = [];
  final String _currentUserId = 'demo-user'; // TODO: 認証から取得

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    try {
      final todos = await _todoService.getTodosByAssignee(_currentUserId);
      setState(() {
        _todos = todos;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('タスクの取得に失敗しました')),
        );
      }
    }
  }

  String _formatDeadline(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // タスクリスト
          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.task_alt),
                    title: Text(todo['title'] as String),
                    subtitle: Text(
                        '期限: ${_formatDeadline(todo['deadline'] as Timestamp)}'),
                    trailing: Checkbox(
                      value: todo['isCompleted'] as bool,
                      onChanged: (value) async {
                        try {
                          await _todoService.updateTodoStatus(
                            patientId: todo['patientId'] as String,
                            todoId: todo['id'] as String,
                            isCompleted: value!,
                          );
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('タスクの状態更新に失敗しました')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffChatTab extends StatefulWidget {
  @override
  State<_StaffChatTab> createState() => _StaffChatTabState();
}

class _StaffChatTabState extends State<_StaffChatTab> {
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> _chats = [];
  final String _currentUserId = 'demo-user'; // TODO: 認証から取得

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      final chats = await _chatService.getChatParticipants(_currentUserId);
      setState(() {
        _chats = chats;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('チャット一覧の取得に失敗しました')),
        );
      }
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'たった今';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}時間前';
    } else {
      return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // チャットリスト
          Expanded(
            child: ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                final chat = _chats[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(Icons.person),
                    ),
                    title: Text(chat['title'] as String),
                    subtitle: Text(chat['lastMessage'] as String),
                    trailing: Text(
                        _formatTimestamp(chat['lastMessageTime'] as Timestamp)),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/patient_detail',
                        arguments: {'id': chat['patientId'] as String},
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MyPageScreenState extends State<MyPageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _selectedWard = '内科';
  String _selectedOccupation = '看護師';
  int _selectedIconIndex = 0;
  Color _selectedColor = Colors.blue;

  final List<String> _wards = ['内科', '外科', '小児科', '産婦人科', '精神科'];
  final List<String> _occupations = ['看護師', '医師', '薬剤師', '理学療法士', '作業療法士'];
  final List<IconData> _avatarIcons = [
    Icons.face,
    Icons.face_2,
    Icons.face_3,
    Icons.face_4,
    Icons.face_5,
    Icons.face_6,
  ];
  final List<Color> _themeColors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.red,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            _name = data['name'] ?? '';
            _selectedWard = data['ward'] ?? '内科';
            _selectedOccupation = data['occupation'] ?? '看護師';
            _selectedIconIndex = data['iconIndex'] ?? 0;
          });
        }
      }
    } catch (e) {
      log('Error loading user data: $e');
    }
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
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // プロフィール画像とユーザー名
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: _selectedColor,
                              child: Icon(
                                _avatarIcons[_selectedIconIndex],
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _name.isEmpty ? 'ユーザー名' : _name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // アイコン変更セクション
                      const Text(
                        'アイコンを変更',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _avatarIcons.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedIconIndex = index;
                                  });
                                },
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: _selectedIconIndex == index
                                      ? _selectedColor
                                      : Colors.grey[300],
                                  child: Icon(
                                    _avatarIcons[index],
                                    size: 40,
                                    color: _selectedIconIndex == index
                                        ? Colors.white
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      // テーマカラー選択セクション
                      const Text(
                        'テーマカラーを選択',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _themeColors.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedColor = _themeColors[index];
                                  });
                                },
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: _themeColors[index],
                                  child: _selectedColor == _themeColors[index]
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      // プロフィール情報編集
                      const Text(
                        'プロフィール情報',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _name,
                        decoration: const InputDecoration(
                          labelText: '名前',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '名前を入力してください';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _name = value!;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: '所属病棟',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.local_hospital),
                        ),
                        value: _selectedWard,
                        items: _wards.map((ward) {
                          return DropdownMenuItem(
                            value: ward,
                            child: Text(ward),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedWard = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: '職業',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.work),
                        ),
                        value: _selectedOccupation,
                        items: _occupations.map((occupation) {
                          return DropdownMenuItem(
                            value: occupation,
                            child: Text(occupation),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedOccupation = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 32),

                      // 保存ボタン
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              try {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.uid)
                                      .update({
                                    'name': _name,
                                    'ward': _selectedWard,
                                    'occupation': _selectedOccupation,
                                    'iconIndex': _selectedIconIndex,
                                    'updatedAt': FieldValue.serverTimestamp(),
                                  });

                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('プロフィールを更新しました'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('プロフィールの更新に失敗しました: $e'),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            '保存',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // タスクタブ
            _StaffTaskTab(),
            // チャットタブ
            _StaffChatTab(),
          ],
        ),
      ),
    );
  }
}
