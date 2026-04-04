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
import '../../../shell/presentation/widgets/app_drawer.dart';
import '../../data/models/post_models.dart';
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
        drawer: const AppDrawer(),
        appBar: AppBar(
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
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
            IconButton(icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary), onPressed: () {}),
            IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary), onPressed: () {}),
          ],
        ),
        body: BlocBuilder<FeedBloc, FeedState>(
          builder: (context, state) {
            if (state.status == FeedStatus.loading) return _buildShimmer();
            if (state.status == FeedStatus.error && state.posts.isEmpty) {
              return BnErrorWidget(
                message: state.errorMessage ?? 'Failed to load feed',
                onRetry: () => _feedBloc.add(const FeedLoadRequested()),
              );
            }
            if (state.posts.isEmpty && state.status == FeedStatus.loaded) return _buildEmptyFeed();

            return RefreshIndicator(
              onRefresh: () async => _feedBloc.add(const FeedRefreshRequested()),
              color: AppColors.primary,
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 8),
                itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index == state.posts.length) {
                    return const Padding(padding: EdgeInsets.all(16), child: BnLoadingIndicator(size: 24));
                  }
                  final post = state.posts[index];
                  return PostCard(
                    post: post,
                    onReact: (type) => _feedBloc.add(FeedReactRequested(postId: post.id, reactionType: type)),
                    onSave: () => _feedBloc.add(FeedSaveToggled(postId: post.id)),
                    onMore: () => _showPostOptions(context, post),
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
          elevation: 4,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return BnShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, _) => Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ShimmerCircle(size: 42),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 130, height: 12, borderRadius: 6),
                      const SizedBox(height: 6),
                      ShimmerBox(width: 80, height: 10, borderRadius: 5),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ShimmerBox(height: 12, borderRadius: 6),
              const SizedBox(height: 6),
              ShimmerBox(width: 220, height: 12, borderRadius: 6),
              const SizedBox(height: 14),
              ShimmerBox(height: 200, borderRadius: 12),
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
          Icon(Icons.dynamic_feed_outlined, size: 72, color: AppColors.textMuted.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('Your feed is empty', style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text('Follow bowlers to see their posts here', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  void _showPostOptions(BuildContext context, PostModel post) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.borderMedium, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              if (post.isMine)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.error),
                  title: const Text('Delete Post'),
                  onTap: () { Navigator.pop(context); _feedBloc.add(FeedPostDeleted(postId: post.id)); },
                )
              else
                ListTile(
                  leading: const Icon(Icons.visibility_off_outlined),
                  title: const Text('Hide Post'),
                  onTap: () { Navigator.pop(context); _feedBloc.add(FeedPostHidden(postId: post.id)); },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
