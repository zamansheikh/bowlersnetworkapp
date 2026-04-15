import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bento_card.dart';

/// Placeholder home screen — full overview with BentoCards comes in Phase 2.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded, size: 22),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, size: 22),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.base),
          children: [
            Text(
              l10n.homeGreeting('Bowler'),
              style: AppTextStyles.pageTitle.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            BentoCard(
              icon: Icons.newspaper_rounded,
              iconColor: AppColors.sectionNewsfeed,
              title: l10n.navNewsfeed,
              onViewAll: () {},
              child: Text(
                'Your feed highlights will appear here.',
                style: AppTextStyles.body.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            BentoCard(
              icon: Icons.track_changes_rounded,
              iconColor: AppColors.sectionEvents,
              title: l10n.navGames,
              onViewAll: () {},
              child: Text(
                'Your last games and stats will appear here.',
                style: AppTextStyles.body.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            BentoCard(
              icon: Icons.emoji_events_rounded,
              iconColor: AppColors.sectionLeaderboard,
              title: 'Leaderboard',
              onViewAll: () {},
              child: Text(
                'Top bowlers this week.',
                style: AppTextStyles.body.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
