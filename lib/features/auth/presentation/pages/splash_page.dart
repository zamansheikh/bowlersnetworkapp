import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/colors.dart';
import '../bloc/auth_cubit.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();

    // Start auth check after animations begin
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🚀 Splash: Starting auth check');
      context.read<AuthCubit>().checkAuthStatus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            // Decorative Background with Ellipses
            _buildDecorativeBackground(size),

            // Main Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SizedBox(
                            width: 160,
                            height: 160,
                            child: SvgPicture.asset(
                              'assets/splash/logo.svg',
                              width: 160,
                              height: 160,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // App Name Text as SVG
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SizedBox(
                          width: 258,
                          height: 26,
                          child: SvgPicture.asset(
                            'assets/splash/text.svg',
                            width: 258,
                            height: 26,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 60),

                  // Loading Indicator
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return Column(
                          children: [
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryLimeGreen,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading...',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.gray),
                            ),
                          ],
                        );
                      } else if (state is AuthError) {
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.error.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Connection Error',
                                      style: TextStyle(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                context.read<AuthCubit>().checkAuthStatus();
                              },
                              child: Text(
                                'Try Again',
                                style: TextStyle(
                                  color: AppColors.primaryLimeGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeBackground(Size size) {
    // Create a scaled-down version of the decorative pattern
    return Positioned.fill(
      child: Stack(
        children: [
          // Background bowling image (with opacity)
          Positioned(
            bottom: -100,
            left: size.width * 0.5 - 150,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/splash/bowling_image.png',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Decorative ellipses pattern
          _buildEllipsesPattern(size),
        ],
      ),
    );
  }

  Widget _buildEllipsesPattern(Size size) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              -150 +
                  (_animationController.value * 20), // Subtle parallax effect
              -50 + (_animationController.value * 10),
            ),
            child: _buildEllipseGrid(size),
          );
        },
      ),
    );
  }

  Widget _buildEllipseGrid(Size size) {
    final ellipsePositions = _generateEllipsePositions(size);

    return Stack(
      children: ellipsePositions.map((position) {
        return Positioned(
          left: position.dx,
          top: position.dy,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              // Stagger the animation for each ellipse
              double staggeredValue = (_animationController.value * 1.2).clamp(
                0.0,
                1.0,
              );
              return Opacity(
                opacity: (staggeredValue * 0.6).clamp(
                  0.0,
                  0.6,
                ), // Semi-transparent
                child: Transform.scale(
                  scale: 0.3 + (staggeredValue * 0.2), // Smaller ellipses
                  child: SvgPicture.asset(
                    'assets/splash/ellipse.svg',
                    width: 80, // Much smaller than original 244px
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  List<Offset> _generateEllipsePositions(Size size) {
    // Generate a grid of ellipse positions adapted for mobile screen
    List<Offset> positions = [];

    // Create a pattern that works for mobile screens
    const spacing = 60.0;

    for (int row = 0; row < 12; row++) {
      for (int col = 0; col < 6; col++) {
        double x =
            -200 + (col * spacing) + ((row % 2) * 30); // Offset every other row
        double y = -100 + (row * 45);

        if (x < size.width + 100 && y < size.height + 100) {
          // Only add visible ellipses
          positions.add(Offset(x, y));
        }
      }
    }

    return positions;
  }
}
