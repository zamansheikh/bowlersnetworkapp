import 'package:flutter/material.dart';
import '../../data/models/message_model.dart';
import '../../../../core/constants/colors.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool showGroupInfo;

  const MessageBubble({
    super.key,
    required this.message,
    this.showGroupInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: message.sentByMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.sentByMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(message.sender.profilePictureUrl),
              backgroundColor: Colors.grey[300],
              onBackgroundImageError: (_, __) {},
              child: message.sender.profilePictureUrl.isEmpty
                  ? Text(
                      message.sender.name.isNotEmpty
                          ? message.sender.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.sentByMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (showGroupInfo && !message.sentByMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message.sender.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: message.sentByMe
                        ? AppColors.primaryLimeGreen
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.message.text.isNotEmpty)
                        Text(
                          message.message.text,
                          style: TextStyle(
                            color: message.sentByMe
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      if (message.message.media.isNotEmpty) ...[
                        if (message.message.text.isNotEmpty)
                          const SizedBox(height: 8),
                        _buildMediaPreview(),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    message.timeDetails.timesince,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ),
              ],
            ),
          ),
          if (message.sentByMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(message.sender.profilePictureUrl),
              backgroundColor: Colors.grey[300],
              onBackgroundImageError: (_, __) {},
              child: message.sender.profilePictureUrl.isEmpty
                  ? Text(
                      message.sender.name.isNotEmpty
                          ? message.sender.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaPreview() {
    if (message.message.media.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: message.message.media.take(4).map((mediaUrl) {
        final isVideo = _isVideoFile(mediaUrl);
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isVideo
                ? Stack(
                    children: [
                      Container(
                        color: Colors.black26,
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_filled,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'VIDEO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Image.network(
                    mediaUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 24,
                        ),
                      );
                    },
                  ),
          ),
        );
      }).toList(),
    );
  }

  bool _isVideoFile(String url) {
    final extensions = ['.mp4', '.webm', '.ogg', '.mov', '.avi'];
    return extensions.any((ext) => url.toLowerCase().endsWith(ext));
  }
}
