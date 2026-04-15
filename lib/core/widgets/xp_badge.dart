import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class XpBadge extends StatelessWidget {
  const XpBadge({
    super.key,
    required this.level,
    this.rank,
    this.compact = false,
  });

  final int level;
  final String? rank;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        vertical: compact ? 2 : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.accentSubtle,
        borderRadius: AppRadius.fullAll,
      ),
      child: Text(
        rank == null ? 'Lv $level' : 'Lv $level · $rank',
        style: AppTextStyles.micro.copyWith(
          color: colors.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
