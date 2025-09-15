import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/feed_post.dart';
import '../cubit/feed_cubit.dart';

class CommentsBottomSheet extends StatefulWidget {
  final FeedPost post;
  final int postIndex;

  const CommentsBottomSheet({
    super.key,
    required this.post,
    required this.postIndex,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await context.read<FeedCubit>().addComment(
        widget.post.metadata.id,
        widget.postIndex,
        _commentController.text.trim(),
      );

      _commentController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add comment: $e')));
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildCommentItem(PostComment comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          CircleAvatar(
            radius: 16,
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
                      fontSize: 12,
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
                // User name and comment
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${comment.user.name} ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: comment.text,
                        style: const TextStyle(
                          color: AppColors.black,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Comment actions (like, reply, etc.)
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        // TODO: Implement like comment
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Like',
                        style: TextStyle(
                          color: AppColors.gray,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () {
                        // TODO: Implement reply to comment
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Reply',
                        style: TextStyle(
                          color: AppColors.gray,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.post.comments.total}',
                  style: const TextStyle(fontSize: 16, color: AppColors.gray),
                ),
              ],
            ),
          ),

          const Divider(height: 24),

          // Comments list
          Flexible(
            child: widget.post.comments.commentList.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 48,
                          color: AppColors.lightGray,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No comments yet',
                          style: TextStyle(color: AppColors.gray, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Be the first to comment!',
                          style: TextStyle(
                            color: AppColors.lightGray,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: widget.post.comments.commentList.length,
                    itemBuilder: (context, index) {
                      return _buildCommentItem(
                        widget.post.comments.commentList[index],
                      );
                    },
                  ),
          ),

          // Comment input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.lightGray, width: 0.5),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // User avatar
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.lightGray,
                    child: Icon(Icons.person, size: 16, color: AppColors.gray),
                  ),
                  const SizedBox(width: 12),
                  // Comment input field
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: TextStyle(color: AppColors.gray),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(color: AppColors.lightGray),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(
                            color: AppColors.primaryLimeGreen,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        isDense: true,
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Submit button
                  GestureDetector(
                    onTap: _isSubmitting ? null : _submitComment,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            _commentController.text.trim().isNotEmpty &&
                                !_isSubmitting
                            ? AppColors.primaryLimeGreen
                            : AppColors.lightGray,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              size: 16,
                              color: Colors.white,
                            ),
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
