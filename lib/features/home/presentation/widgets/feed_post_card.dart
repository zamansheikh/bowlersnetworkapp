import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/feed_post.dart';
import '../cubit/feed_cubit.dart';
import 'media_gallery.dart';

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
  bool _isLiking = false;
  bool _isVoting = false;
  int? _selectedPollOption;

  void _handleLike() async {
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
    });

    try {
      await context.read<FeedCubit>().toggleLike(
        widget.post.metadata.id,
        widget.postIndex,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to like post')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
      }
    }
  }

  void _handleFollow() async {
    if (widget.post.author.viewerIsAuthor) return;

    try {
      await context.read<FeedCubit>().followUser(
        widget.post.author.userId,
        widget.postIndex,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to follow user')));
      }
    }
  }

  void _handlePollVote(int optionId) async {
    if (_isVoting || widget.post.poll == null) return;

    setState(() {
      _isVoting = true;
      _selectedPollOption = optionId;
    });

    try {
      await context.read<FeedCubit>().voteOnPoll(optionId, widget.postIndex);
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

  Widget _buildMediaGallery() {
    if (widget.post.media.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: MediaGallery(
          mediaUrls: widget.post.media,
          height: 224.h,
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Widget _buildPoll() {
    final poll = widget.post.poll;
    if (poll == null) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFEFEFEF), width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            poll.title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF424242),
              height: 1.5,
            ),
          ),
          SizedBox(height: 12.h),
          ...poll.options.map((option) => _buildPollOption(option)),
        ],
      ),
    );
  }

  Widget _buildPollOption(PollOption option) {
    final isSelected = _selectedPollOption == option.optionId;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: () => _handlePollVote(option.optionId),
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF4F9ED) : Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFE2E2E2), width: 1.w),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option.content,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                    color: const Color(0xFF6D6D6D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F9ED), // Lime green background
                  borderRadius: BorderRadius.circular(90.r),
                ),
                width: 40.w,
                child: Center(
                  child: Text(
                    '${option.perc}%',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6D6D6D),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLikedByAndActions() {
    return Column(
      children: [
        // Liked by section
        if (widget.post.metadata.totalLikes > 0)
          Container(
            margin: EdgeInsets.only(bottom: 8.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F9ED),
                borderRadius: BorderRadius.circular(90.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Overlapping avatars
                  Container(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Stack(
                      children: [
                        Container(
                          width: 20.w,
                          height: 20.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                          ),
                        ),
                        Positioned(
                          left: 12.w,
                          child: Container(
                            width: 20.w,
                            height: 20.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 24.w,
                          child: Container(
                            width: 20.w,
                            height: 20.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Liked by picklu and momit',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF191919),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Action bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side - action buttons
            Row(
              children: [
                // Like button
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFE2E2E2),
                      width: 1.w,
                    ),
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  child: InkWell(
                    onTap: _handleLike,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/favourite.svg',
                          width: 20.w,
                          height: 20.h,
                          colorFilter: ColorFilter.mode(
                            widget.post.isLikedByMe
                                ? Colors.red
                                : const Color(0xFF6D6D6D),
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${widget.post.metadata.totalLikes}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6D6D6D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                // Share button
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFE2E2E2),
                      width: 1.w,
                    ),
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  child: InkWell(
                    onTap: () {
                      // TODO: Implement share functionality
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/share.svg',
                          width: 20.w,
                          height: 20.h,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF6D6D6D),
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '13',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6D6D6D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                // Comment button
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFE2E2E2),
                      width: 1.w,
                    ),
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  child: InkWell(
                    onTap: () {
                      context.push('/post/${widget.post.metadata.id}');
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/comment.svg',
                          width: 20.w,
                          height: 20.h,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF6D6D6D),
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${widget.post.metadata.totalComments}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6D6D6D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Right side - Bookmark button
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFF0EEEE), width: 1.w),
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: SvgPicture.asset(
                'assets/icons/bookmark.svg',
                width: 20.w,
                height: 20.h,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF6D6D6D),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE6E6E6), width: 1.w),
      ),
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side - User info
              Expanded(
                child: Row(
                  children: [
                    // User avatar
                    GestureDetector(
                      onTap: () {
                        // TODO: Navigate to user profile
                      },
                      child: CircleAvatar(
                        radius: 24.r,
                        backgroundColor: AppColors.lightGray,
                        backgroundImage:
                            widget.post.author.profilePictureUrl.isNotEmpty
                            ? NetworkImage(widget.post.author.profilePictureUrl)
                            : null,
                        child: widget.post.author.profilePictureUrl.isEmpty
                            ? Text(
                                widget.post.author.name.isNotEmpty
                                    ? widget.post.author.name[0].toUpperCase()
                                    : 'U',
                                style: TextStyle(
                                  color: AppColors.darkGray,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18.sp,
                                ),
                              )
                            : null,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // User info
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Navigate to user profile
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.post.author.name,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.sp,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                // Verification badge
                                SvgPicture.asset(
                                  'assets/icons/verification.svg',
                                  width: 16.w,
                                  height: 16.h,
                                ),
                              ],
                            ),
                            Text(
                              _formatTimeAgo(widget.post.metadata.createdAt),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: const Color(0xFF6D6D6D),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Right side - Follow button
              if (!widget.post.author.viewerIsAuthor)
                GestureDetector(
                  onTap: _handleFollow,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: widget.post.author.isFollowing
                          ? AppColors.primaryLimeGreen
                          : Colors.transparent,
                      border: Border.all(
                        color: AppColors.primaryLimeGreen,
                        width: 1.w,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      widget.post.author.isFollowing ? 'Following' : 'Follow',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: widget.post.author.isFollowing
                            ? Colors.white
                            : AppColors.primaryLimeGreen,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 16.h),

          // Post content - clickable
          GestureDetector(
            onTap: () {
              context.push('/post/${widget.post.metadata.id}');
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post content
                if (widget.post.caption.isNotEmpty)
                  Text(
                    widget.post.caption,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: const Color(0xFF424242),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),

                // Media gallery
                _buildMediaGallery(),

                // Poll
                _buildPoll(),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // Liked by section and Action bar
          _buildLikedByAndActions(),
        ],
      ),
    );
  }
}
