import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/dashboard_range.dart';

/// Pill segmented control for the dashboard's time range. Sticky beneath
/// the app bar across all tabs. Pro tabs can pass `excludeBeyond30: true`
/// to hide the 90d / 365d options (backend rejects them).
class DashboardRangeSelector extends StatelessWidget {
  const DashboardRangeSelector({
    super.key,
    required this.active,
    required this.onPick,
    this.excludeBeyond30 = false,
  });

  final DashboardRange active;
  final ValueChanged<DashboardRange> onPick;
  final bool excludeBeyond30;

  @override
  Widget build(BuildContext context) {
    final options = excludeBeyond30
        ? [DashboardRange.d7, DashboardRange.d30]
        : DashboardRange.values;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 4),
      child: Row(
        children: [
          for (final r in options) ...[
            _RangePill(
              range: r,
              active: r == active,
              onTap: () => onPick(r),
            ),
            if (r != options.last) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _RangePill extends StatelessWidget {
  const _RangePill({
    required this.range,
    required this.active,
    required this.onTap,
  });

  final DashboardRange range;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: active ? colors.accent.withValues(alpha: 0.14) : colors.bgSurface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            range.wire.toUpperCase(),
            style: AppTextStyles.bodySmall.copyWith(
              color: active ? colors.accent : colors.textSecondary,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}
