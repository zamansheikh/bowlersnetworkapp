import 'package:flutter/material.dart';

import '../constants/asset_paths.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// The BowlersNetwork logo mark (circular brand asset) with optional
/// accent glow and optional "BowlersNetwork" wordmark beneath.
///
/// The PNG at [AssetPaths.appIcon] is the source of truth — never draw the
/// logo from a placeholder icon.
class BnLogoMark extends StatelessWidget {
  const BnLogoMark({
    super.key,
    this.size = 56,
    this.showGlow = true,
    this.borderless = false,
  });

  final double size;
  final bool showGlow;

  /// When true, skips the rounded container + border (raw asset image only).
  final bool borderless;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final image = Image.asset(
      AssetPaths.appIcon,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    if (borderless) return image;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: colors.accent.withValues(alpha: 0.28),
                  blurRadius: size * 0.55,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: ClipOval(child: image),
    );
  }
}

/// Text wordmark: "Bowlers" in primary text color + "Network" in accent.
/// Pair with [BnLogoMark] for the full lockup.
class BnWordmark extends StatelessWidget {
  const BnWordmark({super.key, this.fontSize = 20});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Bowlers',
            style: AppTextStyles.pageTitle.copyWith(
              color: colors.textPrimary,
              fontSize: fontSize,
              letterSpacing: -0.3,
            ),
          ),
          TextSpan(
            text: 'Network',
            style: AppTextStyles.pageTitle.copyWith(
              color: colors.accent,
              fontSize: fontSize,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Vertical stack: logo mark above wordmark. Used on splash, auth screens.
class BnBrandLockup extends StatelessWidget {
  const BnBrandLockup({
    super.key,
    this.logoSize = 72,
    this.fontSize = 18,
    this.spacing = AppSpacing.md,
  });

  final double logoSize;
  final double fontSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BnLogoMark(size: logoSize),
        SizedBox(height: spacing),
        BnWordmark(fontSize: fontSize),
      ],
    );
  }
}
