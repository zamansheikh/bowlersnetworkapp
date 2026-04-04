import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  // Base unit: 4
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double huge = 64;

  // Border Radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 999;

  // Common EdgeInsets
  static const EdgeInsets paddingAll = EdgeInsets.all(base);
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(horizontal: base);
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(vertical: base);
  static const EdgeInsets paddingCard = EdgeInsets.all(md);
  static const EdgeInsets paddingScreen = EdgeInsets.symmetric(horizontal: base, vertical: sm);

  // SizedBox helpers
  static const SizedBox verticalXs = SizedBox(height: xs);
  static const SizedBox verticalSm = SizedBox(height: sm);
  static const SizedBox verticalMd = SizedBox(height: md);
  static const SizedBox verticalBase = SizedBox(height: base);
  static const SizedBox verticalLg = SizedBox(height: lg);
  static const SizedBox verticalXl = SizedBox(height: xl);
  static const SizedBox verticalXxl = SizedBox(height: xxl);

  static const SizedBox horizontalXs = SizedBox(width: xs);
  static const SizedBox horizontalSm = SizedBox(width: sm);
  static const SizedBox horizontalMd = SizedBox(width: md);
  static const SizedBox horizontalBase = SizedBox(width: base);
  static const SizedBox horizontalLg = SizedBox(width: lg);
  static const SizedBox horizontalXl = SizedBox(width: xl);
}
