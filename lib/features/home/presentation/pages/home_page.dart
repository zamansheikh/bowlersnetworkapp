import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../cubit/feed_cubit.dart';
import '../widgets/create_post_section.dart';
import '../widgets/feed_post_card.dart';
import '../../data/models/feed_post.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Ensure we're in proper feed state when returning to home
    final feedCubit = context.read<FeedCubit>();
    feedCubit.returnToFeed();
  }

  @override
  Widget build(BuildContext context) {
    return const HomePageView();
  }
}

class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: const AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<FeedCubit>().refreshFeed();
            },
            color: AppColors.primaryLimeGreen,
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: AppColors.white,
                  elevation: 0,
                  scrolledUnderElevation: 1,
                  surfaceTintColor: AppColors.white,
                  floating: true,
                  snap: true,
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: AppColors.black),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  title: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: Image.asset(
                          'assets/icon/icon.png',
                          width: 28.w,
                          height: 28.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Bowlers Network',
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(height: 16.h),

                      // Create Post Section
                      const CreatePostSection(),

                      SizedBox(height: 16.h),

                      // Feed Content
                      BlocConsumer<FeedCubit, FeedState>(
                        listener: (context, state) {
                          if (state is PostCreateSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Post created successfully!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          } else if (state is PostCreateError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to create post: ${state.message}',
                                ),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          if (state is FeedLoading) {
                            return _buildLoadingWidget();
                          } else if (state is FeedError) {
                            return _buildErrorWidget(state.message, context);
                          } else if (state is FeedLoaded ||
                              state is FeedRefreshing ||
                              state is PostCreating ||
                              state is PostCreateSuccess ||
                              state is PostCreateError) {
                            List<FeedPost> posts = [];
                            bool isCreating = false;

                            if (state is FeedLoaded) {
                              posts = state.posts;
                            } else if (state is FeedRefreshing) {
                              posts = state.posts;
                            } else if (state is PostCreating) {
                              posts = state.posts;
                              isCreating = true;
                            } else if (state is PostCreateSuccess) {
                              posts = state.posts;
                            } else if (state is PostCreateError) {
                              posts = state.posts;
                            }

                            return _buildFeedContent(posts, isCreating);
                          }

                          return _buildEmptyWidget();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 60.h),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryLimeGreen,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Loading feed...',
              style: TextStyle(color: AppColors.gray, fontSize: 16.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 64.w, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(color: AppColors.gray, fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                context.read<FeedCubit>().loadFeed();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLimeGreen,
                foregroundColor: AppColors.black,
                padding: EdgeInsets.symmetric(
                  horizontal: 32.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.article_outlined, size: 64, color: AppColors.gray),
            SizedBox(height: 16),
            Text(
              'No posts yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Be the first to share something!',
              style: TextStyle(color: AppColors.gray, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedContent(List<FeedPost> posts, bool isCreating) {
    if (posts.isEmpty) {
      return _buildEmptyWidget();
    }

    return Column(
      children: [
        // Show creating indicator
        if (isCreating)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Creating your post...',
                  style: TextStyle(
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        // Posts list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FeedPostCard(
                post: posts[index],
                postIndex: index,
                onPostUpdate: () {
                  context.read<FeedCubit>().loadFeed();
                },
              ),
            );
          },
        ),

        // Bottom spacing
        const SizedBox(height: 24),
      ],
    );
  }
}
