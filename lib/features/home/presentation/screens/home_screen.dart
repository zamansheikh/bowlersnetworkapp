import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../../core/widgets/bn_logo.dart';
import '../../../../core/widgets/glow_blob.dart';
import '../../../../core/widgets/xp_badge.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: AppSpacing.base,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            BnLogoMark(size: 28, showGlow: false),
            SizedBox(width: AppSpacing.sm),
            BnWordmark(fontSize: 16),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded, size: 22),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, size: 22),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: GlowBlob(
              size: 260,
              color: colors.accent,
              opacity: 0.05,
              animate: false,
            ),
          ),
          SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.base),
              children: [
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    return _HeroGreeting(
                      name: state.profile?.user.displayName ?? 'Bowler',
                      isPro: state.profile?.user.isPro ?? false,
                    );
                  },
                )
                    .animate()
                    .fadeIn(duration: 400.ms, curve: BNCurves.spring)
                    .moveY(
                      begin: 8,
                      end: 0,
                      duration: 400.ms,
                      curve: BNCurves.spring,
                    ),
                const SizedBox(height: AppSpacing.base),
                BentoCard(
                  icon: Icons.newspaper_rounded,
                  iconColor: AppColors.sectionNewsfeed,
                  title: l10n.navNewsfeed,
                  subtitle: 'Latest posts from your network',
                  onTap: () => context.go(RouteNames.newsfeed),
                  onViewAll: () => context.go(RouteNames.newsfeed),
                  child: Text(
                    'Your feed highlights will appear here.',
                    style: AppTextStyles.body.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(
                      delay: 80.ms,
                      duration: 400.ms,
                      curve: BNCurves.spring,
                    )
                    .moveY(
                      begin: 8,
                      end: 0,
                      delay: 80.ms,
                      duration: 400.ms,
                      curve: BNCurves.spring,
                    ),
                const SizedBox(height: AppSpacing.md),
                BentoCard(
                  icon: Icons.track_changes_rounded,
                  iconColor: AppColors.sectionEvents,
                  title: l10n.navGames,
                  subtitle: 'Track your last sessions',
                  onTap: () => context.go(RouteNames.games),
                  onViewAll: () => context.go(RouteNames.games),
                  child: Text(
                    'Your last games and stats will appear here.',
                    style: AppTextStyles.body.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(
                      delay: 160.ms,
                      duration: 400.ms,
                      curve: BNCurves.spring,
                    )
                    .moveY(
                      begin: 8,
                      end: 0,
                      delay: 160.ms,
                      duration: 400.ms,
                      curve: BNCurves.spring,
                    ),
                const SizedBox(height: AppSpacing.md),
                BentoCard(
                  icon: Icons.emoji_events_rounded,
                  iconColor: AppColors.sectionLeaderboard,
                  title: 'Leaderboard',
                  subtitle: 'Top bowlers this week',
                  onViewAll: () {},
                  child: Text(
                    'Leaderboard preview coming soon.',
                    style: AppTextStyles.body.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(
                      delay: 240.ms,
                      duration: 400.ms,
                      curve: BNCurves.spring,
                    )
                    .moveY(
                      begin: 8,
                      end: 0,
                      delay: 240.ms,
                      duration: 400.ms,
                      curve: BNCurves.spring,
                    ),
                const SizedBox(height: AppSpacing.base),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroGreeting extends StatelessWidget {
  const _HeroGreeting({required this.name, required this.isPro});

  final String name;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      showCornerOrb: true,
      borderRadius: AppRadius.xl2All,
      padding: const EdgeInsets.all(AppSpacing.xl),
      highlightBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Welcome back 👋',
                style: AppTextStyles.secondary.copyWith(
                  color: colors.textTertiary,
                ),
              ),
              if (isPro) ...[
                const SizedBox(width: AppSpacing.sm),
                const XpBadge(level: 0, rank: 'PRO'),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            name,
            style: AppTextStyles.displayHero.copyWith(
              color: colors.textPrimary,
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }
}
