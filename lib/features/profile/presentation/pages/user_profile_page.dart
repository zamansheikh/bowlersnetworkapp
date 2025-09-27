import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../home/data/models/user_model.dart';
import '../../../home/presentation/widgets/feed_post_card.dart';
import '../cubit/profile_cubit.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  VideoPlayerController? _videoController;
  late ProfileCubit _profileCubit;

  @override
  void initState() {
    super.initState();
    _profileCubit = getIt<ProfileCubit>();
    // Load user posts when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileCubit.loadUserPosts();
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _profileCubit.close();
    super.dispose();
  }

  void _initializeVideoPlayer(String videoUrl) {
    if (videoUrl.isNotEmpty) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _videoController?.setLooping(true);
            _videoController?.setVolume(0.0); // Muted
            _videoController?.play();
          }
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar to light content
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return BlocProvider.value(
      value: _profileCubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFEFEFEF), // Neutral 100
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              if (state.user is UserModel) {
                final userModel = state.user as UserModel;
                return _buildProfileView(userModel);
              } else {
                return _buildIncompleteProfileMessage(context);
              }
            }
            return _buildLoadingView();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
        backgroundColor: AppColors.primaryLimeGreen,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLimeGreen),
        ),
      ),
    );
  }

  Widget _buildIncompleteProfileMessage(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
        backgroundColor: AppColors.primaryLimeGreen,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline, size: 64.w, color: Colors.grey),
              SizedBox(height: 16.h),
              Text(
                'Profile Incomplete',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Complete your profile to access all features',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () => context.go('/complete-profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLimeGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Complete Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileView(UserModel user) {
    return Stack(
      children: [
        // Main scrollable content
        SingleChildScrollView(
          child: Column(
            children: [
              // Header section with background image/video
              _buildHeaderSection(user),

              // White content section with rounded corners
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5), // Neutral 100
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    children: [
                      // Profile info section
                      _buildProfileInfoSection(user),
                      _buildProfileDetails(user),
                      const SizedBox(height: 12),

                      // Stats grid
                      _buildStatsGrid(user),
                      const SizedBox(height: 12),

                      // Bowling statistics chart
                      _buildBowlingStatisticsChart(),
                      const SizedBox(height: 12),

                      // Social engagement cards row
                      _buildSocialEngagementCards(user),
                      const SizedBox(height: 12),

                      // Sponsors section
                      _buildSponsorsSection(user),
                      const SizedBox(height: 12),

                      // Posts section header
                      _buildPostsSectionHeader(),
                    ],
                  ),
                ),
              ),

              // Posts section
              _buildPostsListSection(),
            ],
          ),
        ),

        // Top status bar and navigation
        _buildTopNavigation(),
      ],
    );
  }

  Widget _buildHeaderSection(UserModel user) {
    return SizedBox(
      height: 240.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image/video
          if (user.isPro && user.introVideoUrl.isNotEmpty)
            _buildVideoPlayer(user.introVideoUrl)
          else if (user.coverPhotoUrl.isNotEmpty)
            Image.network(
              user.coverPhotoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF8BC342), Color(0xFF6fa332)],
                  ),
                ),
              ),
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8BC342), Color(0xFF6fa332)],
                ),
              ),
            ),

          // Dark overlay
          Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.51),
            ),
          ),

          // Play button overlay (if video)
          if (user.isPro && user.introVideoUrl.isNotEmpty)
            Center(
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopNavigation() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        child: Column(
          children: [
            // Status bar
            SizedBox(height: 32.h),

            // Navigation bar
            Container(
              height: 56.h,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  // Back button
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/back_button.svg',
                        height: 24.h,
                        width: 24.h,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                    ),
                  ),

                  // Title
                  Expanded(
                    child: Text(
                      'Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),

                  // Edit button
                  IconButton(
                    icon:  SvgPicture.asset( 'assets/icons/edit_button.svg',
                        height: 24.h,
                        width: 24.h,),
                    onPressed: () => context.push('/profile/edit'),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoSection(UserModel user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Profile picture
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40.r),
            border: Border.all(color: Colors.white, width: 2.w),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(38.r),
            child: user.profilePictureUrl.isNotEmpty
                ? Image.network(
                    user.profilePictureUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Text(
                          user.firstName.isNotEmpty
                              ? user.firstName[0].toUpperCase()
                              : user.name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF8BC342),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        user.firstName.isNotEmpty
                            ? user.firstName[0].toUpperCase()
                            : user.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8BC342),
                        ),
                      ),
                    ),
                  ),
          ),
        ),

        // Level badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFE2F0CF), // Lime green 200
            borderRadius: BorderRadius.circular(50.r),
          ),
          child: Text(
            'Level 3',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetails(UserModel user) {
    return Column(
      children: [
        SizedBox(height: 20.h),

        // User info and stats section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Name and email section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(width: 2.w),
                    if (user.isPro)
                      Icon(Icons.verified, color: Colors.blue, size: 16.sp),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF7D7D7D),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),

            // Followers and following stats
            Row(
              children: [
                Column(
                  children: [
                    Text(
                      '1.5k', // You can replace with actual data
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      'Followers',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF7D7D7D),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16.w),
                Column(
                  children: [
                    Text(
                      '0',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      'Following',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF7D7D7D),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid(UserModel user) {
    return Column(
      children: [
        // First row of stats
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.star,
                iconColor: const Color(0xFFFFCF2E),
                iconBackground: const Color(0xFFFFCF2E).withValues(alpha: 0.15),
                value: user.xp.toString(),
                label: 'XP',
              ),
            ),
            SizedBox(width: 11.w),
            Expanded(
              child: _buildStatCard(
                icon: Icons.emoji_events,
                iconColor: const Color(0xFF3B82F6),
                iconBackground: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                value: user.stats.highGame.toString(),
                label: 'High game',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Second row of stats
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.poll,
                iconColor: const Color(0xFF8A38F5),
                iconBackground: const Color(0xFF8A38F5).withValues(alpha: 0.15),
                value: user.stats.averageScore.toStringAsFixed(1),
                label: 'Average Score',
              ),
            ),
            SizedBox(width: 11.w),
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                iconColor: const Color(0xFFFC5356),
                iconBackground: const Color(0xFFFC5356).withValues(alpha: 0.15),
                value: user.stats.highSeries.toString(),
                label: 'High Series',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String value,
    required String label,
  }) {
    return Container(
      width: 162.w,
      height: 120.h,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: Icon(icon, color: iconColor, size: 16.sp),
          ),

          // Value and label
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF7D7D7D),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBowlingStatisticsChart() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          // Header with title and dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bowling Statists',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEFEFEF)),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  children: [
                    Text(
                      'Monthly',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF7B7878),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: const Color(0xFF7B7878),
                      size: 16.sp,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Chart section
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Y-axis labels
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildYAxisLabel('30'),
                  SizedBox(height: 12.h),
                  _buildYAxisLabel('25'),
                  SizedBox(height: 12.h),
                  _buildYAxisLabel('20'),
                  SizedBox(height: 12.h),
                  _buildYAxisLabel('15'),
                  SizedBox(height: 12.h),
                  _buildYAxisLabel('10'),
                  SizedBox(height: 12.h),
                  _buildYAxisLabel('5'),
                  SizedBox(height: 12.h),
                  _buildYAxisLabel('0'),
                ],
              ),

              SizedBox(width: 12.w),

              // Bar chart
              Expanded(
                child: SizedBox(
                  height: 179.h,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 30,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const months = [
                                'Jan',
                                'Feb',
                                'Mar',
                                'Apr',
                                'Jun',
                                'Jul',
                                'Aug',
                              ];
                              if (value.toInt() < months.length) {
                                return Text(
                                  months[value.toInt()],
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF666666),
                                    fontFamily: 'Poppins',
                                  ),
                                );
                              }
                              return const Text('');
                            },
                            reservedSize: 20.h,
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        _buildBarGroup(0, 25, 30), // Jan - 25 out of 30
                        _buildBarGroup(1, 20, 30), // Feb - 20 out of 30
                        _buildBarGroup(2, 10, 30), // Mar - 10 out of 30
                        _buildBarGroup(3, 15, 30), // Apr - 15 out of 30
                        _buildBarGroup(4, 30, 30), // Jun - 30 out of 30
                        _buildBarGroup(5, 20, 30), // Jul - 20 out of 30
                        _buildBarGroup(6, 5, 30), // Aug - 5 out of 30
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYAxisLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF666666),
        fontFamily: 'Poppins',
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double actualValue, double maxValue) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: actualValue,
          color: const Color(0xFF8BC342), // Lime green 500
          width: 30,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialEngagementCards(UserModel user) {
    return SizedBox(
      height: 115.h,
      child: Row(
        children: [
          Expanded(
            child: _buildEngagementCard(
              icon: Icons.people,
              iconColor: const Color(0xFFFC5356),
              iconBackground: const Color(0xFFFC5356).withValues(alpha: 0.15),
              value: user.followerCount >= 1000
                  ? '${(user.followerCount / 1000).toStringAsFixed(1)}k'
                  : user.followerCount.toString(),
              label: 'Followers',
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _buildEngagementCard(
              icon: Icons.sports,
              iconColor: const Color(0xFF3B82F6),
              iconBackground: const Color(0xFF3B82F6).withValues(alpha: 0.15),
              value: user.stats.experience >= 1000
                  ? '${(user.stats.experience / 1000).toStringAsFixed(1)}k'
                  : user.stats.experience.toString(),
              label: 'Experience',
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _buildEngagementCard(
              icon: Icons.emoji_events,
              iconColor: const Color(0xFF8A38F5),
              iconBackground: const Color(0xFF8A38F5).withValues(alpha: 0.15),
              value: user.level.toString(),
              label: 'Level',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String value,
    required String label,
  }) {
    return Container(
      height: 115.h,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: Icon(icon, color: iconColor, size: 16.sp),
          ),

          // Value and label
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF7D7D7D),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSponsorsSection(UserModel user) {
    // Pro players show sponsors, non-pro players show favorite brands
    final List<BrandModel> brandsToShow = user.isPro
        ? user.sponsors
        : user.favoriteBrands;
    final String sectionTitle = user.isPro ? 'Sponsors' : 'Favorite Brands';

    if (brandsToShow.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionTitle,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            height: 106.h,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                user.isPro ? 'No sponsors yet' : 'No favorite brands yet',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 106.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: brandsToShow.length,
            separatorBuilder: (context, index) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final brand = brandsToShow[index];
              return _buildSponsorCard(brand);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSponsorCard(BrandModel brand) {
    return Container(
      width: 106.w,
      height: 106.h,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Brand logo
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r)),
              child: brand.logoUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.network(
                        brand.logoUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.business,
                              color: Colors.grey,
                              size: 24.sp,
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.business,
                        color: Colors.grey,
                        size: 24.sp,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 8.h),
          // Brand name
          Text(
            brand.name,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPostsSectionHeader() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Posts',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildPostsListSection() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          return _buildPostsContent(
            state.posts,
            state.isLoadingPosts,
            state.postsError,
          );
        }
        return _buildPostsContent(null, true, null);
      },
    );
  }

  Widget _buildPostsContent(
    List<dynamic>? posts,
    bool isLoading,
    String? error,
  ) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 64.sp, color: Colors.grey[400]),
              SizedBox(height: 16.h),
              Text(
                'Failed to load posts',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 8.h),
              Text(
                error,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    if (posts == null || posts.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            children: [
              Icon(Icons.post_add, size: 64.sp, color: Colors.grey[400]),
              SizedBox(height: 16.h),
              Text(
                'No posts yet',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 8.h),
              Text(
                'Your posts will appear here',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: FeedPostCard(
                post: posts[index],
                postIndex: index,
                isMyPost: true,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVideoPlayer(String videoUrl) {
    // Initialize video controller if not already done
    if (_videoController == null || _videoController!.dataSource != videoUrl) {
      _initializeVideoPlayer(videoUrl);
    }

    return Container(
      color: Colors.black,
      child: _videoController != null && _videoController!.value.isInitialized
          ? Stack(
              fit: StackFit.expand,
              children: [
                AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
                // Dark overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                ),
                // Play/Pause button
                Positioned(
                  bottom: 16.h,
                  right: 16.w,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_videoController!.value.isPlaying) {
                          _videoController!.pause();
                        } else {
                          _videoController!.play();
                        }
                      });
                    },
                    child: Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _videoController!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16.h),
                    Text(
                      'Loading Video...',
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
