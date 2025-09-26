import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../constants/colors.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  final String currentLocation;

  const MainShell({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final currentIndex = _getCurrentIndex();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray300.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 72.h,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                index: 0,
                currentIndex: currentIndex,
                route: '/',
              ),
              _buildNavItem(
                context: context,
                icon: Icons.message_outlined,
                activeIcon: Icons.message,
                label: 'Messages',
                index: 1,
                currentIndex: currentIndex,
                route: '/messages',
              ),
              _buildNavItem(
                context: context,
                icon: Icons.event_outlined,
                activeIcon: Icons.event,
                label: 'Events',
                index: 2,
                currentIndex: currentIndex,
                route: '/events',
              ),
              _buildNavItem(
                context: context,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                index: 3,
                currentIndex: currentIndex,
                route: '/profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required int currentIndex,
    required String route,
  }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryLimeGreen.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primaryLimeGreen : AppColors.gray500,
              size: 24.w,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppColors.primaryLimeGreen
                    : AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getCurrentIndex() {
    if (currentLocation.startsWith('/messages')) return 1;
    if (currentLocation.startsWith('/events')) return 2;
    if (currentLocation.startsWith('/profile')) return 3;
    return 0; // Home
  }
}
