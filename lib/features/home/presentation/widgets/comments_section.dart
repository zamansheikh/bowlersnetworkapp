import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/feed_post.dart';

class CommentsSection extends StatelessWidget {
  final FeedPost post;
  final Function(String) onReplyTap;
  final String? replyToCommentId;
  final TextEditingController replyController;
  final bool isAddingReply;
  final Function(String) onAddReply;

  const CommentsSection({
    super.key,
    required this.post,
    required this.onReplyTap,
    this.replyToCommentId,
    required this.replyController,
    required this.isAddingReply,
    required this.onAddReply,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comments header
        Text(
          'Comments (${post.metadata.totalComments})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 16),

        // Comments list
        if (post.comments.commentList.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No comments yet. Be the first to comment!',
                style: TextStyle(color: AppColors.gray, fontSize: 16),
              ),
            ),
          )
        else
          ...post.comments.commentList.map(
            (comment) => _buildCommentItem(comment),
          ),
      ],
    );
  }

  Widget _buildCommentItem(PostComment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.lightGray,
                backgroundImage: comment.user.profilePictureUrl.isNotEmpty
                    ? NetworkImage(comment.user.profilePictureUrl)
                    : null,
                child: comment.user.profilePictureUrl.isEmpty
                    ? Text(
                        comment.user.name.isNotEmpty
                            ? comment.user.name[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: AppColors.darkGray,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Comment content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Comment bubble
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            comment.text,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Reply button
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => onReplyTap(comment.commentId.toString()),
                      child: const Text(
                        'Reply',
                        style: TextStyle(
                          color: AppColors.primaryLimeGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Replies
          if (comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 12),
              child: Column(
                children: comment.replies
                    .map((reply) => _buildReplyItem(reply))
                    .toList(),
              ),
            ),

          // Reply input (if this comment is being replied to)
          if (replyToCommentId == comment.commentId.toString())
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: replyController,
                      decoration: InputDecoration(
                        hintText: 'Write a reply...',
                        hintStyle: const TextStyle(color: AppColors.gray),
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: AppColors.lightGray,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: AppColors.primaryLimeGreen,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: isAddingReply
                        ? null
                        : () => onAddReply(comment.commentId.toString()),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            replyController.text.trim().isNotEmpty &&
                                !isAddingReply
                            ? AppColors.primaryLimeGreen
                            : AppColors.gray,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: isAddingReply
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: AppColors.white,
                              size: 16,
                            ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReplyItem(dynamic reply) {
    // Parse reply data
    final userName = reply['user']?['name'] ?? 'User';
    final profilePictureUrl = reply['user']?['profile_picture_url'] ?? '';
    final replyText = reply['text'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.lightGray,
            backgroundImage: profilePictureUrl.isNotEmpty
                ? NetworkImage(profilePictureUrl)
                : null,
            child: profilePictureUrl.isEmpty
                ? Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: AppColors.darkGray,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),

          // Reply content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.lightGray),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    replyText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.darkGray,
                    ),
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
