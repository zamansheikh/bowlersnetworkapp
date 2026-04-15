import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Semantic color tokens for BowlersNetwork.
///
/// Access inside widgets via `context.colors.bgPrimary`.
/// Never reference raw hex values directly in feature code.
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.bgPrimary,
    required this.bgSurface,
    required this.bgSurfaceElevated,
    required this.bgSurfaceHover,
    required this.borderDefault,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.accentHover,
    required this.accentSubtle,
    required this.accentGlow,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
  });

  final Color bgPrimary;
  final Color bgSurface;
  final Color bgSurfaceElevated;
  final Color bgSurfaceHover;
  final Color borderDefault;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accent;
  final Color accentHover;
  final Color accentSubtle;
  final Color accentGlow;
  final Color error;
  final Color success;
  final Color warning;
  final Color info;

  static const dark = AppThemeColors(
    bgPrimary: AppColors.darkBgPrimary,
    bgSurface: AppColors.darkBgSurface,
    bgSurfaceElevated: AppColors.darkBgSurfaceElevated,
    bgSurfaceHover: AppColors.darkBgSurfaceHover,
    borderDefault: AppColors.darkBorderDefault,
    borderStrong: AppColors.darkBorderStrong,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textTertiary: AppColors.darkTextTertiary,
    accent: AppColors.darkAccent,
    accentHover: AppColors.darkAccentHover,
    accentSubtle: AppColors.darkAccentSubtle,
    accentGlow: AppColors.darkAccentGlow,
    error: AppColors.error,
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
  );

  static const light = AppThemeColors(
    bgPrimary: AppColors.lightBgPrimary,
    bgSurface: AppColors.lightBgSurface,
    bgSurfaceElevated: AppColors.lightBgSurfaceElevated,
    bgSurfaceHover: AppColors.lightBgSurfaceHover,
    borderDefault: AppColors.lightBorderDefault,
    borderStrong: AppColors.lightBorderStrong,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textTertiary: AppColors.lightTextTertiary,
    accent: AppColors.lightAccent,
    accentHover: AppColors.lightAccentHover,
    accentSubtle: AppColors.lightAccentSubtle,
    accentGlow: AppColors.lightAccentGlow,
    error: AppColors.error,
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
  );

  @override
  AppThemeColors copyWith({
    Color? bgPrimary,
    Color? bgSurface,
    Color? bgSurfaceElevated,
    Color? bgSurfaceHover,
    Color? borderDefault,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accent,
    Color? accentHover,
    Color? accentSubtle,
    Color? accentGlow,
    Color? error,
    Color? success,
    Color? warning,
    Color? info,
  }) {
    return AppThemeColors(
      bgPrimary: bgPrimary ?? this.bgPrimary,
      bgSurface: bgSurface ?? this.bgSurface,
      bgSurfaceElevated: bgSurfaceElevated ?? this.bgSurfaceElevated,
      bgSurfaceHover: bgSurfaceHover ?? this.bgSurfaceHover,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      accent: accent ?? this.accent,
      accentHover: accentHover ?? this.accentHover,
      accentSubtle: accentSubtle ?? this.accentSubtle,
      accentGlow: accentGlow ?? this.accentGlow,
      error: error ?? this.error,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      bgPrimary: Color.lerp(bgPrimary, other.bgPrimary, t)!,
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t)!,
      bgSurfaceElevated: Color.lerp(bgSurfaceElevated, other.bgSurfaceElevated, t)!,
      bgSurfaceHover: Color.lerp(bgSurfaceHover, other.bgSurfaceHover, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentHover: Color.lerp(accentHover, other.accentHover, t)!,
      accentSubtle: Color.lerp(accentSubtle, other.accentSubtle, t)!,
      accentGlow: Color.lerp(accentGlow, other.accentGlow, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}
