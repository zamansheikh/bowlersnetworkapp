import 'package:flutter/widgets.dart';

/// Spacing scale based on 4dp base unit.
///
/// Always use these constants instead of hard-coded values. Prevents
/// visual drift across screens.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xl2 = 32;
  static const double xl3 = 40;
  static const double xl4 = 48;
  static const double xl5 = 64;

  static const double screenHPad = 16;
  static const double heroHPad = 24;

  static const double bottomNavHeight = 64;
  static const double appBarHeight = 56;
}

class AppRadius {
  AppRadius._();

  static const double xs = 6;
  static const double sm = 8;
  static const double md = 10; // matches web `rounded-[10px]` (buttons, inputs)
  static const double lg = 14; // matches web `rounded-[14px]` (skeleton cards)
  static const double xl = 16; // matches web `rounded-2xl` (cards)
  static const double xl2 = 24; // matches web `rounded-3xl` (hero)
  static const double full = 999;

  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xl2All = BorderRadius.all(Radius.circular(xl2));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));
}

class AppDurations {
  AppDurations._();

  static const Duration micro = Duration(milliseconds: 150);
  static const Duration short = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration long = Duration(milliseconds: 300);
  static const Duration xlong = Duration(milliseconds: 400);
  static const Duration progress = Duration(milliseconds: 1000);
  static const Duration shimmer = Duration(milliseconds: 1500);
  static const Duration float = Duration(milliseconds: 3200);
  static const Duration pulse = Duration(milliseconds: 2400);
}

/// Custom easing curves that match the web frontend's feel.
class BNCurves {
  BNCurves._();

  /// Spring-like ease-out used for hero/modal entry animations on web
  /// (`cubic-bezier(0.16, 1, 0.3, 1)`). Gives a confident, slightly
  /// overshoot-free landing.
  static const Cubic spring = Cubic(0.16, 1, 0.3, 1);

  /// Slow-in-slow-out for XP bubbles (`cubic-bezier(0.25, 0.1, 0.25, 1)`).
  static const Cubic xpBubble = Cubic(0.25, 0.1, 0.25, 1);

  /// Standard micro-interaction curve.
  static const Curve standard = Curves.easeOutCubic;
}
