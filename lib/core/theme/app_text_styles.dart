import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _baseFont => GoogleFonts.inter();

  // Headings
  static TextStyle get h1 => _baseFont.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get h2 => _baseFont.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get h3 => _baseFont.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get h4 => _baseFont.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  // Body
  static TextStyle get bodyLarge => _baseFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _baseFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => _baseFont.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  // Labels
  static TextStyle get labelLarge => _baseFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelMedium => _baseFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelSmall => _baseFont.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
      );

  // Captions & Overlines
  static TextStyle get caption => _baseFont.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        height: 1.4,
      );

  static TextStyle get overline => _baseFont.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 1.2,
        height: 1.4,
      );

  // Buttons
  static TextStyle get button => _baseFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
        height: 1.2,
      );

  static TextStyle get buttonSmall => _baseFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
        height: 1.2,
      );
}
