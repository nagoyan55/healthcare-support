import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

class ProfileTab extends ConsumerStatefulWidget {
  final int selectedIconIndex;
  final ValueChanged<int> onIconChanged;

  const ProfileTab({
    super.key,
    required this.selectedIconIndex,
    required this.onIconChanged,
  });

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedWard = '内科';
  String _selectedOccupation = '看護師';

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
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
            _nameController.text = data['name'] ?? '';
            _selectedWard = data['ward'] ?? '内科';
            _selectedOccupation = data['occupation'] ?? '看護師';
          });
        }
      }
    } catch (e) {
      log('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeNotifierProvider);
    final primaryColor = theme.colorScheme.primary;

    return SingleChildScrollView(
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
                      backgroundColor: primaryColor,
                      child: Icon(
                        _avatarIcons[widget.selectedIconIndex],
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _nameController.text.isEmpty ? 'ユーザー名' : _nameController.text,
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
                    final isSelected = widget.selectedIconIndex == index;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () => widget.onIconChanged(index),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: isSelected
                              ? primaryColor
                              : Colors.grey[300],
                          child: Icon(
                            _avatarIcons[index],
                            size: 40,
                            color: isSelected
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
                    final color = _themeColors[index];
                    final isSelected = color.value == primaryColor.value;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () => ref
                            .read(themeNotifierProvider.notifier)
                            .setThemeColor(color),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: isSelected
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
                controller: _nameController,
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
                            'name': _nameController.text,
                            'ward': _selectedWard,
                            'occupation': _selectedOccupation,
                            'iconIndex': widget.selectedIconIndex,
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
    );
  }
}
