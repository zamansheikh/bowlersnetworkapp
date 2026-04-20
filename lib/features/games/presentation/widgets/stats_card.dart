import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/user_game_stats.dart';

/// Aggregated stats hero — Average / High Game / High Series + secondary
/// row (Strike %, Clean games, 300s).
class GameStatsCard extends StatelessWidget {
  const GameStatsCard({super.key, required this.stats});

  final UserGameStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      highlightBorder: true,
      showCornerOrb: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'GAME STATS',
                style: AppTextStyles.label.copyWith(
                  color: colors.textTertiary,
                ),
              ),
              const Spacer(),
              Text(
                '${stats.totalGames} games',
                style: AppTextStyles.micro.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _HeroStat(
                value: stats.currentAverage.toStringAsFixed(0),
                label: 'Average',
                color: colors.accent,
                big: true,
              ),
              const SizedBox(width: AppSpacing.lg),
              _HeroStat(
                value: '${stats.highGame}',
                label: 'High Game',
                color: const Color(0xFFEAB308),
              ),
              const SizedBox(width: AppSpacing.lg),
              _HeroStat(
                value: '${stats.highSeries}',
                label: 'High Series',
                color: const Color(0xFFF97316),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: colors.borderDefault),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: LucideIcons.zap,
                  label: 'Strike',
                  value: '${stats.strikePercentage.toStringAsFixed(0)}%',
                  color: colors.accent,
                ),
              ),
              Expanded(
                child: _MiniStat(
                  icon: LucideIcons.target,
                  label: 'Clean',
                  value: '${stats.cleanGameCount}',
                  color: const Color(0xFF3B82F6),
                ),
              ),
              Expanded(
                child: _MiniStat(
                  icon: LucideIcons.trophy,
                  label: '300s',
                  value: '${stats.perfectGameCount}',
                  color: const Color(0xFFEAB308),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.value,
    required this.label,
    required this.color,
    this.big = false,
  });

  final String value;
  final String label;
  final Color color;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: AppTextStyles.numberLarge.copyWith(
              color: color,
              fontSize: big ? 34 : 24,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          value,
          style: AppTextStyles.number.copyWith(
            color: colors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.micro.copyWith(color: colors.textTertiary),
        ),
      ],
    );
  }
}
