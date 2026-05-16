import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/session.dart';

class SessionDetailScreen extends StatelessWidget {
  const SessionDetailScreen({super.key, required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(title: Text(session.name)),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus, size: 18),
        label: Text(
          'Bowl another game',
          style: AppTextStyles.buttonLabel.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        onPressed: () =>
            context.push('${RouteNames.games}/play/${session.uid}'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.base),
          children: [
            AppCard(
              highlightBorder: true,
              showCornerOrb: true,
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.context.label.toUpperCase(),
                    style: AppTextStyles.label.copyWith(
                      color: colors.accent,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${session.seriesTotal}',
                    style: AppTextStyles.numberLarge.copyWith(
                      color: colors.textPrimary,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  Text(
                    'Series total across ${session.gamesPlayed} game${session.gamesPlayed == 1 ? '' : 's'}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  if (session.center != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Icon(LucideIcons.mapPin,
                            size: 13, color: colors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          session.center!.name,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        if (session.laneNumbers.isNotEmpty)
                          Text(
                            '  ·  Lane ${session.laneNumbers}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            if (session.oilPatternName.isNotEmpty)
              _InfoRow(
                icon: LucideIcons.droplet,
                label: 'Oil pattern',
                value: session.oilPatternLength == null
                    ? session.oilPatternName
                    : '${session.oilPatternName} (${session.oilPatternLength} ft)',
              ),
            if (session.notes.isNotEmpty)
              _InfoRow(
                icon: LucideIcons.fileText,
                label: 'Notes',
                value: session.notes,
              ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'GAMES',
              style: AppTextStyles.label.copyWith(color: colors.textTertiary),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final g in session.games) ...[
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.accentSubtle,
                        borderRadius: AppRadius.smAll,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'G${g.gameNumber}',
                        style: AppTextStyles.number.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${g.totalScore}',
                            style: AppTextStyles.numberLarge.copyWith(
                              color: colors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              _Chip(
                                icon: LucideIcons.zap,
                                label: '${g.strikeCount} strikes',
                                color: colors.accent,
                              ),
                              const SizedBox(width: 6),
                              _Chip(
                                icon: LucideIcons.target,
                                label: '${g.spareCount} spares',
                                color: colors.textSecondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!g.isComplete)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colors.warning.withValues(alpha: 0.15),
                          borderRadius: AppRadius.smAll,
                        ),
                        child: Text(
                          'IN PROGRESS',
                          style: AppTextStyles.nano.copyWith(
                            color: colors.warning,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, size: 14, color: colors.textTertiary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label.toUpperCase(),
              style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                value,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTextStyles.micro.copyWith(color: color),
        ),
      ],
    );
  }
}
