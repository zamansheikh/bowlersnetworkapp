import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection.dart';
import '../cubit/feed_cubit.dart';
import '../widgets/feed_post_card.dart';
import '../widgets/comments_section.dart';

class PostDetailPage extends StatelessWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FeedCubit>()..loadPostDetails(postId),
      child: PostDetailView(postId: postId),
    );
  }
}

class PostDetailView extends StatefulWidget {
  final String postId;

  const PostDetailView({super.key, required this.postId});

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  final TextEditingController _commentController = TextEditingController();
  bool _isAddingComment = false;
  String? _replyToCommentId;
  final TextEditingController _replyController = TextEditingController();
  bool _isAddingReply = false;

  @override
  void dispose() {
    _commentController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  void _handleAddComment() async {
    if (_commentController.text.trim().isEmpty || _isAddingComment) return;

    setState(() {
      _isAddingComment = true;
    });

    try {
      await context.read<FeedCubit>().addCommentToPost(
        widget.postId,
        _commentController.text.trim(),
      );
      _commentController.clear();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to add comment')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingComment = false;
        });
      }
    }
  }

  void _handleAddReply(String commentId) async {
    if (_replyController.text.trim().isEmpty || _isAddingReply) return;

    setState(() {
      _isAddingReply = true;
    });

    try {
      await context.read<FeedCubit>().addReply(
        commentId,
        _replyController.text.trim(),
      );
      _replyController.clear();
      setState(() {
        _replyToCommentId = null;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to add reply')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingReply = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Refresh the post in the feed when going back
          try {
            final feedCubit = context.read<FeedCubit>();
            feedCubit.refreshPostInFeed(int.parse(widget.postId));
          } catch (e) {
            // Ignore errors when refreshing
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.black),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Post',
            style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: BlocConsumer<FeedCubit, FeedState>(
          listener: (context, state) {
            if (state is CommentAddSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Comment added successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state is CommentAddError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is ReplyAddSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reply added successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state is ReplyAddError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is FeedLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryLimeGreen,
                ),
              );
            }

            if (state is FeedError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load post',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: AppColors.error),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColors.gray),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context
                          .read<FeedCubit>()
                          .loadPostDetails(widget.postId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLimeGreen,
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is PostDetailLoaded) {
              final post = state.post;
              return Column(
                children: [
                  // Post content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Post card
                          FeedPostCard(
                            post: post,
                            postIndex: 0,
                            onPostUpdate: () => context
                                .read<FeedCubit>()
                                .loadPostDetails(widget.postId),
                          ),
                          const SizedBox(height: 24),

                          // Comments section
                          CommentsSection(
                            post: post,
                            onReplyTap: (commentId) {
                              setState(() {
                                _replyToCommentId =
                                    _replyToCommentId == commentId
                                    ? null
                                    : commentId;
                              });
                            },
                            replyToCommentId: _replyToCommentId,
                            replyController: _replyController,
                            isAddingReply: _isAddingReply,
                            onAddReply: _handleAddReply,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Comment input
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      border: Border(
                        top: BorderSide(color: AppColors.lightGray, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Write a comment...',
                              hintStyle: const TextStyle(color: AppColors.gray),
                              filled: true,
                              fillColor: AppColors.lightGray,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _isAddingComment ? null : _handleAddComment,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color:
                                  _commentController.text.trim().isNotEmpty &&
                                      !_isAddingComment
                                  ? AppColors.primaryLimeGreen
                                  : AppColors.gray,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: _isAddingComment
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.send,
                                    color: AppColors.white,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const Center(child: Text('No post found'));
          },
        ),
      ),
    );
  }
}
