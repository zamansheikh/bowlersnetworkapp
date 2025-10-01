import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/tournament.dart';
import '../bloc/tournament_cubit.dart';
import '../bloc/tournament_state.dart';

class TournamentDetailPage extends StatefulWidget {
  final int tournamentId;
  final Tournament? tournament;

  const TournamentDetailPage({
    super.key,
    required this.tournamentId,
    this.tournament,
  });

  @override
  State<TournamentDetailPage> createState() => _TournamentDetailPageState();
}

class _TournamentDetailPageState extends State<TournamentDetailPage> {
  Tournament? _currentTournament;

  @override
  void initState() {
    super.initState();
    _currentTournament = widget.tournament;

    // If we don't have tournament data, we could load it here
    // For now, we'll assume it's passed from the list
    if (_currentTournament == null) {
      // In a real app, you might want to load the specific tournament
      context.read<TournamentCubit>().loadTournaments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<TournamentCubit, TournamentState>(
        listener: (context, state) {
          if (state is TournamentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is TournamentRegistrationSuccess) {
            setState(() {
              _currentTournament = state.tournament;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.wasRegistered
                      ? 'Successfully registered for ${state.tournament.name}'
                      : 'Successfully unregistered from ${state.tournament.name}',
                ),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          final tournament = _currentTournament;

          if (tournament == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryLimeGreen,
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(tournament),
              SliverToBoxAdapter(child: _buildContent(tournament, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(Tournament tournament) {
    return SliverAppBar(
      expandedHeight: 200.h,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primaryLimeGreen,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.white,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          tournament.name,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryLimeGreen,
                AppColors.primaryLimeGreen.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 60.h,
                right: 20.w,
                child: tournament.isRegistered
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Registered',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Tournament tournament, TournamentState state) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tournament Info Card
          _buildInfoCard(tournament),

          SizedBox(height: AppSpacing.lg),

          // Registration Card
          _buildRegistrationCard(tournament, state),

          SizedBox(height: AppSpacing.lg),

          // Description Card (if available)
          if (tournament.description != null &&
              tournament.description!.isNotEmpty)
            _buildDescriptionCard(tournament),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Tournament tournament) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tournament Information',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // Information Grid
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildInfoItem(
                        Icons.calendar_today,
                        'Start Date',
                        DateFormat(
                          'MMM dd, yyyy • h:mm a',
                        ).format(tournament.startDateTime),
                        AppColors.info,
                      ),
                      SizedBox(height: AppSpacing.md),
                      _buildInfoItem(
                        Icons.attach_money,
                        'Registration Fee',
                        '\$${tournament.regFee.toStringAsFixed(0)}',
                        AppColors.warning,
                      ),
                      SizedBox(height: AppSpacing.md),
                      _buildInfoItem(
                        Icons.sports,
                        'Access Type',
                        tournament.accessType,
                        AppColors.gray600,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    children: [
                      _buildInfoItem(
                        Icons.access_time,
                        'Registration Deadline',
                        DateFormat(
                          'MMM dd, yyyy • h:mm a',
                        ).format(tournament.regDeadlineDateTime),
                        AppColors.error,
                      ),
                      SizedBox(height: AppSpacing.md),
                      _buildInfoItem(
                        Icons.people,
                        'Format',
                        tournament.format,
                        AppColors.primaryLimeGreen,
                      ),
                      SizedBox(height: AppSpacing.md),
                      _buildInfoItem(
                        Icons.location_on,
                        'Location',
                        tournament.address.isEmpty
                            ? 'Location TBD'
                            : tournament.address,
                        AppColors.error,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.gray600,
            fontSize: 10.sp,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.gray900,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegistrationCard(Tournament tournament, TournamentState state) {
    final isRegistering =
        state is TournamentRegistering && state.tournamentId == tournament.id;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tournament Registration',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // Registration Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Registration Fee',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
                Text(
                  '\$${tournament.regFee.toStringAsFixed(0)}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Format',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
                Text(
                  tournament.format,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
                Text(
                  tournament.isRegistered ? 'Registered' : 'Open',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: tournament.isRegistered
                        ? AppColors.success
                        : AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.lg),

            // Registration Button
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: isRegistering
                    ? null
                    : () => _handleRegistration(tournament),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tournament.isRegistered
                      ? Colors.transparent
                      : AppColors.primaryLimeGreen,
                  side: tournament.isRegistered
                      ? const BorderSide(color: AppColors.error, width: 2)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isRegistering
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            tournament.isRegistered
                                ? AppColors.error
                                : AppColors.white,
                          ),
                        ),
                      )
                    : Text(
                        tournament.isRegistered
                            ? 'Unregister from Tournament'
                            : 'Register for Tournament',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: tournament.isRegistered
                              ? AppColors.error
                              : AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            SizedBox(height: AppSpacing.sm),

            // Registration Deadline Notice
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.info),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Registration closes on ${DateFormat('MMM dd, yyyy').format(tournament.regDeadlineDateTime)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(Tournament tournament) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              tournament.description!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRegistration(Tournament tournament) {
    context.read<TournamentCubit>().handleTournamentRegistration(tournament);
  }
}
