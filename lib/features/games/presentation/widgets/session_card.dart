import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/session.dart';

/// Feed-style session summary — displayed in the Games tab list.
class SessionCard extends StatelessWidget {
  const SessionCard({super.key, required this.session, this.onTap});

  final Session session;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _ContextChip(context: session.context),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  session.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              if (session.createdAt != null)
                Text(
                  timeago.format(session.createdAt!, locale: 'en_short'),
                  style: AppTextStyles.micro.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (session.center != null) ...[
                Icon(LucideIcons.mapPin, size: 12, color: colors.textTertiary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    session.center!.name,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.secondary.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
              if (session.laneNumbers.isNotEmpty) ...[
                Text(
                  '  ·  Lane ${session.laneNumbers}',
                  style: AppTextStyles.secondary.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
          if (session.games.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _ScoresRow(games: session.games),
          ],
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.08),
              borderRadius: AppRadius.mdAll,
            ),
            child: Row(
              children: [
                Text(
                  'SERIES',
                  style: AppTextStyles.label.copyWith(color: colors.accent),
                ),
                const Spacer(),
                Text(
                  '${session.seriesTotal}',
                  style: AppTextStyles.numberLarge.copyWith(
                    color: colors.accent,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${session.gamesPlayed} game${session.gamesPlayed == 1 ? '' : 's'}',
                  style: AppTextStyles.micro.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextChip extends StatelessWidget {
  const _ContextChip({required this.context});
  final GameContext context;

  @override
  Widget build(BuildContext ctx) {
    final colors = ctx.colors;
    final (bg, fg) = switch (context) {
      GameContext.league => (
          const Color(0x223B82F6),
          const Color(0xFF3B82F6),
        ),
      GameContext.tournament => (
          const Color(0x22F97316),
          const Color(0xFFF97316),
        ),
      GameContext.casual => (colors.bgSurfaceHover, colors.textSecondary),
      GameContext.practice => (colors.accentSubtle, colors.accent),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.smAll,
      ),
      child: Text(
        context.label.toUpperCase(),
        style: AppTextStyles.nano.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ScoresRow extends StatelessWidget {
  const _ScoresRow({required this.games});
  final List<GameSummary> games;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final g in games) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: colors.bgSurfaceHover.withValues(alpha: 0.4),
                borderRadius: AppRadius.smAll,
                border: Border.all(color: colors.borderDefault),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'G${g.gameNumber}',
                    style: AppTextStyles.nano.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${g.totalScore}',
                    style: AppTextStyles.number.copyWith(
                      color: g.isComplete
                          ? colors.textPrimary
                          : colors.textTertiary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}
