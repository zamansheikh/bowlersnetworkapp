import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../theme/app_theme_colors.dart';

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get viewPadding => MediaQuery.paddingOf(this);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  bool get isTablet => MediaQuery.sizeOf(this).width >= 600;
  bool get reducedMotion => MediaQuery.of(this).disableAnimations;

  /// Semantic color tokens for the active theme. Always prefer this over
  /// raw `AppColors.*` references inside widgets.
  AppThemeColors get colors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.dark;

  /// Generated localisation strings. `context.l10n.onboardingPage1Title`
  AppLocalizations get l10n => AppLocalizations.of(this);
}
