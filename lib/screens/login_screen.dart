import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String _selectedWard = '内科';
  String _selectedOccupation = '看護師';
  int _selectedIconIndex = 0;
  File? _imageFile;

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

  @override
  void initState() {
    super.initState();
    _loadSavedName();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_name');
    if (savedName != null) {
      setState(() {
        _nameController.text = savedName;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        _selectedIconIndex = -1; // カスタム画像を選択した場合
      });
    }
  }

  Future<void> _takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        _selectedIconIndex = -1; // カスタム画像を選択した場合
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // ユーザー名を保存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameController.text);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/ward_selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                const Text(
                  '病院支援システム',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 48),

                // アイコン選択
                const Text('アイコンを選択', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('ギャラリーから選択'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _takePicture,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('写真を撮影'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_imageFile != null)
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: FileImage(_imageFile!),
                  )
                else
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
                                _imageFile = null;
                              });
                            },
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: _selectedIconIndex == index
                                  ? Theme.of(context).primaryColor
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
                const SizedBox(height: 24),

                // 名前入力
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
                const SizedBox(height: 24),

                // 所属病棟選択
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
                const SizedBox(height: 24),

                // 職業選択
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

                // 登録ボタン
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _handleSubmit,
                  child: const Text(
                    '登録',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
