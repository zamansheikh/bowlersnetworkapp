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
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/live_viewer.dart';
import '../bloc/live_detail_bloc.dart';

/// /live/:uid — full broadcast viewer. WebSocket-driven; sections:
///   1. Broadcaster header chip + LIVE/ENDED badge + viewer count
///   2. Multi-game scoreboard (tab strip if >1 game)
///   3. Reaction summary bar + emoji picker
///   4. Comments rail with composer
class LiveDetailScreen extends StatelessWidget {
  const LiveDetailScreen({super.key, required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LiveDetailBloc>(
      create: (_) =>
          getIt<LiveDetailBloc>()..add(LiveDetailOpened(uid)),
      child: const _LiveDetailView(),
    );
  }
}

class _LiveDetailView extends StatelessWidget {
  const _LiveDetailView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        title: const Text('Live'),
        leading: const AppBackButton(fallbackRoute: '/live'),
      ),
      body: BlocConsumer<LiveDetailBloc, LiveDetailState>(
        listenWhen: (p, n) => p.errors != n.errors && n.errors.isNotEmpty,
        listener: (context, state) {
          showAppToast(
            context,
            message: state.errors.join('\n'),
            variant: ToastVariant.error,
          );
        },
        builder: (context, state) {
          if (state.loading && state.detail == null) {
            return const _Skeleton();
          }
          final detail = state.detail;
          if (detail == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Text("Couldn't load this broadcast."),
              ),
            );
          }
          return _LoadedBody(state: state, detail: detail);
        },
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.state, required this.detail});
  final LiveDetailState state;
  final LiveBroadcastDetail detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: colors.accent,
            onRefresh: () async {
              context
                  .read<LiveDetailBloc>()
                  .add(const LiveDetailRefreshRequested());
              await context
                  .read<LiveDetailBloc>()
                  .stream
                  .firstWhere((s) => !s.refreshing);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.sm,
                AppSpacing.base,
                AppSpacing.md,
              ),
              children: [
                _Header(detail: detail),
                if (!detail.isActive) ...[
                  const SizedBox(height: AppSpacing.md),
                  _EndedBanner(detail: detail),
                ],
                const SizedBox(height: AppSpacing.md),
                if (detail.session.games.isEmpty)
                  _EmptyScoreboard(active: detail.isActive)
                else
                  _ScoreboardCard(games: detail.session.games),
                const SizedBox(height: AppSpacing.md),
                _ReactionsCard(detail: detail),
                const SizedBox(height: AppSpacing.md),
                _CommentsSection(
                  comments: state.comments,
                  hasMore: state.hasMoreComments,
                  loadingMore: state.loadingMoreComments,
                  isActive: detail.isActive,
                ),
              ],
            ),
          ),
        ),
        if (detail.isActive)
          SafeArea(
            top: false,
            child: _Composer(busy: state.postingComment),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header (broadcaster + LIVE badge + viewer count)
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.detail});
  final LiveBroadcastDetail detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final user = detail.user;
    return Material(
      color: colors.bgSurface,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Avatar(user: user, size: 44),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: user == null
                            ? null
                            : () =>
                                context.push('/u/${user.username}'),
                        child: Text(
                          user?.displayName ?? 'Someone',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (user?.username != null)
                        Text(
                          '@${user!.username}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.nano.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (detail.isActive) const _LiveBadge() else const _EndedBadge(),
              ],
            ),
            if (detail.title.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                detail.title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _HeaderStat(
                  icon: LucideIcons.users,
                  label: '${detail.viewerCount}',
                  hint: 'watching',
                ),
                const SizedBox(width: AppSpacing.md),
                _HeaderStat(
                  icon: LucideIcons.heart,
                  label: '${detail.reactionsCount}',
                  hint: 'reactions',
                ),
                const SizedBox(width: AppSpacing.md),
                _HeaderStat(
                  icon: LucideIcons.messageCircle,
                  label: '${detail.commentsCount}',
                  hint: 'comments',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.icon,
    required this.label,
    required this.hint,
  });
  final IconData icon;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: colors.textTertiary),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.nano.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 3),
        Text(
          hint,
          style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
        ),
      ],
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE11D48),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'LIVE',
            style: AppTextStyles.nano.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _EndedBadge extends StatelessWidget {
  const _EndedBadge();
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.bgSurfaceHover,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.borderStrong),
      ),
      child: Text(
        'ENDED',
        style: AppTextStyles.nano.copyWith(
          color: colors.textTertiary,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _EndedBanner extends StatelessWidget {
  const _EndedBanner({required this.detail});
  final LiveBroadcastDetail detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.bgSurfaceHover,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.circleOff, size: 16, color: colors.textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              detail.endReason.label,
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scoreboard
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyScoreboard extends StatelessWidget {
  const _EmptyScoreboard({required this.active});
  final bool active;
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.bgSurface,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Text(
            active
                ? 'Waiting for the first frame…'
                : 'No frames were bowled.',
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreboardCard extends StatefulWidget {
  const _ScoreboardCard({required this.games});
  final List<LiveGame> games;

  @override
  State<_ScoreboardCard> createState() => _ScoreboardCardState();
}

class _ScoreboardCardState extends State<_ScoreboardCard> {
  /// Game number the user explicitly tapped. Null = follow live (the
  /// first in-progress game, or the last game if all are complete).
  int? _pickedGameNumber;

  /// The "live" index = first in-progress game, falling back to the last
  /// game if everything's complete. Mirrors the web's
  /// `games.find(g => !g.is_complete) ?? games.at(-1)` selector.
  int _liveIndex() {
    final games = widget.games;
    if (games.isEmpty) return 0;
    final inProgress = games.indexWhere((g) => !g.isComplete);
    return inProgress >= 0 ? inProgress : games.length - 1;
  }

  int _displayIndex() {
    final picked = _pickedGameNumber;
    if (picked == null) return _liveIndex();
    final idx =
        widget.games.indexWhere((g) => g.gameNumber == picked);
    return idx >= 0 ? idx : _liveIndex();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activeIdx = _displayIndex();
    final game = widget.games[activeIdx];
    final liveIdx = _liveIndex();
    final viewingLive = activeIdx == liveIdx;
    return Material(
      color: colors.bgSurface,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.target, size: 14, color: colors.accent),
                const SizedBox(width: 6),
                Text(
                  'Scoreboard',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                if (!viewingLive)
                  TextButton(
                    onPressed: () =>
                        setState(() => _pickedGameNumber = null),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      'Jump to live',
                      style: AppTextStyles.nano.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else
                  Text(
                    game.isComplete ? 'Final' : 'Live',
                    style: AppTextStyles.nano.copyWith(
                      color: game.isComplete
                          ? colors.textTertiary
                          : colors.accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
            if (widget.games.length > 1) ...[
              const SizedBox(height: AppSpacing.sm),
              _GameTabs(
                games: widget.games,
                active: activeIdx,
                liveIndex: liveIdx,
                onPick: (i) => setState(() {
                  _pickedGameNumber = widget.games[i].gameNumber;
                }),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${game.totalScore}',
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: colors.textPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'game ${game.gameNumber}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textTertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _FrameStrip(frames: game.frames),
          ],
        ),
      ),
    );
  }
}

class _GameTabs extends StatelessWidget {
  const _GameTabs({
    required this.games,
    required this.active,
    required this.liveIndex,
    required this.onPick,
  });
  final List<LiveGame> games;
  final int active;

  /// Index of the game the broadcaster is currently bowling. Marked
  /// with a red pulse dot so viewers know which tab is the live one.
  final int liveIndex;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: games.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final selected = i == active;
          final isLive = i == liveIndex;
          return Material(
            color: selected
                ? colors.accent.withValues(alpha: 0.14)
                : colors.bgSurfaceHover,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => onPick(i),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLive) ...[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE11D48),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      'Game ${games[i].gameNumber}',
                      style: AppTextStyles.nano.copyWith(
                        color:
                            selected ? colors.accent : colors.textSecondary,
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Horizontal strip of all 10 frames. Each cell shows a small "X/-" mark
/// plus the running frame score. Empty frames render as placeholders.
class _FrameStrip extends StatelessWidget {
  const _FrameStrip({required this.frames});
  final List<LiveGameFrame> frames;

  @override
  Widget build(BuildContext context) {
    final byNumber = {for (final f in frames) f.frameNumber: f};
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int n = 1; n <= 10; n++)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _FrameCell(
                frameNumber: n,
                frame: byNumber[n],
              ),
            ),
        ],
      ),
    );
  }
}

class _FrameCell extends StatelessWidget {
  const _FrameCell({required this.frameNumber, this.frame});
  final int frameNumber;
  final LiveGameFrame? frame;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bowled = frame?.hasBeenBowled ?? false;
    final mark = _frameMark();
    return Container(
      width: 42,
      decoration: BoxDecoration(
        color: bowled ? colors.bgSurfaceHover : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: bowled ? colors.borderStrong : colors.borderDefault,
          width: bowled ? 1 : 0.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 2),
            alignment: Alignment.center,
            child: Text(
              '$frameNumber',
              style: AppTextStyles.nano.copyWith(
                color: colors.textTertiary,
                fontSize: 9,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 2),
            alignment: Alignment.center,
            child: Text(
              mark,
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 3),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bowled ? colors.bgSurface : Colors.transparent,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(5),
              ),
            ),
            child: Text(
              frame?.frameScore?.toString() ?? '—',
              style: AppTextStyles.nano.copyWith(
                color: colors.textSecondary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _frameMark() {
    final f = frame;
    if (f == null) return '·';
    if (f.isStrike) return 'X';
    if (f.isSpare) return '/';
    if (f.pinfall != null) return '${f.pinfall}';
    return '·';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reactions
// ─────────────────────────────────────────────────────────────────────────────

class _ReactionsCard extends StatelessWidget {
  const _ReactionsCard({required this.detail});
  final LiveBroadcastDetail detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.bgSurface,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.heart, size: 14, color: colors.accent),
                const SizedBox(width: 6),
                Text(
                  'Reactions',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                if (detail.myReaction != null && detail.isActive)
                  TextButton(
                    onPressed: () => context
                        .read<LiveDetailBloc>()
                        .add(const LiveReactionCleared()),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(
                      'Clear',
                      style: AppTextStyles.nano.copyWith(
                        color: colors.textTertiary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final r in LiveReactionType.values)
                  _ReactionButton(
                    type: r,
                    count: detail.reactionSummary[r.wire] ?? 0,
                    selected: detail.myReaction == r,
                    enabled: detail.isActive,
                    onTap: () => context
                        .read<LiveDetailBloc>()
                        .add(LiveReactionPicked(r)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({
    required this.type,
    required this.count,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final LiveReactionType type;
  final int count;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: selected
          ? colors.accent.withValues(alpha: 0.14)
          : colors.bgSurfaceHover,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: Container(
            constraints: const BoxConstraints(minWidth: 46),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(type.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 2),
                Text(
                  '$count',
                  style: AppTextStyles.nano.copyWith(
                    color: selected ? colors.accent : colors.textTertiary,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Comments
// ─────────────────────────────────────────────────────────────────────────────

class _CommentsSection extends StatelessWidget {
  const _CommentsSection({
    required this.comments,
    required this.hasMore,
    required this.loadingMore,
    required this.isActive,
  });

  final List<LiveBroadcastComment> comments;
  final bool hasMore;
  final bool loadingMore;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.bgSurface,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.messageCircle,
                    size: 14, color: colors.accent),
                const SizedBox(width: 6),
                Text(
                  'Comments',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (comments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  isActive
                      ? 'Be the first to comment.'
                      : 'No comments on this broadcast.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: colors.textTertiary),
                ),
              )
            else
              for (final c in comments)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _CommentRow(comment: c),
                ),
            if (hasMore) ...[
              const SizedBox(height: 4),
              Center(
                child: TextButton(
                  onPressed: loadingMore
                      ? null
                      : () => context
                          .read<LiveDetailBloc>()
                          .add(const LiveCommentsLoadMore()),
                  child: Text(
                    loadingMore ? 'Loading…' : 'Load older comments',
                    style: AppTextStyles.nano.copyWith(
                      color: colors.textTertiary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CommentRow extends StatelessWidget {
  const _CommentRow({required this.comment});
  final LiveBroadcastComment comment;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final user = comment.user;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(user: user, size: 28),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      user?.displayName ?? 'Someone',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.nano.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _relative(comment.createdAt),
                    style: AppTextStyles.nano
                        .copyWith(color: colors.textTertiary),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                comment.body,
                style: AppTextStyles.bodySmall
                    .copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _relative(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Composer
// ─────────────────────────────────────────────────────────────────────────────

class _Composer extends StatefulWidget {
  const _Composer({required this.busy});
  final bool busy;
  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _send() {
    final body = _ctl.text.trim();
    if (body.isEmpty || widget.busy) return;
    context.read<LiveDetailBloc>().add(LiveCommentPosted(body));
    _ctl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.sm + MediaQuery.viewInsetsOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        border: Border(
          top: BorderSide(color: colors.borderDefault),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors.bgSurfaceHover,
                borderRadius: BorderRadius.circular(999),
              ),
              child: TextField(
                controller: _ctl,
                minLines: 1,
                maxLines: 3,
                onSubmitted: (_) => _send(),
                style: AppTextStyles.body.copyWith(color: colors.textPrimary),
                cursorColor: colors.accent,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Say something…',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: colors.textTertiary,
                    fontSize: 13,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: colors.accent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: widget.busy ? null : _send,
              child: SizedBox(
                width: 40,
                height: 40,
                child: widget.busy
                    ? const Center(
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : const Icon(
                        LucideIcons.send,
                        size: 16,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared bits
// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user, this.size = 36});
  final LiveBroadcastUser? user;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = user?.firstName.isNotEmpty == true
        ? user!.firstName.substring(0, 1).toUpperCase()
        : user?.username.isNotEmpty == true
            ? user!.username.substring(0, 1).toUpperCase()
            : '?';
    final placeholder = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accentSubtle,
      ),
      child: Text(
        initial,
        style: AppTextStyles.bodySmall.copyWith(
          color: colors.accent,
          fontWeight: FontWeight.w700,
          fontSize: size < 32 ? 10 : 13,
        ),
      ),
    );
    final url = user?.profilePictureUrl;
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

class _Skeleton extends StatelessWidget {
  const _Skeleton();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.xl,
      ),
      children: const [
        SkeletonBox(height: 120),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 200),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 110),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 220),
      ],
    );
  }
}
