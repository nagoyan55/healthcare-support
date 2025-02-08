class Reaction {
  final String emoji;
  final String user;

  Reaction({
    required this.emoji,
    required this.user,
  });
}

class ChatMessage {
  final String id;
  final String sender;
  final String message;
  final DateTime timestamp;
  final bool isCurrentUser;
  final String avatarText;
  final List<Reaction> reactions;
  final String? quotedEhr;
  final bool isShared;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.message,
    required this.timestamp,
    required this.isCurrentUser,
    required this.avatarText,
    this.reactions = const [],
    this.quotedEhr,
    this.isShared = false,
  });

  ChatMessage copyWith({
    String? id,
    String? sender,
    String? message,
    DateTime? timestamp,
    bool? isCurrentUser,
    String? avatarText,
    List<Reaction>? reactions,
    String? quotedEhr,
    bool? isShared,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      avatarText: avatarText ?? this.avatarText,
      reactions: reactions ?? this.reactions,
      quotedEhr: quotedEhr ?? this.quotedEhr,
      isShared: isShared ?? this.isShared,
    );
  }
}
