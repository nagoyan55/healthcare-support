import 'package:flutter/material.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _StaffTaskTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // タスク追加フォーム
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: '新しいタスク',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.add_task),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('タスクを追加'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // タスクリスト
          Expanded(
            child: ListView(
              children: const [
                Card(
                  child: ListTile(
                    leading: Icon(Icons.task_alt),
                    title: Text('患者Aさんのバイタルチェック'),
                    subtitle: Text('期限: 2025/1/27 15:00'),
                    trailing: Icon(Icons.check_box_outline_blank),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.task_alt),
                    title: Text('カンファレンス資料作成'),
                    subtitle: Text('期限: 2025/1/28 10:00'),
                    trailing: Icon(Icons.check_box_outline_blank),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.task_alt),
                    title: Text('新人看護師の指導'),
                    subtitle: Text('期限: 2025/1/28 13:00'),
                    trailing: Icon(Icons.check_box_outline_blank),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffChatTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // チャットリスト
          Expanded(
            child: ListView(
              children: const [
                Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text('田中医師'),
                    subtitle: Text('患者Bさんの状態について相談があります'),
                    trailing: Text('5分前'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text('鈴木看護師'),
                    subtitle: Text('申し送り事項があります'),
                    trailing: Text('30分前'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text('佐藤薬剤師'),
                    subtitle: Text('新しい処方箋について確認したいことがあります'),
                    trailing: Text('1時間前'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyPageScreenState extends State<MyPageScreen> with SingleTickerProviderStateMixin {
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
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              // TODO: Save user data
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('プロフィールを更新しました'),
                                ),
                              );
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
