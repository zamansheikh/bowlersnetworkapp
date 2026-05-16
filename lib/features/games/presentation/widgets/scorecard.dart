import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/scorer/bowling_scorer.dart';

/// Horizontal scorecard — 10 frame cells. Frames 1–9 have two delivery
/// boxes; the 10th has three. Cumulative score sits below; cells where
/// bonus is pending show "—".
///
/// Tap a frame to jump the cursor there (matches web's scorecard
/// click-to-jump behavior).
class Scorecard extends StatelessWidget {
  const Scorecard({
    super.key,
    required this.frames,
    required this.activeIndex,
    required this.onFrameTap,
  });

  final List<FrameResult> frames;
  final int activeIndex;
  final ValueChanged<int> onFrameTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: colors.borderDefault),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            for (var i = 0; i < frames.length; i++)
              _FrameCell(
                result: frames[i],
                isActive: i == activeIndex,
                isLast: i == 9,
                onTap: () => onFrameTap(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _FrameCell extends StatelessWidget {
  const _FrameCell({
    required this.result,
    required this.isActive,
    required this.isLast,
    required this.onTap,
  });

  final FrameResult result;
  final bool isActive;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cellWidth = isLast ? 72.0 : 56.0;
    final boxCount = isLast ? 3 : 2;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: cellWidth,
        decoration: BoxDecoration(
          color: isActive
              ? colors.accent.withValues(alpha: 0.08)
              : Colors.transparent,
          border: Border(
            right: BorderSide(color: colors.borderDefault),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Frame number header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: colors.bgSurface,
                border: Border(
                  bottom: BorderSide(color: colors.borderDefault),
                ),
              ),
              child: Text(
                '${result.frameNumber}',
                textAlign: TextAlign.center,
                style: AppTextStyles.nano.copyWith(
                  color: isActive ? colors.accent : colors.textTertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // Delivery marks
            SizedBox(
              height: 22,
              child: Row(
                children: [
                  for (var b = 0; b < boxCount; b++)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: b == 0
                                ? BorderSide.none
                                : BorderSide(color: colors.borderDefault),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          b < result.marks.length ? result.marks[b] : '',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Cumulative score
            Container(
              width: double.infinity,
              height: 24,
              decoration: BoxDecoration(
                color: colors.bgSurface,
                border: Border(
                  top: BorderSide(color: colors.borderDefault),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                result.cumulativeScore != null ? '${result.cumulativeScore}' : '—',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: result.cumulativeScore == null
                      ? colors.textTertiary
                      : colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
