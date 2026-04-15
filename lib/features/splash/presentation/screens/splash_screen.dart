import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../onboarding/data/onboarding_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    // Small delay so the splash animation plays at least once.
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final onboarding = getIt<OnboardingStorage>();
    final secure = getIt<SecureStorageService>();

    final seen = await onboarding.hasSeenOnboarding();
    if (!mounted) return;
    if (!seen) {
      context.go(RouteNames.onboarding);
      return;
    }

    final token = await secure.getToken();
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      context.go(RouteNames.login);
    } else {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colors.accent.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Icon(
                Icons.sports_cricket_rounded,
                size: 48,
                color: colors.accent,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.96, 0.96),
                  end: const Offset(1.04, 1.04),
                  duration: 1200.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: AppSpacing.lg),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Bowlers',
                    style: AppTextStyles.pageTitle.copyWith(
                      color: colors.textPrimary,
                      fontSize: 22,
                    ),
                  ),
                  TextSpan(
                    text: 'Network',
                    style: AppTextStyles.pageTitle.copyWith(
                      color: colors.accent,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
          ],
        ),
      ),
    );
  }
}
