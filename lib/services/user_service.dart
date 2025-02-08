import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ユーザー情報を取得
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // ユーザー情報を更新
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      print('Error updating user data: $e');
      throw 'ユーザー情報の更新に失敗しました';
    }
  }

  // ユーザーのテーマカラーを更新
  Future<void> updateThemeColor(String userId, String colorHex) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'themeColor': colorHex,
      });
    } catch (e) {
      print('Error updating theme color: $e');
      throw 'テーマカラーの更新に失敗しました';
    }
  }

  // ユーザーのアバター情報を更新
  Future<void> updateAvatar(
    String userId, {
    required int iconIndex,
    String? avatarUrl,
  }) async {
    try {
      final data = {
        'iconIndex': iconIndex,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      };
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      print('Error updating avatar: $e');
      throw 'アバターの更新に失敗しました';
    }
  }

  // 特定の病棟のスタッフ一覧を取得
  Future<List<Map<String, dynamic>>> getStaffByWard(String ward) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('ward', isEqualTo: ward)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error getting staff by ward: $e');
      return [];
    }
  }

  // ユーザーのタスク一覧を取得
  Future<List<Map<String, dynamic>>> getUserTasks(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('todos')
          .where('assignedTo', isEqualTo: userId)
          .orderBy('deadline')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error getting user tasks: $e');
      return [];
    }
  }

  // ユーザーのチャット一覧を取得
  Future<List<Map<String, dynamic>>> getUserChats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error getting user chats: $e');
      return [];
    }
  }
}
