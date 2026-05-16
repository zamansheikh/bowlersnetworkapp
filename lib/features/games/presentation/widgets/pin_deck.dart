import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Pin layout — matches the web's PIN_POS exactly (relative to a 256×220
/// canvas). Pins are positioned by percentage of the canvas size, so the
/// deck scales cleanly with any container width.
const Map<int, ({double x, double y})> _pinPos = {
  7: (x: 28, y: 10),
  8: (x: 92, y: 10),
  9: (x: 156, y: 10),
  10: (x: 220, y: 10),
  4: (x: 60, y: 62),
  5: (x: 124, y: 62),
  6: (x: 188, y: 62),
  2: (x: 92, y: 114),
  3: (x: 156, y: 114),
  1: (x: 124, y: 166),
};

const _canvasWidth = 248.0;
const _canvasHeight = 220.0;
const _pinDiameter = 44.0;

/// Tap a pin to toggle knocked ↔ standing. [standing] is the set still up;
/// pins not in the set render as "knocked" (greyed). Tap is disabled when
/// [onPinTap] is null.
class PinDeck extends StatelessWidget {
  const PinDeck({
    super.key,
    required this.standing,
    required this.onPinTap,
  });

  final List<int> standing;
  final ValueChanged<int>? onPinTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      final scale = c.maxWidth / _canvasWidth;
      final h = _canvasHeight * scale;
      return SizedBox(
        height: h,
        width: c.maxWidth,
        child: Stack(
          children: [
            for (final entry in _pinPos.entries)
              Positioned(
                left: entry.value.x * scale - (_pinDiameter * scale) / 2 + 6,
                top: entry.value.y * scale,
                width: _pinDiameter * scale,
                height: _pinDiameter * scale,
                child: _Pin(
                  number: entry.key,
                  isStanding: standing.contains(entry.key),
                  onTap: onPinTap == null ? null : () => onPinTap!(entry.key),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _Pin extends StatelessWidget {
  const _Pin({
    required this.number,
    required this.isStanding,
    required this.onTap,
  });

  final int number;
  final bool isStanding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fill = isStanding ? colors.bgSurfaceElevated : colors.bgSurface;
    final border = isStanding ? colors.accent : colors.borderDefault;
    final textColor = isStanding ? colors.textPrimary : colors.textTertiary;
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill,
            border: Border.all(color: border, width: isStanding ? 2 : 1),
            boxShadow: isStanding
                ? [
                    BoxShadow(
                      color: colors.accent.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Text(
                '$number',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
