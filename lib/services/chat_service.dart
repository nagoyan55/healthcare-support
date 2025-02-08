import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // チャットメッセージを取得
  Stream<List<Map<String, dynamic>>> getMessages(String patientId) {
    return _firestore
        .collection('chats')
        .doc(patientId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return <String, dynamic>{
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  // メッセージを送信
  Future<void> sendMessage({
    required String patientId,
    required String senderId,
    required String message,
    String? quotedEhr,
    bool isShared = false,
  }) async {
    try {
      final messageData = {
        'sender': senderId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'quotedEhr': quotedEhr,
        'isShared': isShared,
        'reactions': [],
      };

      await _firestore
          .collection('chats')
          .doc(patientId)
          .collection('messages')
          .add(messageData);

      // 最後のメッセージ時間を更新
      await _firestore.collection('chats').doc(patientId).set({
        'lastMessageTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error sending message: $e');
      throw 'メッセージの送信に失敗しました';
    }
  }

  // リアクションを追加
  Future<void> addReaction({
    required String patientId,
    required String messageId,
    required String emoji,
    required String userId,
  }) async {
    try {
      await _firestore
          .collection('chats')
          .doc(patientId)
          .collection('messages')
          .doc(messageId)
          .update({
        'reactions': FieldValue.arrayUnion([
          {
            'emoji': emoji,
            'user': userId,
          }
        ]),
      });
    } catch (e) {
      print('Error adding reaction: $e');
      throw 'リアクションの追加に失敗しました';
    }
  }

  // メッセージを共有状態に設定
  Future<void> shareMessage({
    required String patientId,
    required String messageId,
  }) async {
    try {
      await _firestore
          .collection('chats')
          .doc(patientId)
          .collection('messages')
          .doc(messageId)
          .update({
        'isShared': true,
      });
    } catch (e) {
      print('Error sharing message: $e');
      throw 'メッセージの共有に失敗しました';
    }
  }

  // 電子カルテの引用を取得
  Future<List<Map<String, dynamic>>> getEhrQuotes(String patientId) async {
    try {
      // 注: 実際の実装では、電子カルテシステムのAPIを使用する必要があります
      final snapshot = await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('ehrQuotes')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return <String, dynamic>{
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error getting EHR quotes: $e');
      return [];
    }
  }

  // チャット参加者一覧を取得
  Future<List<Map<String, dynamic>>> getChatParticipants(
      String patientId) async {
    try {
      final doc = await _firestore.collection('chats').doc(patientId).get();
      final List<dynamic> participants = doc.data()?['participants'] ?? [];

      // 参加者の詳細情報を取得
      final userDocs = await Future.wait(
        participants
            .map((userId) => _firestore.collection('users').doc(userId).get()),
      );

      return userDocs.map((userDoc) {
        final data = userDoc.data() ?? {};
        return <String, dynamic>{
          'id': userDoc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error getting chat participants: $e');
      return [];
    }
  }
}
