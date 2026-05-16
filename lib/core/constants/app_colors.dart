import 'package:flutter/material.dart';

/// Raw color palette for BowlersNetwork.
///
/// These are the primitive color values. For semantic access inside widgets,
/// use `context.colors` which resolves to the active [AppThemeColors] extension
/// based on the current theme (light or dark).
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Dark palette (default)
  // ---------------------------------------------------------------------------
  static const darkBgPrimary = Color(0xFF0A0A0A);
  static const darkBgSurface = Color(0xFF111111);
  static const darkBgSurfaceElevated = Color(0xFF1A1A1A);
  static const darkBgSurfaceHover = Color(0xFF222222);
  static const darkBorderDefault = Color(0xFF1F1F1F);
  static const darkBorderStrong = Color(0xFF2E2E2E);
  static const darkTextPrimary = Color(0xFFF5F5F5);
  static const darkTextSecondary = Color(0xFF9A9A9A);
  static const darkTextTertiary = Color(0xFF5A5A5A);

  static const darkAccent = Color(0xFF8BC342);
  static const darkAccentHover = Color(0xFF7DB33A);
  static const darkAccentSubtle = Color(0x1A8BC342); // 10%
  static const darkAccentGlow = Color(0x268BC342); // 15%
  // Premium fill gradient — mirrors web's `.accent-gradient`
  // (`--accent-from` → `--accent-to`). Used on primary CTAs.
  static const darkAccentFrom = Color(0xFFBEF264);
  static const darkAccentTo = Color(0xFF15803D);

  // ---------------------------------------------------------------------------
  // Light palette
  // ---------------------------------------------------------------------------
  static const lightBgPrimary = Color(0xFFFAFAFA);
  static const lightBgSurface = Color(0xFFFFFFFF);
  static const lightBgSurfaceElevated = Color(0xFFFFFFFF);
  static const lightBgSurfaceHover = Color(0xFFF0F0F0);
  static const lightBorderDefault = Color(0xFFE8E8E8);
  static const lightBorderStrong = Color(0xFFD4D4D4);
  static const lightTextPrimary = Color(0xFF0F0F0F);
  static const lightTextSecondary = Color(0xFF6B6B6B);
  static const lightTextTertiary = Color(0xFFA0A0A0);

  static const lightAccent = Color(0xFF6DA030);
  static const lightAccentHover = Color(0xFF5E8C28);
  static const lightAccentSubtle = Color(0x146DA030); // 8%
  static const lightAccentGlow = Color(0x206DA030); // ~12%
  static const lightAccentFrom = Color(0xFF84CC16);
  static const lightAccentTo = Color(0xFF15803D);

  // ---------------------------------------------------------------------------
  // Status (shared across themes)
  // ---------------------------------------------------------------------------
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);

  // ---------------------------------------------------------------------------
  // Section accent colors (mirrors web frontend convention)
  // ---------------------------------------------------------------------------
  static const sectionNewsfeed = Color(0xFF22C55E); // green
  static const sectionChatter = Color(0xFF3B82F6); // blue
  static const sectionMedia = Color(0xFFA855F7); // purple
  static const sectionEvents = Color(0xFFF59E0B); // orange
  static const sectionLeaderboard = Color(0xFFEAB308); // yellow
  static const sectionCards = Color(0xFFEC4899); // pink
}
