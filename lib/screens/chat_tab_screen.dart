import 'package:flutter/material.dart';

class Reaction {
  final String emoji;
  final String user;

  Reaction({
    required this.emoji,
    required this.user,
  });
}

class ChatMessage {
  final String sender;
  final String message;
  final DateTime timestamp;
  final bool isCurrentUser;
  final String avatarText;
  final List<Reaction> reactions;
  final String? quotedEhr; // 電子カルテからの引用
  final bool isShared; // 他の医療従事者と共有されているか

  ChatMessage({
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

class ChatTabScreen extends StatefulWidget {
  const ChatTabScreen({super.key});

  @override
  State<ChatTabScreen> createState() => _ChatTabScreenState();
}

class _ChatTabScreenState extends State<ChatTabScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? _selectedEhr;

  final List<ChatMessage> _messages = [
    ChatMessage(
      sender: '山田医師',
      message: '患者の血圧が高めです。経過観察をお願いします。',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      isCurrentUser: false,
      avatarText: '山田',
      quotedEhr: '血圧: 145/95 mmHg\n脈拍: 78/分\n体温: 36.8℃',
      reactions: [
        Reaction(emoji: '👍', user: '鈴木看護師'),
        Reaction(emoji: '✅', user: '佐藤医師'),
      ],
    ),
    ChatMessage(
      sender: '鈴木看護師',
      message: '承知しました。定期的に測定を行います。',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isCurrentUser: true,
      avatarText: '鈴木',
      isShared: true,
      reactions: [
        Reaction(emoji: '👀', user: '山田医師'),
      ],
    ),
  ];

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showEhrSelector() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '電子カルテから引用',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                // 実際の実装では電子カルテAPIから取得
                ListTile(
                  title: const Text('最新のバイタル'),
                  subtitle: const Text('血圧: 132/85 mmHg\n脈拍: 75/分\n体温: 36.5℃'),
                  onTap: () {
                    setState(() {
                      _selectedEhr = '血圧: 132/85 mmHg\n脈拍: 75/分\n体温: 36.5℃';
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('処方情報'),
                  subtitle: const Text('降圧剤: アムロジピン 5mg\n利尿薬: フロセミド 20mg'),
                  onTap: () {
                    setState(() {
                      _selectedEhr = '降圧剤: アムロジピン 5mg\n利尿薬: フロセミド 20mg';
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReactionPicker(ChatMessage message, int index) {
    final reactions = ['👍', '✅', '👀', '❗', '⭐'];

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'リアクションを追加',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  children: reactions.map((emoji) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          final updatedMessage = message.copyWith(
                            reactions: [
                              ...message.reactions,
                              Reaction(
                                emoji: emoji,
                                user: '鈴木看護師',
                              ),
                            ],
                          );
                          _messages[index] = updatedMessage;
                        });
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _shareMessage(ChatMessage message, int index) {
    // 実際の実装では共有先選択UIを表示
    setState(() {
      final updatedMessage = message.copyWith(isShared: true);
      _messages[index] = updatedMessage;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('他の医療従事者と共有しました'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          sender: '鈴木看護師',
          message: _messageController.text,
          timestamp: DateTime.now(),
          isCurrentUser: true,
          avatarText: '鈴木',
          quotedEhr: _selectedEhr,
        ),
      );
      _selectedEhr = null;
    });
    _messageController.clear();

    // スクロールを一番下に移動
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return '今日';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return '昨日';
    }
    return '${date.month}月${date.day}日';
  }

  Widget _buildAvatar(String text, Color backgroundColor) {
    return CircleAvatar(
      backgroundColor: backgroundColor,
      radius: 16,
      child: Text(
        text.characters.first,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? currentDate;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[_messages.length - 1 - index];
              final messageDate = _formatDate(message.timestamp);

              // 日付区切りの表示判定
              Widget? dateWidget;
              if (currentDate != messageDate) {
                dateWidget = Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        messageDate,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
                currentDate = messageDate;
              }

              return Column(
                children: [
                  if (dateWidget != null) dateWidget,
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    child: Row(
                      mainAxisAlignment: message.isCurrentUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!message.isCurrentUser) ...[
                          _buildAvatar(
                            message.avatarText,
                            Colors.blue,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Column(
                            crossAxisAlignment: message.isCurrentUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (!message.isCurrentUser)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Text(
                                    message.sender,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              Column(
                                crossAxisAlignment: message.isCurrentUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (message.quotedEhr != null)
                                    Container(
                                      margin:
                                          const EdgeInsets.only(bottom: 8.0),
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F3F4),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFE8EAED),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(
                                                Icons.description,
                                                size: 16,
                                                color: Color(0xFF5F6368),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                '電子カルテより',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF5F6368),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            message.quotedEhr!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF202124),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  InkWell(
                                    onLongPress: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return SafeArea(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ListTile(
                                                  leading: const Icon(
                                                      Icons.add_reaction),
                                                  title:
                                                      const Text('リアクションを追加'),
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    _showReactionPicker(
                                                      message,
                                                      _messages.length -
                                                          1 -
                                                          index,
                                                    );
                                                  },
                                                ),
                                                ListTile(
                                                  leading:
                                                      const Icon(Icons.share),
                                                  title:
                                                      const Text('他の医療従事者と共有'),
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    _shareMessage(
                                                      message,
                                                      _messages.length -
                                                          1 -
                                                          index,
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 4.0),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 8.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: message.isCurrentUser
                                            ? const Color(0xFF1A73E8)
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        message.message,
                                        style: TextStyle(
                                          color: message.isCurrentUser
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (message.reactions.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Wrap(
                                        spacing: 4,
                                        children: message.reactions
                                            .map((reaction) => Tooltip(
                                                  message: reaction.user,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFF1F3F4),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Text(
                                                      reaction.emoji,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (message.isShared)
                                        const Padding(
                                          padding: EdgeInsets.only(
                                              right: 4.0, top: 4.0),
                                          child: Icon(
                                            Icons.share,
                                            size: 12,
                                            color: Color(0xFF5F6368),
                                          ),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 4.0, left: 4.0),
                                        child: Text(
                                          '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (message.isCurrentUser) ...[
                          const SizedBox(width: 8),
                          _buildAvatar(
                            message.avatarText,
                            Colors.green,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: _showEhrSelector,
                  icon: const Icon(
                    Icons.description,
                    color: Color(0xFF5F6368),
                  ),
                  tooltip: '電子カルテから引用',
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'メッセージを入力',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                      ),
                      maxLines: null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1A73E8),
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
