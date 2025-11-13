import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/pro_player.dart';
import '../cubit/pro_players_cubit.dart';
import '../widgets/player_card.dart';

class ProPlayersPage extends StatefulWidget {
  const ProPlayersPage({super.key});

  @override
  State<ProPlayersPage> createState() => _ProPlayersPageState();
}

class _ProPlayersPageState extends State<ProPlayersPage> {
  late ProPlayersCubit _cubit;

  // Define multiple color themes for variety
  final List<Map<String, Color>> _colorThemes = [
    {
      'primary': const Color(0xFF8BC342),
      'secondary': const Color(0xFF385019),
      'accent': const Color(0xFF75B11D),
    },
    {
      'primary': const Color(0xFF3B82F6),
      'secondary': const Color(0xFF1E3A8A),
      'accent': const Color(0xFF60A5FA),
    },
    {
      'primary': const Color(0xFF8B5CF6),
      'secondary': const Color(0xFF4C1D95),
      'accent': const Color(0xFFA78BFA),
    },
    {
      'primary': const Color(0xFFF59E0B),
      'secondary': const Color(0xFF92400E),
      'accent': const Color(0xFFFBBF24),
    },
    {
      'primary': const Color(0xFFEC4899),
      'secondary': const Color(0xFFBE185D),
      'accent': const Color(0xFFF472B6),
    },
    {
      'primary': const Color(0xFF10B981),
      'secondary': const Color(0xFF047857),
      'accent': const Color(0xFF34D399),
    },
    {
      'primary': const Color(0xFFEF4444),
      'secondary': const Color(0xFFB91C1C),
      'accent': const Color(0xFFF87171),
    },
    {
      'primary': const Color(0xFF06B6D4),
      'secondary': const Color(0xFF0E7490),
      'accent': const Color(0xFF67E8F9),
    },
  ];

  @override
  void initState() {
    super.initState();
    _cubit = getIt<ProPlayersCubit>();
    _cubit.loadProPlayers();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.gray50,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.gray900,
          leading: Container(
            margin: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.gray200),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => context.pop(),
              color: AppColors.gray700,
              iconSize: 18.sp,
            ),
          ),
          title: Text(
            'Professional Bowlers',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryLimeGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primaryLimeGreen.withValues(alpha: 0.3),
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => _cubit.loadProPlayers(),
                color: AppColors.primaryLimeGreen,
                iconSize: 20.sp,
                tooltip: 'Refresh',
              ),
            ),
          ],
        ),
        body: BlocConsumer<ProPlayersCubit, ProPlayersState>(
          listener: (context, state) {
            if (state is ProPlayersError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  action: SnackBarAction(
                    label: 'Retry',
                    textColor: Colors.white,
                    onPressed: () => _cubit.loadProPlayers(),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProPlayersLoading) {
              return _buildLoadingView();
            }

            if (state is ProPlayersLoaded) {
              return _buildPlayersView(state.players);
            }

            if (state is ProPlayersError) {
              return _buildErrorView(state.message);
            }

            return _buildEmptyView();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8BC342)),
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading professional bowlers...',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersView(List<ProPlayer> players) {
    if (players.isEmpty) {
      return _buildEmptyView();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          SizedBox(height: 24.h),
          // Header Section
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF8BC342).withValues(alpha: 0.1),
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: const Color(0xFF8BC342).withValues(alpha: 0.2),
                width: 1.w,
              ),
            ),
            child: Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8BC342).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.star,
                        color: Color(0xFF8BC342),
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Professional Bowlers',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF385019),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  'Connect with professional bowlers from around the community',
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatChip(
                      '${players.length} Pro Players',
                      Icons.people,
                    ),
                    SizedBox(width: 12.w),
                    _buildStatChip('Verified Profiles', Icons.verified),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          // Players Grid
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              final theme = _colorThemes[index % _colorThemes.length];

              return Column(
                children: [
                  Center(
                    child: PlayerCard(
                      player: player,
                      primaryColor: theme['primary']!,
                      secondaryColor: theme['secondary']!,
                      accentColor: theme['accent']!,
                      onTap: () => _navigateToPlayerDetail(player),
                      onFollow: () => _toggleFollow(player),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              );
            },
          ),

          // Bottom Padding
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildStatChip(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFF8BC342).withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: const Color(0xFF8BC342)),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: Color(0xFF385019),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
            ),
            SizedBox(height: 24.h),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => _cubit.loadProPlayers(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8BC342),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: const Color(0xFF8BC342).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                Icons.star_outline,
                size: 64.sp,
                color: Color(0xFF8BC342),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No Pro Players Found',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFF385019),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'Check back later for professional bowlers to connect with.',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => _cubit.loadProPlayers(),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8BC342),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPlayerDetail(ProPlayer player) {
    context.push(
      '/player/${player.username}',
      extra: {'userId': player.userId.toString()},
    );
  }

  void _toggleFollow(ProPlayer player) {
    _cubit.toggleFollowPlayer(player.userId);
  }
}
