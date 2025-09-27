import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/pro_player.dart';
import '../cubit/pro_players_cubit.dart';
import '../../../home/presentation/widgets/feed_post_card.dart';
import '../../../home/data/models/feed_post.dart';

class PlayerDetailPage extends StatefulWidget {
  final String userName;
  final String userId;

  const PlayerDetailPage({
    super.key,
    required this.userName,
    required this.userId,
  });

  @override
  State<PlayerDetailPage> createState() => _PlayerDetailPageState();
}

class _PlayerDetailPageState extends State<PlayerDetailPage> {
  late ProPlayersCubit _cubit;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<ProPlayersCubit>();
    _cubit.loadProPlayerById(widget.userName);
  }

  @override
  void dispose() {
    _cubit.close();
    _videoController?.dispose();
    super.dispose();
  }

  void _initializeVideoPlayer(String videoUrl) {
    if (videoUrl.isNotEmpty) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _videoController?.setLooping(true);
            _videoController?.setVolume(0.0); // Muted
            _videoController?.play();
          }
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: BlocConsumer<ProPlayersCubit, ProPlayersState>(
          listener: (context, state) {
            if (state is ProPlayerDetailError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProPlayerDetailLoading) {
              return _buildLoadingView();
            }

            if (state is ProPlayerDetailLoaded) {
              // Load posts when player is loaded but posts haven't been loaded yet
              if (state.posts == null &&
                  !state.isLoadingPosts &&
                  state.postsError == null) {
                // Trigger posts loading
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _cubit.loadUserPosts(widget.userId);
                });
              }
              return _buildPlayerDetailView(
                state.player,
                state.posts,
                state.isLoadingPosts,
                state.postsError,
              );
            }

            if (state is ProPlayerDetailError) {
              return _buildErrorView(state.message);
            }

            return _buildLoadingView();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF8BC342),
        foregroundColor: Colors.white,
        title: const Text('Player Profile'),
      ),
      body: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8BC342)),
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF8BC342),
        foregroundColor: Colors.white,
        title: const Text('Player Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _cubit.loadProPlayerById(widget.userName),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8BC342),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerDetailView(
    ProPlayer player,
    List<FeedPost>? posts,
    bool isLoadingPosts,
    String? postsError,
  ) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with back button and video/cover
          SliverAppBar(
            expandedHeight: 180,
            pinned: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 60.w,
            leading: Row(
              children: [
                SizedBox(width: 20.w),
                Container(
                  height: 40.w,
                  width: 40.w,
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/back_button.svg',
                      height: 24.h,
                      width: 24.h,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Intro Video or Cover Photo
                  if (player.introVideoUrl.isNotEmpty && player.isPro)
                    _buildVideoPlayer(player.introVideoUrl)
                  else
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF8BC342), Color(0xFF6fa332)],
                        ),
                      ),
                    ),

                  // Dark overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Profile Info Section
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, 10),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture and Basic Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Profile Picture
                        Container(
                          width: 120.w,
                          height: 120.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.white, width: 3.w),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: player.profilePictureUrl.isNotEmpty
                                ? Image.network(
                                    player.profilePictureUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Name and Stats
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name and Pro Badge
                              Row(
                                children: [
                                  Text(
                                    player.name,
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (player.isPro) SizedBox(width: 6.w),
                                  if (player.isPro)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.verified,
                                        color: Colors.white,
                                        size: 16.sp,
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              Text(
                                player.isPro ? 'Pro Player' : 'Amateur Player',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey[600],
                                ),
                              ),

                              SizedBox(height: 8.h),

                              // Circular Stats (like web version)
                              Row(
                                children: [
                                  _buildCircularStat(
                                    player.followerCount.toString(),
                                    'Followers',
                                    Colors.blue,
                                  ),
                                  SizedBox(width: 16.w),
                                  _buildCircularStat(
                                    player.stats.highGame.toString(),
                                    'High Game',
                                    Colors.black,
                                  ),
                                  SizedBox(width: 16.w),
                                  _buildCircularStat(
                                    player.stats.highSeries.toString(),
                                    'High Series',
                                    Colors.orange,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 120.w,
                          child: ElevatedButton(
                            onPressed: () =>
                                _cubit.toggleFollowPlayer(player.userId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: player.isFollowed
                                  ? Colors.green
                                  : const Color(0xFF8BC342),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              player.isFollowed ? 'Following' : 'Follow',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 120.w,
                          child: OutlinedButton(
                            onPressed: () {
                              // Handle get in touch
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.r),
                              ),
                              side: BorderSide(color: Colors.grey[400]!),
                            ),
                            child: Text(
                              'Get in Touch',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 8.h)),

          // Sponsors Section (like web version)
          if (player.sponsors.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: player.sponsors.map((sponsor) {
                    return Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: sponsor.logoUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                sponsor.logoUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.business,
                                      color: Colors.grey,
                                      size: 24,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.business,
                                color: Colors.grey,
                                size: 24,
                              ),
                            ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // Posts Section Header
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: const Text(
                  'Posts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),

          // Posts Grid (like web version)
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: _buildPostsSection(posts, isLoadingPosts, postsError),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularStat(String value, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPostsSection(
    List<FeedPost>? posts,
    bool isLoadingPosts,
    String? postsError,
  ) {
    if (isLoadingPosts) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 64),
            child: Column(
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8BC342)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading posts...',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (postsError != null) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 64),
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  'Failed to load posts',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  postsError,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _cubit.loadUserPosts(widget.userName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8BC342),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (posts == null || posts.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 64),
            child: Column(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No posts yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Share your first bowling experience!',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: FeedPostCard(post: posts[index], postIndex: index),
        );
      },
    );
  }

  Widget _buildVideoPlayer(String videoUrl) {
    // Initialize video controller if not already done
    if (_videoController == null || _videoController!.dataSource != videoUrl) {
      _initializeVideoPlayer(videoUrl);
    }

    return Container(
      color: Colors.black,
      child: _videoController != null && _videoController!.value.isInitialized
          ? Stack(
              fit: StackFit.expand,
              children: [
                AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
                // Dark overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                ),
                // Play/Pause button
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_videoController!.value.isPlaying) {
                          _videoController!.pause();
                        } else {
                          _videoController!.play();
                        }
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _videoController!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Loading Video...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
