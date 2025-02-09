import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../services/auth_service.dart';
import '../../providers/ai_chat_provider.dart';
import '../../widgets/auth_wrapper.dart';
import '../../widgets/chat_date_divider.dart';
import '../../widgets/chat_message_item.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AuthService _authService = AuthService();
  late final AIChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = AIChatProvider(
      currentUserId: _authService.currentUser?.uid,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    try {
      await _chatProvider.sendMessage(message);
      _messageController.clear();

      // メッセージ送信後、最下部にスクロール
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      // エラーはChatProviderで管理されるため、ここでは何もしない
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthWrapper(
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<Map<String, List<ChatMessage>>>(
              stream: _chatProvider.getMessagesByDate(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('エラーが発生しました: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('メッセージがありません'));
                }

                final messagesByDate = snapshot.data!;
                final dates = messagesByDate.keys.toList();

                return ListView.builder(
                  controller: _scrollController,
                  reverse: false,
                  itemCount: dates.length,
                  itemBuilder: (context, index) {
                    final date = dates[index];
                    final messages = messagesByDate[date]!;

                    return Column(
                      children: [
                        ChatDateDivider(date: date),
                        ...messages.map(
                          (message) => ChatMessageItem(
                            message: message,
                            onReactionAdd: (_) {}, // AIチャットではリアクション機能は使用しない
                            onShare: (_) {}, // AIチャットでは共有機能は使用しない
                          ),
                        ),
                      ],
                    );
                  },
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
                  Stack(
                    children: [
                      ListenableBuilder(
                        listenable: _chatProvider,
                        builder: (context, _) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _chatProvider.error != null 
                                ? Colors.red 
                                : const Color(0xFF1A73E8),
                            ),
                            child: IconButton(
                              onPressed: _chatProvider.isLoading ? null : _sendMessage,
                              icon: _chatProvider.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                    ),
                            ),
                          );
                        },
                      ),
                      ListenableBuilder(
                        listenable: _chatProvider,
                        builder: (context, _) {
                          if (_chatProvider.error != null) {
                            return Positioned(
                              top: -40,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _chatProvider.error!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
