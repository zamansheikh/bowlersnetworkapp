import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../cubit/feed_v3_cubit.dart';
import '../widgets/create_post_section.dart';
import '../widgets/feed_v3_post_card.dart';
import '../../data/models/feed_v3_post.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load feed on init
    context.read<FeedV3Cubit>().loadFeed();
    // Infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<FeedV3Cubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: const AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => context.read<FeedV3Cubit>().refresh(),
            color: AppColors.primaryLimeGreen,
            child: CustomScrollView(
              controller: _scrollController,
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
                      icon: SvgPicture.asset(
                        'assets/icons/menu.svg',
                        height: 24.h,
                        width: 24.w,
                      ),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: Image.asset(
                          'assets/icon/icon.png',
                          width: 24.w,
                          height: 24.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Bowlers Network',
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                // Create Post Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        SizedBox(height: 32.h),
                        const CreatePostSection(),
                        SizedBox(height: 12.h),
                      ],
                    ),
                  ),
                ),

                // FeedV3 Content
                BlocBuilder<FeedV3Cubit, FeedV3State>(
                  builder: (context, state) {
                    if (state is FeedV3Loading) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryLimeGreen,
                          ),
                        ),
                      );
                    }

                    if (state is FeedV3Error) {
                      return SliverFillRemaining(
                        child: _buildErrorWidget(state.message, context),
                      );
                    }

                    if (state is FeedV3Loaded) {
                      if (state.posts.isEmpty) {
                        return const SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.article_outlined,
                                  size: 64,
                                  color: AppColors.gray400,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No posts yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Be the first to share something!',
                                  style: TextStyle(color: AppColors.gray500),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          // Loading more indicator
                          if (index == state.posts.length) {
                            return state.isLoadingMore
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primaryLimeGreen,
                                      ),
                                    ),
                                  )
                                : const SizedBox(height: 32);
                          }

                          final post = state.posts[index];
                          return FeedV3PostCard(
                            post: post,
                            onTap: () => context.push('/post/${post.id}'),
                            onLike: () =>
                                context.read<FeedV3Cubit>().toggleLike(post.id),
                            onPollVote: (optionId) => context
                                .read<FeedV3Cubit>()
                                .voteOnPoll(post.id, [optionId]),
                            onComment: () => context.push('/post/${post.id}'),
                          );
                        }, childCount: state.posts.length + 1),
                      );
                    }

                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message, BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64.w, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(color: AppColors.gray500, fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => context.read<FeedV3Cubit>().loadFeed(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLimeGreen,
                foregroundColor: AppColors.black,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
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
}
