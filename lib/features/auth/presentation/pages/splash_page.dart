import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/secure_storage_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final localStorage = getIt<LocalStorageService>();
    final secureStorage = getIt<SecureStorageService>();

    // First launch → onboarding
    final onboardingDone = await localStorage.getBool(AppConstants.onboardingCompleteKey);
    if (!onboardingDone) {
      if (mounted) context.go('/onboarding');
      return;
    }

    // No token → login
    final hasToken = await secureStorage.hasToken();
    if (!hasToken) {
      if (mounted) context.go('/auth/login');
      return;
    }

    // Has token → check profile completion
    try {
      final dio = getIt<Dio>();
      final response = await dio.get('/api/profile/completion');
      final data = response.data as Map<String, dynamic>;
      final isComplete = data['is_complete'] as bool? ?? false;

      if (!mounted) return;
      if (isComplete) {
        context.go('/home');
      } else {
        context.go('/profile-wizard');
      }
    } catch (_) {
      // Token might be invalid, go to login
      if (mounted) context.go('/auth/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(AssetPaths.splashBowlingImage, fit: BoxFit.fitWidth),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(AssetPaths.splashLogo, width: 120, height: 120),
                    const SizedBox(height: 24),
                    const Text(
                      'BowlersNetwork',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: -0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
