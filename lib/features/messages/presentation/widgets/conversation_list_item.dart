import 'package:flutter/material.dart';
import '../../data/models/conversation_model.dart';
import '../../../../core/constants/colors.dart';

class ConversationListItem extends StatelessWidget {
  final ConversationModel conversation;
  final bool isSelected;
  final VoidCallback onTap;

  const ConversationListItem({
    super.key,
    required this.conversation,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryLimeGreen.withOpacity(0.1) : null,
        border: isSelected
            ? Border(
                right: BorderSide(color: AppColors.primaryLimeGreen, width: 3),
              )
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage:
                  (conversation.displayImageUrl?.isNotEmpty == true)
                  ? NetworkImage(conversation.displayImageUrl!)
                  : null,
              backgroundColor: Colors.grey[300],
              onBackgroundImageError: (_, __) {
                print(
                  'Failed to load conversation image: ${conversation.displayImageUrl}',
                );
              },
              child: (conversation.displayImageUrl?.isEmpty != false)
                  ? Text(
                      conversation.displayName.isNotEmpty
                          ? conversation.displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            if (conversation.unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLimeGreen,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    conversation.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                conversation.displayName,
                style: TextStyle(
                  fontWeight: conversation.unreadCount > 0
                      ? FontWeight.bold
                      : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (conversation.type == 'group')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Group',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (conversation.lastMessage != null)
              Text(
                _getLastMessageText(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontWeight: conversation.unreadCount > 0
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            else
              Text(
                'No messages yet',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 2),
            Text(
              conversation.lastActivity ?? 'Unknown',
              style: TextStyle(color: Colors.grey[400], fontSize: 11),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _getLastMessageText() {
    final lastMessage = conversation.lastMessage;
    if (lastMessage == null) return '';

    String prefix = lastMessage.sentByMe ? 'You: ' : '';
    String text = lastMessage.message.text;

    if (text.isEmpty && lastMessage.message.media.isNotEmpty) {
      text =
          '📎 ${lastMessage.message.media.length} attachment${lastMessage.message.media.length > 1 ? 's' : ''}';
    }

    const maxLength = 35;
    if (text.length > maxLength) {
      text = '${text.substring(0, maxLength)}...';
    }

    return '$prefix$text';
  }
}
