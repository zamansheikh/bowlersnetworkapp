import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../domain/entities/leaderboard.dart';
import '../bloc/leaderboard_bloc.dart';
import '../widgets/podium_slot.dart';
import '../widgets/ranking_row.dart';
import '../widgets/ranks_section.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LeaderboardBloc>(
      create: (_) => getIt<LeaderboardBloc>()
        ..add(const LeaderboardTabChanged(LeaderboardTab.weekly)),
      child: const _LeaderboardView(),
    );
  }
}

class _LeaderboardView extends StatefulWidget {
  const _LeaderboardView();

  @override
  State<_LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<_LeaderboardView> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >=
        _scroll.position.maxScrollExtent - 600) {
      final bloc = context.read<LeaderboardBloc>();
      if (bloc.state.hasMore && !bloc.state.loadingMore) {
        bloc.add(const LeaderboardNextPageRequested());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final myUserId =
        context.select<ProfileBloc, int?>((b) => b.state.profile?.user.id);
    final myLevel =
        context.select<ProfileBloc, int?>((b) => b.state.xp?.level);

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: colors.accent,
            onRefresh: () async {
              context
                  .read<LeaderboardBloc>()
                  .add(const LeaderboardRefreshRequested());
              await context
                  .read<LeaderboardBloc>()
                  .stream
                  .firstWhere((s) => !s.refreshing);
            },
            child: CustomScrollView(
              controller: _scroll,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base,
                    AppSpacing.base,
                    AppSpacing.base,
                    AppSpacing.md,
                  ),
                  sliver: const SliverToBoxAdapter(child: _Hero()),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabsDelegate(
                    active: state.tab,
                    onSelect: (t) => context
                        .read<LeaderboardBloc>()
                        .add(LeaderboardTabChanged(t)),
                  ),
                ),
                ..._buildBody(context, state, myUserId, myLevel, colors),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildBody(
    BuildContext context,
    LeaderboardState state,
    int? myUserId,
    int? myLevel,
    dynamic colors,
  ) {
    // ── Ranks tab ────────────────────────────────────────────────────────────
    if (state.tab == LeaderboardTab.ranks) {
      if (state.ranksLoading && state.ranks.isEmpty) {
        return const [SliverFillRemaining(child: _RanksSkeleton())];
      }
      if (state.ranks.isEmpty) {
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: LucideIcons.award,
              title: 'No ranks available',
              hint: state.errors.isNotEmpty ? state.errors.join('\n') : null,
              action: state.errors.isNotEmpty
                  ? AppButton(
                      label: context.l10n.actionRetry,
                      onPressed: () => context
                          .read<LeaderboardBloc>()
                          .add(const LeaderboardRefreshRequested()),
                    )
                  : null,
            ),
          ),
        ];
      }
      return [
        SliverToBoxAdapter(
          child: RanksSection(ranks: state.ranks, myLevel: myLevel),
        ),
      ];
    }

    // ── Leaderboard tabs (weekly / monthly / global) ─────────────────────────
    if (state.loading && state.entries.isEmpty) {
      return const [SliverFillRemaining(child: _LeaderboardSkeleton())];
    }
    if (state.entries.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: LucideIcons.trophy,
            title: 'No rankings yet for this period',
            hint: state.errors.isNotEmpty
                ? state.errors.join('\n')
                : 'Earn XP to appear on the leaderboard.',
          ),
        ),
      ];
    }

    final podium = state.entries.take(3).toList(growable: false);
    final rest = state.entries.length > 3
        ? state.entries.sublist(3)
        : const <LeaderboardEntry>[];

    return [
      if (state.tab == LeaderboardTab.weekly)
        const SliverToBoxAdapter(child: _WeeklyRewardsBanner()),
      SliverToBoxAdapter(
        child: _Podium(podium: podium, currentUserId: myUserId ?? 0),
      ),
      SliverToBoxAdapter(
        child: _YourPositionCard(
          myPosition: state.myPosition,
          periodLabel: state.tab == LeaderboardTab.weekly
              ? 'this week'
              : state.tab == LeaderboardTab.monthly
                  ? 'this month'
                  : 'all time',
        ),
      ),
      if (rest.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base,
              AppSpacing.base,
              AppSpacing.base,
              0,
            ),
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base,
                      AppSpacing.base,
                      AppSpacing.base,
                      AppSpacing.sm,
                    ),
                    child: Text(
                      'RANKINGS',
                      style: AppTextStyles.label.copyWith(
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ),
                  for (var i = 0; i < rest.length; i++) ...[
                    RankingRow(
                      entry: rest[i],
                      isSelf:
                          myUserId != null && rest[i].user.id == myUserId,
                      isTopTen: rest[i].position <= 10,
                    ),
                    if (i < rest.length - 1)
                      Divider(
                        height: 1,
                        color: context.colors.borderDefault
                            .withValues(alpha: 0.4),
                      ),
                  ],
                  if (state.loadingMore)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.colors.accent,
                          ),
                        ),
                      ),
                    )
                  else if (!state.hasMore && state.entries.length > 3)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Center(
                        child: Text(
                          'Showing all ${state.totalEntries} bowlers',
                          style: AppTextStyles.nano.copyWith(
                            color: context.colors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
    ];
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Hero — gradient title card matching web's design.
// ═══════════════════════════════════════════════════════════════════════════
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: colors.accent.withValues(alpha: 0.15)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFEAB308).withValues(alpha: 0.1),
            colors.accent.withValues(alpha: 0.06),
            const Color(0xFFF97316).withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(LucideIcons.trophy, color: colors.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                'XP Leaderboard',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: colors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'See where you rank among the bowling community',
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Tabs — pinned under hero. 4 tabs: Weekly / Monthly / Global / Levels & Ranks
// ═══════════════════════════════════════════════════════════════════════════
class _TabsDelegate extends SliverPersistentHeaderDelegate {
  _TabsDelegate({required this.active, required this.onSelect});

  final LeaderboardTab active;
  final ValueChanged<LeaderboardTab> onSelect;

  static const _height = 44.0;

  @override
  double get minExtent => _height;
  @override
  double get maxExtent => _height;

  @override
  bool shouldRebuild(covariant _TabsDelegate oldDelegate) =>
      oldDelegate.active != active;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colors = context.colors;
    return Container(
      color: colors.bgPrimary,
      height: _height,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.borderDefault)),
        ),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          children: [
            for (final spec in const [
              _TabSpec(LeaderboardTab.weekly, 'Weekly', LucideIcons.calendar),
              _TabSpec(LeaderboardTab.monthly, 'Monthly', LucideIcons.calendar),
              _TabSpec(LeaderboardTab.global, 'Global', LucideIcons.globe),
              _TabSpec(
                  LeaderboardTab.ranks, 'Levels & Ranks', LucideIcons.award),
            ])
              _Tab(spec: spec, active: active == spec.tab, onTap: () => onSelect(spec.tab)),
          ],
        ),
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec(this.tab, this.label, this.icon);
  final LeaderboardTab tab;
  final String label;
  final IconData icon;
}

