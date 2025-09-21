import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Modern typography system inspired by clean, minimal design
/// Based on Material Design 3 with custom refinements for readability
class AppTextStyles {
  // Base font family - using system default for consistency
  static const String fontFamily = 'SF Pro Display'; // iOS-style for clean look
  static const String fontFamilyFallback = 'Roboto'; // Android fallback

  // ========== DISPLAY STYLES (Large headings) ==========

  /// Large display text - for main titles and headers
  /// Usage: Page titles, main headings
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700, // Bold
    letterSpacing: -0.5,
    height: 1.1,
  );

  /// Medium display text - for section titles
  /// Usage: Section headings, modal titles
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600, // Semi-bold
    letterSpacing: -0.3,
    height: 1.2,
  );

  /// Small display text - for subsection titles
  /// Usage: Card titles, subsection headings
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.2,
  );

  // ========== HEADLINE STYLES (Medium headings) ==========

  /// Large headline - for important content titles
  /// Usage: Profile sections, feature titles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );

  /// Medium headline - for content organization
  /// Usage: List headers, form sections
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );

  /// Small headline - for minor headings
  /// Usage: Settings categories, small sections
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  // ========== TITLE STYLES (Functional text) ==========

  /// Large title - for navigation and buttons
  /// Usage: App bar titles, large buttons
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );

  /// Medium title - for labels and form fields
  /// Usage: Input labels, card titles
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );

  /// Small title - for secondary labels
  /// Usage: Secondary text, timestamps
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.4,
  );

  // ========== BODY STYLES (Content text) ==========

  /// Large body text - for main content
  /// Usage: Article content, descriptions
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5, // Better readability
  );

  /// Medium body text - for standard content
  /// Usage: List items, form content, general text
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
  );

  /// Small body text - for supporting content
  /// Usage: Helper text, subtitles
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.4,
  );

  // ========== LABEL STYLES (UI elements) ==========

  /// Large label - for prominent UI elements
  /// Usage: Button text, form labels
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.3,
  );

  /// Medium label - for standard UI elements
  /// Usage: Navigation items, chips
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.3,
  );

  /// Small label - for minimal UI elements
  /// Usage: Captions, small badges
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.3,
  );

  // ========== SPECIALIZED STYLES ==========

  /// Button text style
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.2,
  );

  /// Input field text style
  static const TextStyle input = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
  );

  /// Caption text style (very small supporting text)
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    height: 1.3,
  );

  /// Overline text style (small uppercase labels)
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    height: 1.3,
  );
}

/// Extension methods for easy color application
extension AppTextStylesExtension on TextStyle {
  /// Apply primary color (lime green)
  TextStyle get primary => copyWith(color: AppColors.primaryLimeGreen);

  /// Apply secondary color
  TextStyle get secondary => copyWith(color: AppColors.gray600);

  /// Apply surface color
  TextStyle get onSurface => copyWith(color: AppColors.gray800);

  /// Apply error color
  TextStyle get error => copyWith(color: AppColors.error);

  /// Apply success color
  TextStyle get success => copyWith(color: AppColors.success);

  /// Apply white color
  TextStyle get white => copyWith(color: AppColors.white);

  /// Apply muted/disabled color
  TextStyle get muted => copyWith(color: AppColors.gray400);
}
