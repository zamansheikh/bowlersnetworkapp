import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _bgController;
  late AnimationController _contentController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  final _pages = const [
    _OnboardingData(
      icon: Icons.sports_rounded,
      iconBgColors: [Color(0xFF8BC342), Color(0xFF6FA332)],
      title: 'Track Every Frame',
      subtitle: 'Pin-by-pin scoring, smart analytics,\nand AI coaching to elevate your game.',
      accentColor: AppColors.primary,
    ),
    _OnboardingData(
      icon: Icons.people_rounded,
      iconBgColors: [Color(0xFF5145CD), Color(0xFF7C6FE8)],
      title: 'Join the Community',
      subtitle: 'Connect with bowlers, share scores,\nand climb the leaderboards.',
      accentColor: AppColors.navActive,
    ),
    _OnboardingData(
      icon: Icons.emoji_events_rounded,
      iconBgColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
      title: 'Compete & Earn',
      subtitle: 'Tournaments, XP rewards, trading cards,\nand your path from Newcomer to Legend.',
      accentColor: Color(0xFFF59E0B),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );
    _contentController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bgController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _contentController.reset();
    _contentController.forward();
  }

  Future<void> _finishOnboarding() async {
    final localStorage = getIt<LocalStorageService>();
    await localStorage.setBool(AppConstants.onboardingCompleteKey, true);
    if (mounted) context.go('/auth/login');
  }

  @override
  Widget build(BuildContext context) {
    final data = _pages[_currentPage];

    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Stack(
        children: [
          // Animated background orbs
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, _) => CustomPaint(
              size: MediaQuery.sizeOf(context),
              painter: _OrbPainter(
                progress: _bgController.value,
                color: data.accentColor.withValues(alpha: 0.07),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16, top: 8),
                    child: TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        'Skip',
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (_, index) => _buildPage(_pages[index]),
                  ),
                ),

                // Bottom section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (i) {
                          final isActive = i == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive ? data.accentColor : AppColors.borderLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),

                      // Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _currentPage == _pages.length - 1
                              ? _finishOnboarding
                              : () => _pageController.nextPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: data.accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            _currentPage == _pages.length - 1 ? "Let's Bowl!" : 'Next',
                            style: AppTextStyles.button,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingData data) {
    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideUp,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with gradient circle
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: data.iconBgColors,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: data.iconBgColors[0].withValues(alpha: 0.35),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Icon(data.icon, size: 64, color: Colors.white),
              ),
              const SizedBox(height: 48),

              // Title
              Text(
                data.title,
                style: AppTextStyles.h1.copyWith(
                  fontSize: 28,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalMd,

              // Subtitle
              Text(
                data.subtitle,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final List<Color> iconBgColors;
  final String title;
  final String subtitle;
  final Color accentColor;

  const _OnboardingData({
    required this.icon,
    required this.iconBgColors,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });
}

/// Paints soft floating orbs in the background
class _OrbPainter extends CustomPainter {
  final double progress;
  final Color color;

  _OrbPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // Three orbs floating at different speeds
    for (int i = 0; i < 3; i++) {
      final phase = progress * 2 * pi + (i * pi * 0.7);
      final radius = size.width * (0.3 + i * 0.15);
      final cx = size.width * 0.5 + cos(phase + i) * size.width * 0.2;
      final cy = size.height * (0.25 + i * 0.2) + sin(phase) * 40;
      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.progress != progress || old.color != color;
}
