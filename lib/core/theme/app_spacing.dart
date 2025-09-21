import 'package:flutter/material.dart';

/// Modern spacing system for consistent, clean layouts
/// Inspired by 8-point grid system and modern design principles
class AppSpacing {
  // ========== BASE SPACING UNITS ==========

  /// Extra small spacing - 4dp
  /// Usage: Icon padding, tight spacing
  static const double xs = 4.0;

  /// Small spacing - 8dp
  /// Usage: Small margins, compact layouts
  static const double sm = 8.0;

  /// Medium spacing - 16dp (Base unit)
  /// Usage: Standard margins, padding, most common spacing
  static const double md = 16.0;

  /// Large spacing - 24dp
  /// Usage: Section spacing, larger margins
  static const double lg = 24.0;

  /// Extra large spacing - 32dp
  /// Usage: Major section breaks, page margins
  static const double xl = 32.0;

  /// Extra extra large spacing - 48dp
  /// Usage: Screen margins, major layout breaks
  static const double xxl = 48.0;

  /// Extra extra extra large spacing - 64dp
  /// Usage: Major screen sections, hero spacing
  static const double xxxl = 64.0;

  // ========== SEMANTIC SPACING (Based on usage context) ==========

  /// Screen edge margins
  static const double screenMargin = lg; // 24dp
  static const double screenMarginLarge = xl; // 32dp

  /// Card spacing
  static const double cardPadding = md; // 16dp
  static const double cardMargin = md; // 16dp
  static const double cardSpacing = sm; // 8dp between cards

  /// List item spacing
  static const double listItemPadding = md; // 16dp
  static const double listItemSpacing = sm; // 8dp between items
  static const double listSectionSpacing = lg; // 24dp between sections

  /// Form spacing
  static const double formFieldSpacing = md; // 16dp between fields
  static const double formSectionSpacing = xl; // 32dp between sections
  static const double formPadding = lg; // 24dp form container padding

  /// Button spacing
  static const double buttonPadding = md; // 16dp button internal padding
  static const double buttonSpacing = sm; // 8dp between buttons
  static const double buttonGroupSpacing = md; // 16dp between button groups

  /// Navigation spacing
  static const double navItemSpacing = sm; // 8dp between nav items
  static const double navSectionSpacing = lg; // 24dp between nav sections

  /// Content spacing
  static const double contentSpacing = md; // 16dp standard content spacing
  static const double paragraphSpacing = sm; // 8dp between paragraphs
  static const double sectionSpacing = xl; // 32dp between major sections

  /// Icon and text spacing
  static const double iconTextSpacing = sm; // 8dp between icon and text
  static const double iconPadding = xs; // 4dp icon internal padding

  // ========== BORDER RADIUS (Related to spacing for consistency) ==========

  /// Border radius values for consistent rounded corners
  static const double radiusXS = 4.0; // Small elements
  static const double radiusSM = 8.0; // Buttons, small cards
  static const double radiusMD = 12.0; // Standard cards, forms
  static const double radiusLG = 16.0; // Large cards, modals
  static const double radiusXL = 20.0; // Hero elements
  static const double radiusXXL = 24.0; // Screen-level elements

  /// Semantic border radius
  static const double buttonRadius = radiusSM; // 8dp
  static const double cardRadius = radiusMD; // 12dp
  static const double inputRadius = radiusSM; // 8dp
  static const double modalRadius = radiusLG; // 16dp

  // ========== ELEVATION/SHADOW (Spacing-related depth) ==========

  /// Elevation values for consistent depth perception
  static const double elevationNone = 0.0;
  static const double elevationXS = 1.0; // Subtle elevation
  static const double elevationSM = 2.0; // Cards, buttons
  static const double elevationMD = 4.0; // Floating elements
  static const double elevationLG = 8.0; // Modals, sheets
  static const double elevationXL = 16.0; // Navigation, important elements

  /// Semantic elevation
  static const double cardElevation = elevationSM; // 2dp
  static const double buttonElevation = elevationXS; // 1dp
  static const double modalElevation = elevationLG; // 8dp
  static const double navElevation = elevationMD; // 4dp
}

/// Extension for easy spacing application in widgets
extension SpacingExtension on num {
  /// Convert number to SizedBox with height
  Widget get verticalSpace => SizedBox(height: toDouble());

  /// Convert number to SizedBox with width
  Widget get horizontalSpace => SizedBox(width: toDouble());

  /// Convert number to EdgeInsets.all
  EdgeInsets get allPadding => EdgeInsets.all(toDouble());

  /// Convert number to EdgeInsets.symmetric horizontal
  EdgeInsets get horizontalPadding =>
      EdgeInsets.symmetric(horizontal: toDouble());

  /// Convert number to EdgeInsets.symmetric vertical
  EdgeInsets get verticalPadding => EdgeInsets.symmetric(vertical: toDouble());

  /// Convert number to EdgeInsets.only top
  EdgeInsets get topPadding => EdgeInsets.only(top: toDouble());

  /// Convert number to EdgeInsets.only bottom
  EdgeInsets get bottomPadding => EdgeInsets.only(bottom: toDouble());

  /// Convert number to EdgeInsets.only left
  EdgeInsets get leftPadding => EdgeInsets.only(left: toDouble());

  /// Convert number to EdgeInsets.only right
  EdgeInsets get rightPadding => EdgeInsets.only(right: toDouble());
}

/// Pre-built spacing widgets for common use cases
class SpacingWidgets {
  /// Vertical spacers
  static const Widget verticalXS = SizedBox(height: AppSpacing.xs);
  static const Widget verticalSM = SizedBox(height: AppSpacing.sm);
  static const Widget verticalMD = SizedBox(height: AppSpacing.md);
  static const Widget verticalLG = SizedBox(height: AppSpacing.lg);
  static const Widget verticalXL = SizedBox(height: AppSpacing.xl);
  static const Widget verticalXXL = SizedBox(height: AppSpacing.xxl);

  /// Horizontal spacers
  static const Widget horizontalXS = SizedBox(width: AppSpacing.xs);
  static const Widget horizontalSM = SizedBox(width: AppSpacing.sm);
  static const Widget horizontalMD = SizedBox(width: AppSpacing.md);
  static const Widget horizontalLG = SizedBox(width: AppSpacing.lg);
  static const Widget horizontalXL = SizedBox(width: AppSpacing.xl);
  static const Widget horizontalXXL = SizedBox(width: AppSpacing.xxl);
}
