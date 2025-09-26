import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    return Scaffold(
      body: Container(
        width: 1.sw, // 100% screen width
        height: 1.sh, // 100% screen height
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            // Decorative Background with Ellipses
            _buildDecorativeBackground(),

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
                            width: 160.w, // Responsive width
                            height: 160.h, // Responsive height
                            child: SvgPicture.asset(
                              'assets/splash/logo.svg',
                              width: 160.w,
                              height: 160.h,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 16.h), // Responsive height
                  // App Name Text as SVG
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SizedBox(
                          width: 258.w, // Responsive width
                          height: 26.h, // Responsive height
                          child: SvgPicture.asset(
                            'assets/splash/text.svg',
                            width: 258.w,
                            height: 26.h,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 60.h), // Responsive height
                  // Loading Indicator
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return Column(
                          children: [
                            SizedBox(
                              width: 40.w, // Responsive width
                              height: 40.h, // Responsive height
                              child: CircularProgressIndicator(
                                strokeWidth: 3.w, // Responsive stroke width
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryLimeGreen,
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h), // Responsive height
                            Text(
                              'Loading...',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.gray,
                                    fontSize: 14.sp, // Responsive font size
                                  ),
                            ),
                          ],
                        );
                      } else if (state is AuthError) {
                        return Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    24.w, // Responsive horizontal padding
                                vertical: 12.h, // Responsive vertical padding
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  12.r,
                                ), // Responsive border radius
                                border: Border.all(
                                  color: AppColors.error.withValues(alpha: 0.3),
                                  width: 1.w, // Responsive border width
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: AppColors.error,
                                    size: 20.sp, // Responsive icon size
                                  ),
                                  SizedBox(width: 8.w), // Responsive width
                                  Flexible(
                                    child: Text(
                                      'Connection Error',
                                      style: TextStyle(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14.sp, // Responsive font size
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h), // Responsive height
                            TextButton(
                              onPressed: () {
                                context.read<AuthCubit>().checkAuthStatus();
                              },
                              child: Text(
                                'Try Again',
                                style: TextStyle(
                                  color: AppColors.primaryLimeGreen,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp, // Responsive font size
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

  Widget _buildDecorativeBackground() {
    // Create a scaled-down version of the decorative pattern
    return Positioned.fill(
      child: Stack(
        children: [
          // Background bowling image (with opacity)
          Positioned(
            bottom: -50.h, // Responsive bottom position
            left: 0.w,
            right: 0.w,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/splash/bowling_image.png',
                width: 300.w, // Responsive width
                height: 300.h, // Responsive height
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Decorative ellipses pattern
          _buildEllipsesPattern(),
        ],
      ),
    );
  }

  Widget _buildEllipsesPattern() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              -150.w +
                  (_animationController.value *
                      20.w), // Responsive parallax effect
              -50.h + (_animationController.value * 10.h),
            ),
            child: _buildEllipseGrid(),
          );
        },
      ),
    );
  }

  Widget _buildEllipseGrid() {
    final ellipsePositions = _generateEllipsePositions();

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
                    width: 80.w, // Responsive width
                    height: 80.h, // Responsive height
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

  List<Offset> _generateEllipsePositions() {
    // Generate a grid of ellipse positions adapted for mobile screen
    List<Offset> positions = [];

    // Create a pattern that works for mobile screens with responsive spacing
    final spacing = 60.0.w; // Responsive spacing

    for (int row = 0; row < 12; row++) {
      for (int col = 0; col < 6; col++) {
        double x =
            -200.w +
            (col * spacing) +
            ((row % 2) * 30.w); // Responsive offset every other row
        double y = -100.h + (row * 45.h); // Responsive row spacing

        if (x < 1.sw + 100.w && y < 1.sh + 100.h) {
          // Only add visible ellipses - using screen width/height
          positions.add(Offset(x, y));
        }
      }
    }

    return positions;
  }
}
