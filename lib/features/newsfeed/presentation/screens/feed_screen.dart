import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../domain/entities/post.dart';
import '../bloc/feed_bloc.dart';
import '../widgets/create_post_composer.dart';
import '../widgets/post_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FeedBloc>(
      create: (_) => getIt<FeedBloc>()..add(const FeedLoadRequested()),
      child: const _FeedView(),
    );
  }
}

class _FeedView extends StatefulWidget {
  const _FeedView();

  @override
  State<_FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<_FeedView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    final cur = _scrollController.position.pixels;
    if (cur >= max - 600) {
      final bloc = context.read<FeedBloc>();
      if (bloc.state.hasMore && !bloc.state.loadingMore) {
        bloc.add(const FeedNextPageRequested());
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.navNewsfeed),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search, size: 20),
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        bottom: const _FilterBar(),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<FeedBloc, FeedState>(
          builder: (context, state) {
            if (state.loading) return const _FeedSkeleton();

            return RefreshIndicator(
              color: colors.accent,
              onRefresh: () async {
                context.read<FeedBloc>().add(const FeedRefreshRequested());
                await context
                    .read<FeedBloc>()
                    .stream
                    .firstWhere((s) => !s.refreshing);
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base,
                      AppSpacing.base,
                      AppSpacing.base,
                      AppSpacing.md,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _buildComposer(context),
                    ),
                  ),
                  if (state.posts.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: LucideIcons.newspaper,
                        title: l10n.commonEmptyListTitle,
                        hint: state.errors.isNotEmpty
                            ? state.errors.join('\n')
                            : 'Follow people to see posts here.',
                        action: AppButton(
                          label: l10n.actionRetry,
                          onPressed: () => context
                              .read<FeedBloc>()
                              .add(const FeedRefreshRequested()),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base,
                      ),
                      sliver: SliverList.separated(
                        itemCount:
                            state.posts.length + (state.hasMore ? 1 : 0),
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.base),
                        itemBuilder: (context, index) {
                          if (index >= state.posts.length) {
                            return Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.accent,
                                  ),
                                ),
                              ),
                            );
                          }
                          final post = state.posts[index];
                          return PostCard(
                            post: post,
                            onReact: (r) => context.read<FeedBloc>().add(
                                  FeedReactionToggled(
                                    postUid: post.uid,
                                    reaction: r,
                                  ),
                                ),
                            onComment: () {},
                            onSave: () => context
                                .read<FeedBloc>()
                                .add(FeedSaveToggled(postUid: post.uid)),
                            onShare: () {},
                            onMore: () => _showMoreMenu(context, post),
                          );
                        },
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.xl),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildComposer(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        final profile = profileState.profile;
        return CreatePostComposer(
          currentAvatarUrl: profile?.profilePictureUrl,
          currentInitial: profile?.user.displayName ?? '?',
          onOpenText: () {},
          onOpenPhoto: () {},
          onOpenVideo: () {},
          onOpenScore: () {},
          onOpenPoll: () {},
        );
      },
    );
  }

  void _showMoreMenu(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        final colors = sheetCtx.colors;
        return SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: colors.bgSurfaceElevated,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    LucideIcons.eyeOff,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                  title: Text(
                    'Hide from my feed',
                    style: AppTextStyles.body
                        .copyWith(color: colors.textPrimary),
                  ),
                  onTap: () {
                    Navigator.of(sheetCtx).pop();
                    context
                        .read<FeedBloc>()
                        .add(FeedPostHidden(postUid: post.uid));
                  },
                ),
                ListTile(
                  leading: Icon(LucideIcons.flag, size: 18, color: colors.error),
                  title: Text(
                    'Report post',
                    style:
                        AppTextStyles.body.copyWith(color: colors.error),
                  ),
                  onTap: () => Navigator.of(sheetCtx).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _FilterBar extends StatelessWidget implements PreferredSizeWidget {
  const _FilterBar();

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.borderDefault)),
      ),
      child: BlocBuilder<FeedBloc, FeedState>(
        buildWhen: (p, n) => p.filter != n.filter,
        builder: (context, state) {
          return ListView(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            children: [
              _chip(context,
                  label: 'All', active: state.filter == null, filter: null),
              _chip(context,
                  label: 'Following',
                  active: state.filter == 'following',
                  filter: 'following'),
              _chip(context,
                  label: 'Scores',
                  active: state.filter == 'scores',
                  filter: 'scores'),
              _chip(context,
                  label: 'Polls',
                  active: state.filter == 'polls',
                  filter: 'polls'),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(BuildContext context,
      {required String label, required bool active, required String? filter}) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppRadius.fullAll,
            onTap: () => context
                .read<FeedBloc>()
                .add(FeedFilterChanged(filter: filter)),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: active
                    ? colors.accent.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: AppRadius.fullAll,
                border: Border.all(
                  color: active ? colors.accent : colors.borderDefault,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: active ? colors.accent : colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, _) => const SkeletonCard(height: 240),
    );
  }
}
