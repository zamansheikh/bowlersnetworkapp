import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bn_error_widget.dart';
import '../../../../core/widgets/bn_loading_indicator.dart';
import '../../../../core/widgets/bn_shimmer.dart';
import '../bloc/feed_bloc.dart';
import '../widgets/post_card.dart';

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  late final FeedBloc _feedBloc;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _feedBloc = getIt<FeedBloc>()..add(const FeedLoadRequested());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _feedBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      _feedBloc.add(const FeedLoadMoreRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _feedBloc,
      child: Scaffold(
        backgroundColor: AppColors.bgLightGray,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(AssetPaths.splashLogo, width: 28, height: 28),
              const SizedBox(width: 8),
              Text('BowlersNetwork', style: AppTextStyles.h4.copyWith(color: AppColors.primary)),
            ],
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
              onPressed: () {}, // TODO: Navigate to search
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
              onPressed: () {}, // TODO: Navigate to notifications
            ),
          ],
        ),
        body: BlocBuilder<FeedBloc, FeedState>(
          builder: (context, state) {
            if (state.status == FeedStatus.loading) {
              return _buildShimmer();
            }
            if (state.status == FeedStatus.error && state.posts.isEmpty) {
              return BnErrorWidget(
                message: state.errorMessage ?? 'Failed to load feed',
                onRetry: () => _feedBloc.add(const FeedLoadRequested()),
              );
            }
            if (state.posts.isEmpty && state.status == FeedStatus.loaded) {
              return _buildEmptyFeed();
            }

            return RefreshIndicator(
              onRefresh: () async => _feedBloc.add(const FeedRefreshRequested()),
              color: AppColors.primary,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.posts.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: BnLoadingIndicator(size: 24),
                    );
                  }
                  final post = state.posts[index];
                  return Column(
                    children: [
                      PostCard(
                        post: post,
                        onReact: (type) => _feedBloc.add(FeedReactRequested(postId: post.id, reactionType: type)),
                        onSave: () => _feedBloc.add(FeedSaveToggled(postId: post.id)),
                        onMore: () => _showPostOptions(context, post),
                      ),
                      if (index < state.posts.length - 1)
                        const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final created = await context.push<bool>('/create-post');
            if (created == true) _feedBloc.add(const FeedRefreshRequested());
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return BnShimmer(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (_, _) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [ShimmerCircle(size: 40), SizedBox(width: 12), Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [ShimmerBox(width: 120, height: 14), SizedBox(height: 6), ShimmerBox(width: 80, height: 10)],
              )]),
              SizedBox(height: 12),
              ShimmerBox(height: 14),
              SizedBox(height: 6),
              ShimmerBox(height: 14, width: 200),
              SizedBox(height: 12),
              ShimmerBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyFeed() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.dynamic_feed_outlined, size: 80, color: AppColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('Your feed is empty', style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('Follow bowlers to see their posts here', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  void _showPostOptions(BuildContext context, dynamic post) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (post.isMine)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Delete Post'),
                onTap: () {
                  Navigator.pop(context);
                  _feedBloc.add(FeedPostDeleted(postId: post.id));
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.visibility_off_outlined),
                title: const Text('Hide Post'),
                onTap: () {
                  Navigator.pop(context);
                  _feedBloc.add(FeedPostHidden(postId: post.id));
                },
              ),
          ],
        ),
      ),
    );
  }
}
