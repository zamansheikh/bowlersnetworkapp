import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../home/data/models/user_model.dart';
import '../cubit/overview_cubit.dart';
import '../cubit/overview_state.dart';
import '../widgets/metric_card.dart';
import '../widgets/performance_trends_chart.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        leading: Container(
          margin: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray200),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.pop(),
            color: AppColors.gray700,
            iconSize: 18,
          ),
        ),
        title: Text(
          'Overview',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.gray900,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: BlocBuilder<OverviewCubit, OverviewState>(
        builder: (context, state) {
          if (state is OverviewLoading || state is OverviewInitial) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryLimeGreen,
              ),
            );
          }

          if (state is OverviewError) {
            return _buildErrorState(context, state.message);
          }

          if (state is OverviewLoaded || state is OverviewPerformanceLoading) {
            final data = state is OverviewLoaded
                ? state
                : (state as OverviewPerformanceLoading);

            return RefreshIndicator(
              onRefresh: () => context.read<OverviewCubit>().refreshData(),
              color: AppColors.primaryLimeGreen,
              child: CustomScrollView(
                slivers: [
                  // Welcome Header
                  _buildWelcomeHeader(context),

                  // Stats Grid
                  _buildStatsGrid(context, data),

                  // Favorite Brands Section
                  // _buildFavoriteBrandsSection(context, data),

                  // Performance Chart Section
                  _buildPerformanceSection(context, data),

                  // Recent Activity Section
                  _buildRecentActivitySection(context, data),

                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red.shade400,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Error loading overview',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () => context.read<OverviewCubit>().loadOverviewData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLimeGreen,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildWelcomeHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          final userName = authState is Authenticated
              ? authState.user.name
              : 'User';
          final userAvatar =
              authState is Authenticated && authState.user is UserModel
              ? (authState.user as UserModel).profilePictureUrl
              : null;

          return Container(
            margin: EdgeInsets.all(AppSpacing.lg),
            padding: EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryLimeGreen, Color(0xFF6fa332)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryLimeGreen.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: userAvatar != null && userAvatar.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: userAvatar,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.white.withOpacity(0.2),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.white.withOpacity(0.2),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.white.withOpacity(0.2),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: AppSpacing.lg),

                // Welcome text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        userName,
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  SliverToBoxAdapter _buildStatsGrid(BuildContext context, dynamic data) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Stats',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // Top row - XP and Level
            Row(
              children: [
                Expanded(
                  child: _buildModernStatCard(
                    icon: Icons.star_rounded,
                    label: 'XP',
                    value: '1',
                    change: '+0 this week',
                    color: AppColors.primaryLimeGreen,
                    isPositive: true,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildModernStatCard(
                    icon: Icons.trending_up_rounded,
                    label: 'Level',
                    value: '1',
                    change: '+1 this week',
                    color: const Color(0xFF3B82F6),
                    isPositive: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),

            // Bottom row - Likes and Shares
            Row(
              children: [
                Expanded(
                  child: _buildModernStatCard(
                    icon: Icons.favorite_rounded,
                    label: 'Likes',
                    value: '128',
                    change: '+13 this week',
                    color: const Color(0xFFEC4899),
                    isPositive: true,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildModernStatCard(
                    icon: Icons.share_rounded,
                    label: 'Shares',
                    value: '32',
                    change: '+2 this week',
                    color: const Color(0xFF8B5CF6),
                    isPositive: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),

            // Additional stats row
            Row(
              children: [
                Expanded(
                  child: _buildModernStatCard(
                    icon: Icons.comment_rounded,
                    label: 'Comments',
                    value: '45',
                    change: '+4 this week',
                    color: const Color(0xFF10B981),
                    isPositive: true,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildModernStatCard(
                    icon: Icons.people_rounded,
                    label: 'Followers',
                    value: '245',
                    change: '+24 new followers',
                    color: const Color(0xFFF59E0B),
                    isPositive: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernStatCard({
    required IconData icon,
    required String label,
    required String value,
    required String change,
    required Color color,
    required bool isPositive,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w800,
              fontSize: 28,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            change,
            style: AppTextStyles.bodySmall.copyWith(
              color: isPositive ? AppColors.primaryLimeGreen : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildFavoriteBrandsSection(
    BuildContext context,
    dynamic data,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '❤️ Favorite Brands',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to brands page
                  },
                  child: Text(
                    'View All Brands',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryLimeGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildBrandCard('Storm Bowling'),
                  SizedBox(width: AppSpacing.md),
                  _buildBrandCard('Brunswick B...'),
                  SizedBox(width: AppSpacing.md),
                  _buildBrandCard('Dexter Shoes'),
                  SizedBox(width: AppSpacing.md),
                  _buildBrandCard('Add Brand'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandCard(String brandName) {
    final isAddCard = brandName == 'Add Brand';
    return Container(
      width: 100,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isAddCard ? AppColors.gray50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAddCard ? AppColors.gray300 : AppColors.gray200,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isAddCard ? AppColors.gray200 : AppColors.gray100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isAddCard ? Icons.add_rounded : Icons.image,
              color: isAddCard ? AppColors.gray500 : AppColors.gray400,
              size: 24,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            brandName,
            style: AppTextStyles.bodySmall.copyWith(
              color: isAddCard ? AppColors.gray600 : AppColors.gray900,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildPerformanceSection(
    BuildContext context,
    dynamic data,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Performance Trends',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.gray900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Monthly',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.gray700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.gray700,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xl),

              // Chart placeholder - using simple bars to match screenshot
              Container(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildChartBar('Jan', 200, AppColors.primaryLimeGreen),
                    _buildChartBar('Feb', 180, AppColors.primaryLimeGreen),
                    _buildChartBar('Mar', 220, AppColors.primaryLimeGreen),
                    _buildChartBar('Apr', 160, AppColors.primaryLimeGreen),
                    _buildChartBar('May', 190, AppColors.primaryLimeGreen),
                    _buildChartBar('Jun', 210, AppColors.primaryLimeGreen),
                  ],
                ),
              ),

              SizedBox(height: AppSpacing.lg),

              // Chart legend/info
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLimeGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Average Score',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartBar(String label, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: height * 0.6, // Scale down to fit
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.gray600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildRecentActivitySection(
    BuildContext context,
    dynamic data,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latest Content',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'New videos from BEK TV+',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray600,
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            _buildContentCard(
              title: 'Learn from the pros how to perfect your hook',
              isUnderDevelopment: true,
            ),

            SizedBox(height: AppSpacing.xl),

            Text(
              'Messages',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Recent messages from your network',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray600,
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            _buildContentCard(
              title: 'Chat with your bowling network',
              isUnderDevelopment: true,
            ),

            SizedBox(height: AppSpacing.xl),

            Text(
              'Upcoming Tournaments',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Tournaments you have registered for',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray600,
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            _buildContentCard(
              title: 'View upcoming tournaments',
              isUnderDevelopment: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard({
    required String title,
    required bool isUnderDevelopment,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isUnderDevelopment) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLimeGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryLimeGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.construction_rounded,
                    color: AppColors.primaryLimeGreen,
                    size: 16,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'FEATURE UNDER DEVELOPMENT',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryLimeGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),
          ],

          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray700,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          if (isUnderDevelopment) ...[
            SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Coming Soon',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray500,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
