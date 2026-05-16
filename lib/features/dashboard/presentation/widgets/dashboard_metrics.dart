import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Number-with-label tile used in the responsive metric grids on every
/// dashboard tab. Optionally shows a [DeltaPill] underneath for
/// period-over-period comparisons.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.deltaPct,
    this.suffix = '',
  });

  final String label;
  final String value;
  final IconData? icon;

  /// Percent change vs previous period. Null = no baseline (renders no pill).
  final double? deltaPct;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.bgSurfaceHover,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 11, color: colors.textTertiary),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.nano.copyWith(
                    color: colors.textTertiary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              if (suffix.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Text(
                    suffix,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.textTertiary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          if (deltaPct != null) ...[
            const SizedBox(height: 4),
            DeltaPill(percent: deltaPct),
          ],
        ],
      ),
    );
  }
}

/// "+12.4%" green / "-3.1%" red / "—" gray. Pass null for "no baseline".
class DeltaPill extends StatelessWidget {
  const DeltaPill({super.key, required this.percent, this.compact = true});

  final double? percent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final p = percent;
    if (p == null) {
      return _Chip(
        label: 'New',
        color: colors.textTertiary,
        icon: null,
        compact: compact,
      );
    }
    final positive = p > 0.01;
    final negative = p < -0.01;
    final color = positive
        ? colors.success
        : negative
            ? colors.error
            : colors.textTertiary;
    final icon = positive
        ? LucideIcons.trendingUp
        : negative
            ? LucideIcons.trendingDown
            : LucideIcons.minus;
    final magnitude = p.abs();
    final formatted = magnitude >= 100
        ? magnitude.toStringAsFixed(0)
        : magnitude.toStringAsFixed(1);
    return _Chip(
      label: '${positive ? '+' : negative ? '-' : ''}$formatted%',
      color: color,
      icon: icon,
      compact: compact,
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    required this.icon,
    required this.compact,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final hPad = compact ? 6.0 : 8.0;
    final vPad = compact ? 1.0 : 2.0;
    final iconSize = compact ? 10.0 : 12.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: AppTextStyles.nano.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
