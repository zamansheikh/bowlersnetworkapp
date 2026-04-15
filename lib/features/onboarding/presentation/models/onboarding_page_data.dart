import 'package:flutter/material.dart';

/// Static data backing a single onboarding page.
///
/// Localized strings are pulled at build-time via context.l10n inside
/// the onboarding screen — this class only carries layout-level data.
class OnboardingPageData {
  const OnboardingPageData({
    required this.icon,
    required this.accent,
    required this.titleKey,
    required this.descriptionKey,
  });

  final IconData icon;
  final Color accent;

  /// Which l10n key to read for the title. Uses a closure so callers can pass
  /// `(l) => l.onboardingPage1Title` and stay fully type-safe.
  final String Function(dynamic l10n) titleKey;
  final String Function(dynamic l10n) descriptionKey;
}