class _Tab extends StatelessWidget {
  const _Tab({required this.spec, required this.active, required this.onTap});

  final _TabSpec spec;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = active ? colors.accent : colors.textTertiary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? colors.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(spec.icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              spec.label,
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Weekly rewards banner — mirrors web's tier perk grid.
// ═══════════════════════════════════════════════════════════════════════════
class _WeeklyRewardsBanner extends StatelessWidget {
  const _WeeklyRewardsBanner();

  static const _tiers = [
    _RewardTier('1st', 500, 'Champion Badge', Color(0xFFEAB308)),
    _RewardTier('2nd', 300, null, Color(0xFF9CA3AF)),
    _RewardTier('3rd', 200, null, Color(0xFFFB923C)),
    _RewardTier('Top 10', 100, 'Badge', null),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        0,
        AppSpacing.base,
        AppSpacing.md,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          borderRadius: AppRadius.xlAll,
          border: Border.all(
            color: const Color(0xFFEAB308).withValues(alpha: 0.2),
          ),
          gradient: LinearGradient(
            colors: [
              const Color(0xFFEAB308).withValues(alpha: 0.06),
              const Color(0xFFEAB308).withValues(alpha: 0.03),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAB308).withValues(alpha: 0.15),
                    borderRadius: AppRadius.mdAll,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(LucideIcons.trophy,
                      size: 16, color: Color(0xFFEAB308)),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Weekly Rewards',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Earned at week\'s end based on your final rank',
                        style: AppTextStyles.nano.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(builder: (_, c) {
              final cols = c.maxWidth > 380 ? 4 : 2;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in _tiers)
                    SizedBox(
                      width: (c.maxWidth - 8 * (cols - 1)) / cols,
                      child: _RewardTile(tier: t),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _RewardTier {
  const _RewardTier(this.place, this.xp, this.perk, this.color);
  final String place;
  final int xp;
  final String? perk;
  final Color? color;
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({required this.tier});
  final _RewardTier tier;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = tier.color ?? colors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: colors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: accent.withValues(alpha: 0.4)),
            ),
            child: Text(
              tier.place.toUpperCase(),
              style: AppTextStyles.nano.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '+${tier.xp} XP',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (tier.perk != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                tier.perk!,
                style: AppTextStyles.nano.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Podium — top 3 with slot order 2/1/3.
// ═══════════════════════════════════════════════════════════════════════════
class _Podium extends StatelessWidget {
  const _Podium({required this.podium, required this.currentUserId});
  final List<LeaderboardEntry> podium;
  final int currentUserId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        0,
        AppSpacing.base,
        AppSpacing.md,
      ),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (podium.length >= 2)
                  PodiumSlot(
                    entry: podium[1],
                    place: 2,
                    isSelf: podium[1].user.id == currentUserId,
                  ),
                const SizedBox(width: 8),
                if (podium.isNotEmpty)
                  PodiumSlot(
                    entry: podium[0],
                    place: 1,
                    isSelf: podium[0].user.id == currentUserId,
                  ),
                const SizedBox(width: 8),
                if (podium.length >= 3)
                  PodiumSlot(
                    entry: podium[2],
                    place: 3,
                    isSelf: podium[2].user.id == currentUserId,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Ties broken by who joined BowlersNetwork first.',
              textAlign: TextAlign.center,
              style: AppTextStyles.nano.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Your Position card.
// ═══════════════════════════════════════════════════════════════════════════
class _YourPositionCard extends StatelessWidget {
  const _YourPositionCard({
    required this.myPosition,
    required this.periodLabel,
  });

  final MyLeaderboardPosition? myPosition;
  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        0,
        AppSpacing.base,
        AppSpacing.md,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: colors.bgSurfaceElevated,
          borderRadius: AppRadius.xlAll,
          border: Border(
            top: BorderSide(color: colors.accent.withValues(alpha: 0.2)),
            right: BorderSide(color: colors.accent.withValues(alpha: 0.2)),
            bottom: BorderSide(color: colors.accent.withValues(alpha: 0.2)),
            left: BorderSide(color: colors.accent, width: 3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.15),
                borderRadius: AppRadius.mdAll,
              ),
              alignment: Alignment.center,
              child: Icon(LucideIcons.trophy,
                  size: 18, color: colors.accent),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Your Position',
                    style: AppTextStyles.nano.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (myPosition != null)
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '#${myPosition!.position}  ',
                            style: AppTextStyles.sectionTitle.copyWith(
                              color: colors.accent,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                          TextSpan(
                            text:
                                '${_formatXp(myPosition!.xpEarned)} XP $periodLabel',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      'Unranked',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Skeletons.
// ═══════════════════════════════════════════════════════════════════════════
class _LeaderboardSkeleton extends StatelessWidget {
  const _LeaderboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.base),
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              _PodiumSkeleton(small: true),
              SizedBox(width: 8),
              _PodiumSkeleton(small: false),
              SizedBox(width: 8),
              _PodiumSkeleton(small: true),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < 5; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                const SkeletonBox(height: 14, width: 24),
                const SizedBox(width: AppSpacing.md),
                const SkeletonCircle(size: 36),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonBox(height: 12, width: 120),
                      SizedBox(height: 6),
                      SkeletonBox(height: 10, width: 80),
                    ],
                  ),
                ),
                const SkeletonBox(height: 14, width: 50),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PodiumSkeleton extends StatelessWidget {
  const _PodiumSkeleton({required this.small});
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SkeletonCircle(size: small ? 44 : 56),
        const SizedBox(height: 8),
        const SkeletonBox(height: 12, width: 70),
        const SizedBox(height: 6),
        const SkeletonBox(height: 11, width: 50),
        const SizedBox(height: 8),
        SkeletonBox(
          height: small ? 56 : 96,
          width: 90,
          borderRadius: AppRadius.mdAll,
        ),
      ],
    );
  }
}

class _RanksSkeleton extends StatelessWidget {
  const _RanksSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, _) => const SkeletonCard(height: 220),
    );
  }
}

String _formatXp(int xp) {
  if (xp < 1000) return '$xp';
  if (xp < 1000000) {
    return '${(xp / 1000).toStringAsFixed(xp % 1000 >= 100 ? 1 : 0)}K';
  }
  return '${(xp / 1000000).toStringAsFixed(1)}M';
}
