import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../utils/date_formatter.dart';

class ChatProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;
  final ChatService _chatService;
  final UserService _userService;
  String? _currentUserName;
  final String patientId;
  final String? currentUserId;

  ChatProvider({
    required this.patientId,
    required this.currentUserId,
    ChatService? chatService,
    UserService? userService,
  }) : _chatService = chatService ?? ChatService(),
       _userService = userService ?? UserService() {
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
    return _chatService.getMessages(patientId).map((messages) {
      final messagesList = messages.map((data) {
        try {
          final reactions = (data['reactions'] as List<dynamic>? ?? [])
              .map((r) => Reaction(
                    emoji: r['emoji'] as String,
                    user: r['user'] as String,
                  ))
              .toList();

          final timestamp = data['timestamp'];
          final DateTime messageTime;
          if (timestamp is Timestamp) {
            messageTime = timestamp.toDate();
          } else if (timestamp is DateTime) {
            messageTime = timestamp;
          } else {
            messageTime = DateTime.now(); // フォールバック
          }

          return ChatMessage(
            id: data['id'] as String? ?? '',
            sender: data['sender'] as String? ?? '',
            message: data['message'] as String? ?? '',
            timestamp: messageTime,
            isCurrentUser: data['sender'] == currentUserId,
            avatarText: data['sender'] == currentUserId ? (_currentUserName?.substring(0, 1) ?? '看') : '医',
            reactions: reactions,
            quotedEhr: data['quotedEhr'] as String?,
            isShared: data['isShared'] as bool? ?? false,
          );
        } catch (e) {
          print('Message parsing error: $e');
          // エラーが発生した場合はスキップ
          return null;
        }
      }).whereType<ChatMessage>().toList();

      // メッセージを日付でグループ化
      final messagesByDate = <String, List<ChatMessage>>{};
      for (final message in messagesList) {
        final date = DateFormatter.formatMessageDate(message.timestamp);
        messagesByDate.putIfAbsent(date, () => []).add(message);
      }

      // 各日付のメッセージを時刻でソート(新しい順)
      messagesByDate.forEach((date, messages) {
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      });

      // 日付でソート(新しい順)
      final sortedDates = messagesByDate.keys.toList()
        ..sort((a, b) => b.compareTo(a));
      
      return Map.fromEntries(
        sortedDates.map((date) => MapEntry(date, messagesByDate[date]!)),
      );
    });
  }

  Future<void> sendMessage(String message, String? quotedEhr) async {
    if (currentUserId == null) return;

    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      await _chatService.sendMessage(
        patientId: patientId,
        senderId: currentUserId!,
        message: message,
        quotedEhr: quotedEhr,
      );
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
      
      return; // エラーを再スローしない
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addReaction(String messageId, String emoji) async {
    if (currentUserId == null) return;

    await _chatService.addReaction(
      patientId: patientId,
      messageId: messageId,
      emoji: emoji,
      userId: currentUserId!,
    );
  }

  Future<void> shareMessage(String messageId) async {
    await _chatService.shareMessage(
      patientId: patientId,
      messageId: messageId,
    );
  }
}
