import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/feed_post.dart';
import '../cubit/feed_cubit.dart';

class FeedPostCard extends StatefulWidget {
  final FeedPost post;
  final int postIndex;
  final VoidCallback? onPostUpdate;

  const FeedPostCard({
    super.key,
    required this.post,
    required this.postIndex,
    this.onPostUpdate,
  });

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  late FeedPost _localPost;
  bool _isLiking = false;
  bool _isVoting = false;
  int? _selectedPollOption;

  @override
  void initState() {
    super.initState();
    _localPost = widget.post;
  }

  @override
  void didUpdateWidget(FeedPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post != widget.post) {
      _localPost = widget.post;
    }
  }

  void _handleLike() async {
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
      // Optimistic update
      final newLikedState = !_localPost.isLikedByMe;
      _localPost = _localPost.copyWith(
        isLikedByMe: newLikedState,
        metadata: _localPost.metadata.copyWith(
          totalLikes: newLikedState
              ? _localPost.metadata.totalLikes + 1
              : _localPost.metadata.totalLikes - 1,
        ),
      );
    });

    try {
      await context.read<FeedCubit>().toggleLike(
        _localPost.metadata.id,
        widget.postIndex,
      );
      widget.onPostUpdate?.call();
    } catch (error) {
      // Revert optimistic update on error
      setState(() {
        _localPost = widget.post;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to like post')));
      }
    } finally {
      setState(() {
        _isLiking = false;
      });
    }
  }

  void _handleFollow() async {
    if (_localPost.author.viewerIsAuthor) return;

    try {
      await context.read<FeedCubit>().followUser(
        _localPost.author.userId,
        widget.postIndex,
      );
      setState(() {
        _localPost = _localPost.copyWith(
          author: _localPost.author.copyWith(isFollowing: true),
        );
      });
      widget.onPostUpdate?.call();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to follow user')));
      }
    }
  }

  void _handlePollVote(int optionId) async {
    if (_isVoting || _localPost.poll == null) return;

    setState(() {
      _isVoting = true;
      _selectedPollOption = optionId;
    });

    try {
      await context.read<FeedCubit>().voteOnPoll(optionId, widget.postIndex);
      widget.onPostUpdate?.call();
    } catch (error) {
      setState(() {
        _selectedPollOption = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to vote on poll')));
      }
    } finally {
      setState(() {
        _isVoting = false;
      });
    }
  }

  String _formatTimeAgo(String createdAt) {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 7) {
        return DateFormat('MMM d, y').format(dateTime);
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return createdAt;
    }
  }

  Widget _buildTextWithTags(String text, List<String> tags) {
    if (tags.isEmpty) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          height: 1.4,
          color: AppColors.black,
        ),
      );
    }

    final parts = text.split(RegExp(r'(#\w+)'));
    final spans = <TextSpan>[];

    for (final part in parts) {
      if (part.startsWith('#')) {
        spans.add(
          TextSpan(
            text: part,
            style: const TextStyle(
              color: AppColors.primaryLimeGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: part,
            style: const TextStyle(color: AppColors.black),
          ),
        );
      }
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: const TextStyle(fontSize: 15, height: 1.4),
      ),
    );
  }

  Widget _buildMediaGallery() {
    if (_localPost.media.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      constraints: const BoxConstraints(maxHeight: 400),
      child: _localPost.media.length == 1
          ? _buildSingleImage(_localPost.media.first)
          : _buildMultipleImages(),
    );
  }

  Widget _buildSingleImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: AppColors.lightGray,
            child: const Center(
              child: Icon(Icons.broken_image, color: AppColors.gray, size: 48),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMultipleImages() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _localPost.media.length,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: EdgeInsets.only(
              right: index < _localPost.media.length - 1 ? 8 : 0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _localPost.media[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.lightGray,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: AppColors.gray,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPoll() {
    final poll = _localPost.poll;
    if (poll == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            poll.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          ...poll.options.map((option) => _buildPollOption(option)),
        ],
      ),
    );
  }

  Widget _buildPollOption(PollOption option) {
    final isSelected = _selectedPollOption == option.optionId;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _handlePollVote(option.optionId),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryLimeGreen.withValues(alpha: 0.1)
                : AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryLimeGreen
                  : AppColors.lightGray,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected
                        ? AppColors.primaryLimeGreen
                        : AppColors.black,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${option.perc}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGray,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          // Like button
          InkWell(
            onTap: _handleLike,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _localPost.isLikedByMe
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: _localPost.isLikedByMe ? Colors.red : AppColors.gray,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_localPost.metadata.totalLikes}',
                    style: const TextStyle(
                      color: AppColors.darkGray,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Comment button
          InkWell(
            onTap: () {
              // TODO: Implement comment functionality
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.comment_outlined,
                    color: AppColors.gray,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_localPost.metadata.totalComments}',
                    style: const TextStyle(
                      color: AppColors.darkGray,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Share button
          InkWell(
            onTap: () {
              // TODO: Implement share functionality
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: const Icon(
                Icons.share_outlined,
                color: AppColors.gray,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header
            Row(
              children: [
                // User avatar
                GestureDetector(
                  onTap: () {
                    // TODO: Navigate to user profile
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.lightGray,
                    backgroundImage:
                        _localPost.author.profilePictureUrl.isNotEmpty
                        ? NetworkImage(_localPost.author.profilePictureUrl)
                        : null,
                    child: _localPost.author.profilePictureUrl.isEmpty
                        ? Text(
                            _localPost.author.name.isNotEmpty
                                ? _localPost.author.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: AppColors.darkGray,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                // User info
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Navigate to user profile
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _localPost.author.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          _formatTimeAgo(_localPost.metadata.createdAt),
                          style: const TextStyle(
                            color: AppColors.gray,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Follow button
                if (!_localPost.author.viewerIsAuthor &&
                    !_localPost.author.isFollowing)
                  GestureDetector(
                    onTap: _handleFollow,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryLimeGreen),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '+ Follow',
                        style: TextStyle(
                          color: AppColors.primaryLimeGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Post content
            if (_localPost.caption.isNotEmpty)
              _buildTextWithTags(_localPost.caption, _localPost.tags),

            // Media gallery
            _buildMediaGallery(),

            // Poll
            _buildPoll(),

            const SizedBox(height: 8),

            // Action bar
            _buildActionBar(),
          ],
        ),
      ),
    );
  }
}
