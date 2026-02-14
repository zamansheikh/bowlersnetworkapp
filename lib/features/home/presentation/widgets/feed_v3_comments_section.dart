import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/feed_v3_post.dart';
import '../../data/repositories/feed_v3_repository.dart';

/// Reusable comments section for FeedV3 posts
class FeedV3CommentsSection extends StatefulWidget {
  final int postId;
  final FeedV3Repository repository;
  final int pageSize;
  final VoidCallback? onCommentAdded;

  const FeedV3CommentsSection({
    super.key,
    required this.postId,
    required this.repository,
    this.pageSize = 15,
    this.onCommentAdded,
  });

  @override
  State<FeedV3CommentsSection> createState() => _FeedV3CommentsSectionState();
}

class _FeedV3CommentsSectionState extends State<FeedV3CommentsSection> {
  final _commentController = TextEditingController();
  final _focusNode = FocusNode();
  List<FeedV3Comment> _comments = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _hasMore = false;
  int _currentPage = 1;
  int? _replyingTo; // comment id being replied to
  String? _replyingToName;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadComments({bool loadMore = false}) async {
    if (loadMore && !_hasMore) return;

    try {
      final page = loadMore ? _currentPage + 1 : 1;
      final response = await widget.repository.getComments(
        widget.postId,
        page: page,
        pageSize: widget.pageSize,
      );

      setState(() {
        if (loadMore) {
          _comments = [..._comments, ...response.results];
        } else {
          _comments = response.results;
        }
        _hasMore = response.hasMore;
        _currentPage = page;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      final comment = await widget.repository.addComment(
        widget.postId,
        text: text,
        parentId: _replyingTo,
      );
      _commentController.clear();

      if (_replyingTo != null) {
        // Add reply under parent comment
        setState(() {
          _comments = _comments.map((c) {
            if (c.id == _replyingTo) {
              return c.copyWith(replies: [...c.replies, comment]);
            }
            return c;
          }).toList();
          _replyingTo = null;
          _replyingToName = null;
        });
      } else {
        // Add top-level comment
        setState(() {
          _comments = [comment, ..._comments];
        });
      }

      widget.onCommentAdded?.call();
    } catch (e) {
      // Show error
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _toggleCommentLike(int commentId) async {
    // Optimistic update
    setState(() {
      _comments = _comments.map((c) {
        if (c.id == commentId) {
          return c.copyWith(
            hasLiked: !c.hasLiked,
            likesCount: c.likesCount + (c.hasLiked ? -1 : 1),
          );
        }
        // Check replies
        final updatedReplies = c.replies.map((r) {
          if (r.id == commentId) {
            return r.copyWith(
              hasLiked: !r.hasLiked,
              likesCount: r.likesCount + (r.hasLiked ? -1 : 1),
            );
          }
          return r;
        }).toList();
        return c.copyWith(replies: updatedReplies);
      }).toList();
    });

    try {
      await widget.repository.likeComment(commentId);
    } catch (_) {
      // Revert on failure - reload
      _loadComments();
    }
  }

  Future<void> _deleteComment(int commentId) async {
    try {
      await widget.repository.deleteComment(commentId);
      setState(() {
        _comments = _comments
            .where((c) => c.id != commentId)
            .map(
              (c) => c.copyWith(
                replies: c.replies.where((r) => r.id != commentId).toList(),
              ),
            )
            .toList();
      });
      widget.onCommentAdded?.call();
    } catch (_) {}
  }

  void _startReply(int commentId, String authorName) {
    setState(() {
      _replyingTo = commentId;
      _replyingToName = authorName;
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, color: AppColors.borderLight),

        // Comment input
        _buildCommentInput(),

        // Comments list
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryLimeGreen,
              ),
            ),
          )
        else if (_comments.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No comments yet. Be the first!',
                style: TextStyle(color: AppColors.gray400, fontSize: 13),
              ),
            ),
          )
        else ...[
          ..._comments.map((comment) => _buildCommentTile(comment)),
          if (_hasMore)
            TextButton(
              onPressed: () => _loadComments(loadMore: true),
              child: const Text(
                'Load more comments',
                style: TextStyle(
                  color: AppColors.primaryLimeGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reply indicator
          if (_replyingTo != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.reply, size: 14, color: AppColors.gray500),
                  const SizedBox(width: 4),
                  Text(
                    'Replying to $_replyingToName',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray500,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() {
                      _replyingTo = null;
                      _replyingToName = null;
                    }),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
          // Input row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _focusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitComment(),
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: _replyingTo != null
                        ? 'Write a reply...'
                        : 'Write a comment...',
                    hintStyle: const TextStyle(
                      color: AppColors.gray400,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: AppColors.gray50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _isSubmitting
                  ? const SizedBox(
                      width: 36,
                      height: 36,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryLimeGreen,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.send_rounded),
                      color: AppColors.primaryLimeGreen,
                      iconSize: 22,
                      onPressed: _submitComment,
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTile(FeedV3Comment comment, {bool isReply = false}) {
    return Container(
      padding: EdgeInsets.fromLTRB(isReply ? 56 : 16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: isReply ? 14 : 16,
                backgroundColor: AppColors.gray200,
                backgroundImage: comment.author.profilePictureUrl.isNotEmpty
                    ? CachedNetworkImageProvider(
                        comment.author.profilePictureUrl,
                      )
                    : null,
                child: comment.author.profilePictureUrl.isEmpty
                    ? Text(
                        comment.author.name.isNotEmpty
                            ? comment.author.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: isReply ? 10 : 12,
                          color: AppColors.gray600,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author + time
                    Row(
                      children: [
                        Text(
                          comment.author.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: isReply ? 12 : 13,
                            color: AppColors.gray900,
                          ),
                        ),
                        if (comment.isPostAuthor) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Author',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Text(
                          comment.created,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.gray400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Comment text
                    Text(
                      comment.text,
                      style: TextStyle(
                        fontSize: isReply ? 13 : 14,
                        color: AppColors.gray800,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Actions
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _toggleCommentLike(comment.id),
                          child: Row(
                            children: [
                              Icon(
                                comment.hasLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 14,
                                color: comment.hasLiked
                                    ? AppColors.error
                                    : AppColors.gray400,
                              ),
                              if (comment.likesCount > 0) ...[
                                const SizedBox(width: 3),
                                Text(
                                  '${comment.likesCount}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.gray500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (!isReply)
                          GestureDetector(
                            onTap: () =>
                                _startReply(comment.id, comment.author.name),
                            child: const Text(
                              'Reply',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.gray500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (comment.isMine) ...[
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => _deleteComment(comment.id),
                            child: const Icon(
                              Icons.delete_outline,
                              size: 14,
                              color: AppColors.gray400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Replies
          if (comment.replies.isNotEmpty)
            ...comment.replies.map(
              (reply) => _buildCommentTile(reply, isReply: true),
            ),
        ],
      ),
    );
  }
}
