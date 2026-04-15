import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/onboarding_storage.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  late final List<_PageSpec> _pages = [
    _PageSpec(
      icon: Icons.groups_rounded,
      accent: AppColors.sectionNewsfeed,
      title: (l) => l.onboardingPage1Title,
      description: (l) => l.onboardingPage1Description,
    ),
    _PageSpec(
      icon: Icons.track_changes_rounded,
      accent: AppColors.sectionEvents,
      title: (l) => l.onboardingPage2Title,
      description: (l) => l.onboardingPage2Description,
    ),
    _PageSpec(
      icon: Icons.forum_rounded,
      accent: AppColors.sectionChatter,
      title: (l) => l.onboardingPage3Title,
      description: (l) => l.onboardingPage3Description,
    ),
    _PageSpec(
      icon: Icons.emoji_events_rounded,
      accent: AppColors.sectionLeaderboard,
      title: (l) => l.onboardingPage4Title,
      description: (l) => l.onboardingPage4Description,
    ),
  ];

  bool get _isLast => _currentPage == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await getIt<OnboardingStorage>().markSeen();
    if (!mounted) return;
    context.go(RouteNames.login);
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: AppDurations.medium,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              onSkip: _isLast ? null : _finish,
              skipLabel: l10n.actionSkip,
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) {
                  final p = _pages[i];
                  return OnboardingPage(
                    index: i,
                    icon: p.icon,
                    accent: p.accent,
                    title: p.title(l10n),
                    description: p.description(l10n),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.base,
              ),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: _pages[_currentPage].accent,
                      dotColor: colors.borderStrong,
                      dotHeight: 6,
                      dotWidth: 6,
                      expansionFactor: 4,
                      spacing: 6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: _isLast ? l10n.actionGetStarted : l10n.actionNext,
                    onPressed: _next,
                    expand: true,
                    size: AppButtonSize.large,
                    trailingIcon: _isLast ? null : Icons.arrow_forward_rounded,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSkip, required this.skipLabel});

  final VoidCallback? onSkip;
  final String skipLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.base,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.l10n.appName,
            style: AppTextStyles.cardTitle.copyWith(color: colors.textPrimary),
          ),
          AnimatedOpacity(
            duration: AppDurations.micro,
            opacity: onSkip == null ? 0 : 1,
            child: TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                foregroundColor: colors.textSecondary,
                minimumSize: const Size(44, 44),
              ),
              child: Text(
                skipLabel,
                style: AppTextStyles.buttonLabel.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageSpec {
  const _PageSpec({
    required this.icon,
    required this.accent,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color accent;
  final String Function(AppLocalizations l) title;
  final String Function(AppLocalizations l) description;
}
