import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/bn_logo.dart';
import '../../../../core/widgets/glow_blob.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../onboarding/data/onboarding_storage.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';

/// Shown at boot while we hydrate auth state. Once AuthBloc resolves, this
/// routes to onboarding (first launch), login, profile (incomplete) or home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthStarted());
  }

  Future<void> _handleTransition(AuthStatus status) async {
    if (status == AuthStatus.unknown) return;

    // Give the splash animation a moment on fast launches.
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    if (status == AuthStatus.unauthenticated) {
      final seen = await getIt<OnboardingStorage>().hasSeenOnboarding();
      if (!mounted) return;
      context.go(seen ? RouteNames.login : RouteNames.onboarding);
      return;
    }

    if (status == AuthStatus.requiresConsent) {
      context.go(RouteNames.consentPending);
      return;
    }

    context.read<ProfileBloc>().add(const ProfileLoadRequested());
    context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, next) => prev.status != next.status,
      listener: (_, state) => _handleTransition(state.status),
      child: Scaffold(
        backgroundColor: colors.bgPrimary,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const AmbientBackground(),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BnLogoMark(size: 88)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(0.96, 0.96),
                        end: const Offset(1.06, 1.06),
                        duration: 1400.ms,
                        curve: Curves.easeInOut,
                      ),
                  const SizedBox(height: AppSpacing.lg),
                  const BnWordmark(fontSize: 22)
                      .animate()
                      .fadeIn(
                        duration: 600.ms,
                        delay: 200.ms,
                        curve: BNCurves.spring,
                      )
                      .moveY(
                        begin: 6,
                        end: 0,
                        duration: 600.ms,
                        delay: 200.ms,
                        curve: BNCurves.spring,
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
