import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../newsfeed/domain/repositories/newsfeed_repository.dart';
import '../../../newsfeed/presentation/widgets/comments_sheet.dart';
import '../../../newsfeed/presentation/widgets/post_card.dart';
import '../bloc/user_posts_bloc.dart';

/// Posts tab for either the self-profile or the other-user profile.
///
/// Builds its own [UserPostsBloc] keyed by [userId] — pass `isSelf` so
/// the bloc picks `/api/newsfeed/my-posts` (which includes private
/// posts the owner can see) over the public user-scoped endpoint.
///
/// Renders cards with the existing newsfeed [PostCard] so visuals stay
/// in sync with the main feed.
class PostsTab extends StatelessWidget {
  const PostsTab({
    super.key,
    required this.userId,
    required this.isSelf,
  });

  final int userId;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserPostsBloc>(
      // Keyed so switching between profiles spins up a fresh bloc.
      key: ValueKey('posts-tab-$userId-$isSelf'),
      create: (_) => UserPostsBloc(
        repository: getIt<NewsfeedRepository>(),
        isSelf: isSelf,
        userId: userId,
      )..add(const UserPostsLoadRequested()),
      child: _PostsTabView(isSelf: isSelf),
    );
  }
}

class _PostsTabView extends StatefulWidget {
  const _PostsTabView({required this.isSelf});
  final bool isSelf;

  @override
  State<_PostsTabView> createState() => _PostsTabViewState();
}

class _PostsTabViewState extends State<_PostsTabView> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final remaining =
        _scroll.position.maxScrollExtent - _scroll.position.pixels;
    if (remaining < 800) {
      context.read<UserPostsBloc>().add(const UserPostsNextPageRequested());
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocConsumer<UserPostsBloc, UserPostsState>(
      listenWhen: (p, n) => p.errors != n.errors && n.errors.isNotEmpty,
      listener: (context, state) {
        showAppToast(
          context,
          message: state.errors.join('\n'),
          variant: ToastVariant.error,
        );
      },
      builder: (context, state) {
        if (state.loading && state.posts.isEmpty) {
          return const _PostsSkeleton();
        }
        if (state.posts.isEmpty) {
          return EmptyState(
            icon: LucideIcons.newspaper,
            title: 'No posts yet',
            hint: widget.isSelf
                ? 'Posts you create on the Newsfeed will show up here.'
                : 'No public posts to show.',
          );
        }
        return RefreshIndicator(
          color: colors.accent,
          onRefresh: () async {
            context
                .read<UserPostsBloc>()
                .add(const UserPostsRefreshRequested());
            await context
                .read<UserPostsBloc>()
                .stream
                .firstWhere((s) => !s.refreshing);
          },
          child: ListView.separated(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            // Profile is a CustomScrollView — this tab sits inside a
            // SliverToBoxAdapter so it needs an explicit shrinkWrap to
            // size itself. But because we use a proper scroll controller
            // here the parent shouldn't intercept; the parent wraps us in
            // a bounded SizedBox so this controller actually scrolls.
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            itemCount:
                state.posts.length + (state.loadingMore ? 1 : 0),
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, i) {
              if (i >= state.posts.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.accent,
                      ),
                    ),
                  ),
                );
              }
              final post = state.posts[i];
              return PostCard(
                post: post,
                onReact: (r) => context.read<UserPostsBloc>().add(
                      UserPostsReactionToggled(
                        postUid: post.uid,
                        reaction: r,
                      ),
                    ),
                onComment: () => showCommentsSheet(
                  context,
                  postUid: post.uid,
                  isPostAuthor: post.isMine,
                ),
                onSave: () => context.read<UserPostsBloc>().add(
                      UserPostsSaveToggled(postUid: post.uid),
                    ),
                onShare: () => _comingSoon(context, 'Reposting from the profile'),
                onMore: () => _comingSoon(context, 'Post options'),
                onFollow: () => _comingSoon(context, 'Follow from a post'),
                onAuthorTap: post.author.username.isEmpty
                    ? null
                    : () => context.push(
                          '/u/${post.author.username}',
                        ),
              );
            },
          ),
        );
      },
    );
  }

  void _comingSoon(BuildContext context, String label) {
    showAppToast(
      context,
      message: '$label is available from the main Newsfeed for now.',
      variant: ToastVariant.info,
    );
  }
}

class _PostsSkeleton extends StatelessWidget {
  const _PostsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, _) => const SkeletonBox(height: 240),
    );
  }
}
