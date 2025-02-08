import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('病院支援システム'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'サインイン'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SignInTab(),
          ],
        ),
      ),
    );
  }
}

class SignInTab extends StatefulWidget {
  const SignInTab({super.key});

  @override
  State<SignInTab> createState() => _SignInTabState();
}

class _SignInTabState extends State<SignInTab> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/ward_selection');
      } on FirebaseAuthException catch (e) {
        String message;
        switch (e.code) {
          case 'user-not-found':
            message = 'ユーザーが見つかりません';
            break;
          case 'wrong-password':
            message = 'パスワードが間違っています';
            break;
          case 'invalid-email':
            message = 'メールアドレスの形式が正しくありません';
            break;
          case 'too-many-requests':
            message = 'ログイン試行回数が多すぎます。しばらく待ってから再試行してください';
            break;
          default:
            message = 'サインインに失敗しました: ${e.message}';
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 48),
              // メールアドレス入力
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'メールアドレス',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'メールアドレスを入力してください';
                  }
                  if (!value.contains('@')) {
                    return '有効なメールアドレスを入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // パスワード入力
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'パスワード',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'パスワードを入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              // サインインボタン
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _handleSignIn,
                child: const Text(
                  'サインイン',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
