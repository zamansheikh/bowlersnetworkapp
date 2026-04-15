import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale for BowlersNetwork.
///
/// Uses Geist via `google_fonts` with system fallback. Caller provides the
/// color (typically via `context.colors.textPrimary`) — these methods return
/// uncolored base styles so text color automatically adapts to theme.
///
/// Colored variants take a [BuildContext] and pull the right token.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    double? letterSpacing,
    double? height,
    Color? color,
    List<FontFeature>? fontFeatures,
  }) {
    // Geist + system fallback. google_fonts ships Geist as of v6+.
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
      fontFeatures: fontFeatures,
    );
  }

  // ---------------------------------------------------------------------------
  // Uncolored primitives — color inherited from DefaultTextStyle / widget
  // ---------------------------------------------------------------------------
  static TextStyle get pageTitle => _base(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.2,
      );

  static TextStyle get sectionTitle =>
      _base(fontSize: 16, fontWeight: FontWeight.w600, height: 1.3);

  static TextStyle get cardTitle =>
      _base(fontSize: 15, fontWeight: FontWeight.w600, height: 1.35);

  static TextStyle get body => _base(fontSize: 14, height: 1.5);

  static TextStyle get bodyMedium =>
      _base(fontSize: 14, fontWeight: FontWeight.w500, height: 1.5);

  static TextStyle get bodySmall => _base(fontSize: 13, height: 1.5);

  static TextStyle get secondary => _base(fontSize: 12, height: 1.4);

  static TextStyle get label => _base(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        height: 1.3,
      );

  static TextStyle get micro =>
      _base(fontSize: 10, fontWeight: FontWeight.w500, height: 1.3);

  static TextStyle get number => _base(
        fontSize: 14,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle get numberLarge => _base(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle get buttonLabel =>
      _base(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.1);

  // ---------------------------------------------------------------------------
  // Builds a Material TextTheme so default widgets (Scaffold, AppBar, buttons)
  // pick up the Geist family and sensible sizing out of the box.
  // ---------------------------------------------------------------------------
  static TextTheme textTheme(Color defaultColor) {
    return TextTheme(
      displayLarge: pageTitle.copyWith(color: defaultColor),
      displayMedium: pageTitle.copyWith(fontSize: 22, color: defaultColor),
      displaySmall: pageTitle.copyWith(fontSize: 20, color: defaultColor),
      headlineLarge: sectionTitle.copyWith(fontSize: 20, color: defaultColor),
      headlineMedium: sectionTitle.copyWith(color: defaultColor),
      headlineSmall: cardTitle.copyWith(color: defaultColor),
      titleLarge: sectionTitle.copyWith(color: defaultColor),
      titleMedium: cardTitle.copyWith(color: defaultColor),
      titleSmall: bodyMedium.copyWith(color: defaultColor),
      bodyLarge: body.copyWith(color: defaultColor),
      bodyMedium: body.copyWith(color: defaultColor),
      bodySmall: bodySmall.copyWith(color: defaultColor),
      labelLarge: buttonLabel.copyWith(color: defaultColor),
      labelMedium: secondary.copyWith(color: defaultColor),
      labelSmall: label.copyWith(color: defaultColor),
    );
  }
}
