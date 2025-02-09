import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/user_service.dart';
import '../models/chat_message.dart';
import '../utils/date_formatter.dart';

class AIChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? currentUserId;
  final UserService _userService;
  String? _currentUserName;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  AIChatProvider({
    required this.currentUserId,
    UserService? userService,
  }) : _userService = userService ?? UserService() {
    _loadCurrentUserName();
  }

  Future<void> _loadCurrentUserName() async {
    if (currentUserId != null) {
      final userData = await _userService.getUserData(currentUserId!);
      if (userData != null) {
        _currentUserName = userData['name'] as String?;
        notifyListeners();
      }
    }
  }

  Stream<Map<String, List<ChatMessage>>> getMessagesByDate() {
    return _firestore
        .collection('ai_chats')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      final messagesList = snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          final timestamp = data['timestamp'];
          final DateTime messageTime;
          if (timestamp is Timestamp) {
            messageTime = timestamp.toDate();
          } else if (timestamp is DateTime) {
            messageTime = timestamp;
          } else {
            messageTime = DateTime.now();
          }

          return ChatMessage(
            id: doc.id,
            sender: data['sender'] as String? ?? '',
            message: data['message'] as String? ?? '',
            timestamp: messageTime,
            isCurrentUser: data['sender'] == currentUserId,
            avatarText: data['sender'] == currentUserId ? (_currentUserName?.substring(0, 1) ?? '看') : 'AI',
            reactions: const [],
            isShared: false,
          );
        } catch (e) {
          print('Message parsing error: $e');
          return null;
        }
      }).whereType<ChatMessage>().toList();

      // メッセージを日付でグループ化
      final messagesByDate = <String, List<ChatMessage>>{};
      for (final message in messagesList) {
        final date = DateFormatter.formatMessageDate(message.timestamp);
        messagesByDate.putIfAbsent(date, () => []).add(message);
      }

      // 各日付のメッセージを時刻でソート
      messagesByDate.forEach((date, messages) {
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      });

      // 日付でソート
      final sortedDates = messagesByDate.keys.toList()
        ..sort((a, b) => b.compareTo(a));
      
      return Map.fromEntries(
        sortedDates.map((date) => MapEntry(date, messagesByDate[date]!)),
      );
    });
  }

  Future<void> sendMessage(String message) async {
    if (currentUserId == null) return;

    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore
          .collection('ai_chats')
          .add({
            'sender': currentUserId,
            'message': message,
            'timestamp': FieldValue.serverTimestamp(),
          });

    } catch (e) {
      _error = 'メッセージの送信に失敗しました';
      notifyListeners();
      
      // エラーメッセージを3秒間表示
      Future.delayed(const Duration(seconds: 3), () {
        if (_error != null) {
          _error = null;
          notifyListeners();
        }
      });
      
      return;
    }
    
    _isLoading = false;
    notifyListeners();
  }
}
