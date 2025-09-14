import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primaryLimeGreen = Color(0xFF8BC342);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Shades of Lime Green
  static const Color lightLimeGreen = Color(0xFF9ED354);
  static const Color darkLimeGreen = Color(0xFF7AB230);

  // Gray Variants
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color gray = Color(0xFF6C757D);
  static const Color darkGray = Color(0xFF343A40);

  // Status Colors
  static const Color success = Color(0xFF28A745);
  static const Color error = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF17A2B8);

  // Modern UI Colors
  static const Color surface = Color(0xFFFAFAFA);
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color outline = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [lightLimeGreen, primaryLimeGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [white, lightGray],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Card colors
  static const Color cardBackground = white;
  static const Color cardShadow = Color(0x0A000000);
}
