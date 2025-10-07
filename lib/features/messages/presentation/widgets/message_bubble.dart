import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/message_model.dart';

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
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 20.w),
      child: Row(
        mainAxisAlignment: message.sentByMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.sentByMe && showGroupInfo) ...[
            Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: message.sender.profilePictureUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.network(
                        message.sender.profilePictureUrl,
                        width: 32.w,
                        height: 32.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildFallbackAvatar();
                        },
                      ),
                    )
                  : _buildFallbackAvatar(),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.sentByMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (showGroupInfo && !message.sentByMe)
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Text(
                      message.sender.name,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.sp,
                        color: const Color(0xFF6D6D6D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: message.sentByMe
                        ? const Color(0xFF8BC342) // Figma lime green
                        : const Color(0xFFF4F9ED), // Figma light green
                    borderRadius: _getBorderRadius(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.message.text.isNotEmpty)
                        Text(
                          message.message.text,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: message.sentByMe
                                ? const Color(0xFF111B05)
                                : const Color(0xFF6D6D6D),
                            fontSize: 12.sp,
                            height: 1.33,
                          ),
                        ),
                      if (message.message.media.isNotEmpty) ...[
                        if (message.message.text.isNotEmpty)
                          SizedBox(height: 8.h),
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
              onBackgroundImageError: (_, _) {},
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

  Widget _buildFallbackAvatar() {
    return Container(
      width: 32.w,
      height: 32.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[400],
      ),
      child: Center(
        child: Text(
          message.sender.name.isNotEmpty
              ? message.sender.name[0].toUpperCase()
              : '?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  BorderRadius _getBorderRadius() {
    if (message.sentByMe) {
      // Outgoing message (right side) - rounded on left, square on bottom right
      return BorderRadius.only(
        topLeft: Radius.circular(20.r),
        topRight: Radius.circular(8.r),
        bottomLeft: Radius.circular(20.r),
        bottomRight: Radius.circular(8.r),
      );
    } else {
      // Incoming message (left side) - rounded on right, square on bottom left
      return BorderRadius.only(
        topLeft: Radius.circular(8.r),
        topRight: Radius.circular(20.r),
        bottomLeft: Radius.circular(8.r),
        bottomRight: Radius.circular(20.r),
      );
    }
  }
}
