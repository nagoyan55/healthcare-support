import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../utils/date_formatter.dart';

class ChatMessageItem extends StatelessWidget {
  final ChatMessage message;
  final Function(ChatMessage) onReactionAdd;
  final Function(ChatMessage) onShare;

  const ChatMessageItem({
    super.key,
    required this.message,
    required this.onReactionAdd,
    required this.onShare,
  });

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
    return Padding(
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
                        margin: const EdgeInsets.only(bottom: 8.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3F4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE8EAED),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                    leading: const Icon(Icons.add_reaction),
                                    title: const Text('リアクションを追加'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      onReactionAdd(message);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.share),
                                    title: const Text('他の医療従事者と共有'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      onShare(message);
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F3F4),
                                        borderRadius: BorderRadius.circular(12),
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
                            padding: EdgeInsets.only(right: 4.0, top: 4.0),
                            child: Icon(
                              Icons.share,
                              size: 12,
                              color: Color(0xFF5F6368),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                          child: Text(
                            DateFormatter.formatMessageTime(message.timestamp),
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
    );
  }
}
