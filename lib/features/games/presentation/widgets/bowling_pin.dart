import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Single bowling pin — matches web's SVG silhouette (white body, red neck
/// band) with knocked vs standing states.
///
/// Drawn with [CustomPainter] so the path is crisp at any size and we
/// don't ship an asset for a single shape.
class BowlingPin extends StatelessWidget {
  const BowlingPin({
    super.key,
    required this.number,
    required this.isStanding,
  });

  final int number;
  final bool isStanding;

  static const Color _pinBody = Color(0xFFFAFAFA);
  static const Color _redNeck = Color(0xFFDC2626);
  static const Color _pinOutline = Color(0xFF1F1F1F);

  @override
  Widget build(BuildContext context) {
    if (!isStanding) return _KnockedPin(number: number);

    return CustomPaint(
      painter: _PinPainter(
        body: _pinBody,
        neck: _redNeck,
        outline: _pinOutline,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _PinPainter extends CustomPainter {
  _PinPainter({
    required this.body,
    required this.neck,
    required this.outline,
  });

  final Color body;
  final Color neck;
  final Color outline;

  @override
  void paint(Canvas canvas, Size size) {
    // Map a normalised 40-wide × 56-tall path into the canvas. Pin shape
    // matches the web's SVG: rounded head, narrow neck, wider belly,
    // flared base.
    final w = size.width;
    final h = size.height;
    final sx = w / 40;
    final sy = h / 56;

    final pinPath = Path()
      ..moveTo(20 * sx, 3 * sy)
      ..cubicTo(14 * sx, 3 * sy, 12 * sx, 9 * sy, 12 * sx, 15 * sy)
      ..cubicTo(12 * sx, 20 * sy, 14 * sx, 24 * sy, 16 * sx, 27 * sy)
      ..cubicTo(13 * sx, 31 * sy, 10 * sx, 37 * sy, 10 * sx, 44 * sy)
      ..cubicTo(10 * sx, 50 * sy, 14 * sx, 53 * sy, 20 * sx, 53 * sy)
      ..cubicTo(26 * sx, 53 * sy, 30 * sx, 50 * sy, 30 * sx, 44 * sy)
      ..cubicTo(30 * sx, 37 * sy, 27 * sx, 31 * sy, 24 * sx, 27 * sy)
      ..cubicTo(26 * sx, 24 * sy, 28 * sx, 20 * sy, 28 * sx, 15 * sy)
      ..cubicTo(28 * sx, 9 * sy, 26 * sx, 3 * sy, 20 * sx, 3 * sy)
      ..close();

    // Soft drop shadow under the pin (web uses 0 3px 5px rgba(0,0,0,.12)).
    canvas.drawPath(
      pinPath.shift(Offset(0, 3 * sy)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Body fill.
    canvas.drawPath(pinPath, Paint()..color = body);

    // Red neck band — a horizontal stripe across the narrow part.
    final neckRect = Rect.fromLTWH(
      11 * sx,
      18 * sy,
      18 * sx,
      6 * sy,
    );
    canvas.save();
    canvas.clipPath(pinPath);
    canvas.drawRect(neckRect, Paint()..color = neck);
    canvas.restore();

    // Thin outline for crispness on light backgrounds.
    canvas.drawPath(
      pinPath,
      Paint()
        ..color = outline.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_PinPainter old) =>
      old.body != body || old.neck != neck || old.outline != outline;
}

/// Knocked pin — hollow circle with just the number inside. Visually
/// "absent" so the eye is drawn to standing pins.
class _KnockedPin extends StatelessWidget {
  const _KnockedPin({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.7,
        heightFactor: 0.7,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.bgSurfaceHover.withValues(alpha: 0.4),
            border: Border.all(
              color: colors.borderDefault,
              width: 1,
            ),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Text(
                  '$number',
                  style: AppTextStyles.nano.copyWith(
                    color: colors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
