import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/network_badge.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/chatter.dart';
import '../../domain/repositories/chatter_repository.dart';
import '../bloc/discussion_detail_bloc.dart';

/// /chatter/:uid — full discussion view with opinion thread + composer.
/// Tap an upvote arrow to optimistically toggle. Type a comment and hit
/// Post to prepend a new opinion to the list.
class DiscussionDetailScreen extends StatelessWidget {
  const DiscussionDetailScreen({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DiscussionDetailBloc>(
      create: (_) => DiscussionDetailBloc(
        repository: getIt<ChatterRepository>(),
        uid: uid,
      )..add(const DiscussionDetailLoadRequested()),
      child: const _DetailView(),
    );
  }
}

class _DetailView extends StatefulWidget {
  const _DetailView();
  @override
  State<_DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<_DetailView> {
  final _scroll = ScrollController();
  final _composer = TextEditingController();
  final _composerFocus = FocusNode();
  bool _composerHasText = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _composer.addListener(_onComposerChanged);
  }

  void _onComposerChanged() {
    final hasText = _composer.text.trim().isNotEmpty;
    if (hasText != _composerHasText) {
      setState(() => _composerHasText = hasText);
    }
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final remaining = _scroll.position.maxScrollExtent - _scroll.position.pixels;
    if (remaining < 600) {
      context
          .read<DiscussionDetailBloc>()
          .add(const DiscussionDetailOpinionsNextPageRequested());
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _composer.removeListener(_onComposerChanged);
    _composer.dispose();
    _composerFocus.dispose();
    super.dispose();
  }

  void _submitOpinion() {
    final body = _composer.text.trim();
    if (body.isEmpty) return;
    context
        .read<DiscussionDetailBloc>()
        .add(DiscussionDetailOpinionPosted(body: body));
    _composer.clear();
    _composerFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        title: const Text('Discussion'),
        leading: const AppBackButton(),
      ),
      body: BlocConsumer<DiscussionDetailBloc, DiscussionDetailState>(
        listenWhen: (p, n) => p.errors != n.errors && n.errors.isNotEmpty,
        listener: (context, state) {
          showAppToast(
            context,
            message: state.errors.join('\n'),
            variant: ToastVariant.error,
          );
        },
        builder: (context, state) {
          if (state.loading && state.discussion == null) {
            return const _DetailSkeleton();
          }
          final discussion = state.discussion;
          if (discussion == null) {
            return Center(
              child: EmptyState(
                icon: LucideIcons.messageSquareX,
                title: 'Discussion not found',
                hint: state.errors.isNotEmpty ? state.errors.join('\n') : null,
                action: AppButton(
                  label: 'Retry',
                  onPressed: () => context
                      .read<DiscussionDetailBloc>()
                      .add(const DiscussionDetailLoadRequested()),
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: colors.accent,
                  onRefresh: () async {
                    context
                        .read<DiscussionDetailBloc>()
                        .add(const DiscussionDetailRefreshRequested());
                    await context
                        .read<DiscussionDetailBloc>()
                        .stream
                        .firstWhere((s) => !s.refreshing);
                  },
                  child: CustomScrollView(
                    controller: _scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _Header(
                          discussion: discussion,
                          upvoteBusy: state.upvoteBusy,
                          onUpvote: () => context
                              .read<DiscussionDetailBloc>()
                              .add(const DiscussionDetailUpvoteToggled()),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _OpinionsHeader(
                          count: discussion.opinionCount,
                          sort: state.opinionSort,
                          onPick: (s) => context
                              .read<DiscussionDetailBloc>()
                              .add(DiscussionDetailOpinionSortChanged(s)),
                        ),
                      ),
                      if (state.opinionsLoading && state.opinions.isEmpty)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            child: Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                        )
                      else if (state.opinions.isEmpty)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.xl),
                            child: Center(
                              child: Text(
                                'No opinions yet — be the first to share one.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.base,
                            0,
                            AppSpacing.base,
                            AppSpacing.xl,
                          ),
                          sliver: SliverList.separated(
                            itemCount: state.opinions.length +
                                (state.opinionsLoadingMore ? 1 : 0),
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (_, i) {
                              if (i >= state.opinions.length) {
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
                              final o = state.opinions[i];
                              return _OpinionCard(
                                opinion: o,
                                busy: state.opinionUpvoteBusyIds.contains(o.id),
                                onUpvote: () => context
                                    .read<DiscussionDetailBloc>()
                                    .add(DiscussionDetailOpinionUpvoteToggled(
                                        o.id)),
                                onAuthorTap: o.author == null
                                    ? null
                                    : () => context.push(
                                        '/u/${o.author!.username}'),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              _Composer(
                controller: _composer,
                focusNode: _composerFocus,
                posting: state.posting,
                canSubmit: _composerHasText && !state.posting,
                locked: discussion.isLocked,
                onSubmit: _submitOpinion,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header — author, topic, title, body, tags, action bar.
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({
    required this.discussion,
    required this.upvoteBusy,
    required this.onUpvote,
  });

  final Discussion discussion;
  final bool upvoteBusy;
  final VoidCallback onUpvote;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final author = discussion.author;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.sm,
      ),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badges row (topic + resolved / locked)
            Row(
              children: [
                if (discussion.topic != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.accentSubtle,
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Text(
                      discussion.topic!.name,
                      style: AppTextStyles.nano.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                if (discussion.isResolved) ...[
                  const SizedBox(width: 6),
                  _PillBadge(
                    icon: LucideIcons.circleCheck,
                    label: 'Resolved',
                    tint: colors.success,
                  ),
                ],
                if (discussion.isLocked) ...[
                  const SizedBox(width: 6),
                  _PillBadge(
                    icon: LucideIcons.lock,
                    label: 'Locked',
                    tint: colors.textTertiary,
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              discussion.title,
              style: AppTextStyles.pageTitle.copyWith(
                color: colors.textPrimary,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (author != null)
              InkWell(
                onTap: () => context.push('/u/${author.username}'),
                borderRadius: AppRadius.smAll,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      _Avatar(author: author, size: 32),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          author.displayName,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (author.badgeIconUrl != null) ...[
                        const SizedBox(width: 4),
                        NetworkBadge(url: author.badgeIconUrl, size: 14),
                      ],
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _relativeTime(discussion.createdAt),
                        style: AppTextStyles.nano.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (discussion.body.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                discussion.body,
                style: AppTextStyles.body.copyWith(
                  color: colors.textPrimary,
                  height: 1.5,
                ),
              ),
            ],
            if (discussion.tags.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final tag in discussion.tags)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.bgSurfaceHover,
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.hash,
                              size: 11, color: colors.textTertiary),
                          const SizedBox(width: 2),
                          Text(
                            tag,
                            style: AppTextStyles.nano.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            // Action bar: upvote button (with count) + view count.
            Row(
              children: [
                _UpvoteButton(
                  active: discussion.hasUpvoted == true,
                  count: discussion.upvoteCount,
                  busy: upvoteBusy,
                  onTap: discussion.isMine == true ? null : onUpvote,
                ),
                const SizedBox(width: AppSpacing.md),
                Icon(LucideIcons.messageCircle,
                    size: 13, color: colors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  '${discussion.opinionCount}',
                  style: AppTextStyles.nano.copyWith(
                    color: colors.textTertiary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Icon(LucideIcons.eye, size: 13, color: colors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  '${discussion.viewCount}',
                  style: AppTextStyles.nano.copyWith(
                    color: colors.textTertiary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UpvoteButton extends StatelessWidget {
  const _UpvoteButton({
    required this.active,
    required this.count,
    required this.busy,
    this.onTap,
  });

  final bool active;
  final int count;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final disabled = onTap == null || busy;
    return Material(
      color: active ? colors.accent.withValues(alpha: 0.12) : colors.bgSurface,
      borderRadius: AppRadius.fullAll,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: AppRadius.fullAll,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: AppRadius.fullAll,
            border: Border.all(
              color: active ? colors.accent : colors.borderDefault,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.chevronUp,
                size: 14,
                color: active ? colors.accent : colors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: AppTextStyles.bodySmall.copyWith(
                  color: active ? colors.accent : colors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({
    required this.icon,
    required this.label,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: AppRadius.smAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: tint),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTextStyles.nano.copyWith(
              color: tint,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Opinions
// ─────────────────────────────────────────────────────────────────────────────
class _OpinionsHeader extends StatelessWidget {
  const _OpinionsHeader({
    required this.count,
    required this.sort,
    required this.onPick,
  });

  final int count;
  final OpinionSort sort;
  final ValueChanged<OpinionSort> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.md,
        AppSpacing.base,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            'Opinions ($count)',
            style: AppTextStyles.sectionTitle.copyWith(
              color: colors.textPrimary,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          for (final s in OpinionSort.values) ...[
            _SortPill(
              label: s.label,
              active: s == sort,
              onTap: () => onPick(s),
            ),
            if (s != OpinionSort.values.last) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _SortPill extends StatelessWidget {
  const _SortPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: active ? colors.accent.withValues(alpha: 0.12) : Colors.transparent,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            label,
            style: AppTextStyles.nano.copyWith(
              color: active ? colors.accent : colors.textTertiary,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _OpinionCard extends StatelessWidget {
  const _OpinionCard({
    required this.opinion,
    required this.busy,
    required this.onUpvote,
    this.onAuthorTap,
  });

  final Opinion opinion;
  final bool busy;
  final VoidCallback onUpvote;
  final VoidCallback? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final author = opinion.author;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onAuthorTap,
                child: _Avatar(author: author, size: 28),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (author != null)
                Flexible(
                  child: InkWell(
                    onTap: onAuthorTap,
                    child: Text(
                      author.displayName,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (opinion.isAcknowledged) ...[
                const SizedBox(width: 6),
                Icon(LucideIcons.badgeCheck,
                    size: 12, color: colors.success),
              ],
              const Spacer(),
              Text(
                _relativeTime(opinion.createdAt),
                style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            opinion.body,
            style: AppTextStyles.body.copyWith(
              color: colors.textPrimary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _UpvoteButton(
                active: opinion.hasUpvoted == true,
                count: opinion.upvoteCount,
                busy: busy,
                onTap: opinion.isMine == true ? null : onUpvote,
              ),
              if (opinion.replyCount > 0) ...[
                const SizedBox(width: AppSpacing.md),
                Icon(LucideIcons.cornerDownRight,
                    size: 13, color: colors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  '${opinion.replyCount} ${opinion.replyCount == 1 ? 'reply' : 'replies'}',
                  style: AppTextStyles.nano.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Composer
// ─────────────────────────────────────────────────────────────────────────────
class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.posting,
    required this.canSubmit,
    required this.locked,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool posting;
  final bool canSubmit;
  final bool locked;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (locked) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.bgSurface,
          border: Border(top: BorderSide(color: colors.borderDefault)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Icon(LucideIcons.lock, size: 14, color: colors.textTertiary),
              const SizedBox(width: 6),
              Text(
                'This discussion is locked.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: colors.textTertiary),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        border: Border(top: BorderSide(color: colors.borderDefault)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: colors.bgPrimary,
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(color: colors.borderDefault),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                  style: AppTextStyles.body
                      .copyWith(color: colors.textPrimary, fontSize: 14),
                  cursorColor: colors.accent,
                  decoration: InputDecoration(
                    hintText: 'Share your opinion…',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: colors.textTertiary,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppButton(
              label: 'Post',
              icon: LucideIcons.send,
              size: AppButtonSize.regular,
              loading: posting,
              onPressed: canSubmit ? onSubmit : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared bits
// ─────────────────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  const _Avatar({required this.author, required this.size});
  final ChatterAuthor? author;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = (author?.firstName.isNotEmpty ?? false)
        ? author!.firstName.substring(0, 1).toUpperCase()
        : (author?.username.isNotEmpty ?? false)
            ? author!.username.substring(0, 1).toUpperCase()
            : '?';
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accentSubtle,
        border: Border.all(color: colors.borderStrong),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.nano.copyWith(
          color: colors.accent,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.4,
        ),
      ),
    );
    final url = author?.profilePictureUrl;
    if (url == null || url.isEmpty) return placeholder;
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, _) => placeholder,
          errorWidget: (_, _, _) => placeholder,
        ),
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.base),
      children: const [
        SkeletonBox(height: 28),
        SizedBox(height: AppSpacing.sm),
        SkeletonBox(height: 24),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 80),
        SizedBox(height: AppSpacing.lg),
        SkeletonBox(height: 60),
        SizedBox(height: AppSpacing.sm),
        SkeletonBox(height: 60),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
String _relativeTime(DateTime? when) {
  if (when == null) return '';
  final diff = DateTime.now().toUtc().difference(when.toUtc());
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo';
  return '${(diff.inDays / 365).floor()}y';
}
