import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/tournament.dart';

class TournamentCard extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback onTap;
  final VoidCallback onRegister;
  final bool isRegistering;
  final String? distance; // Distance from selected location

  const TournamentCard({
    super.key,
    required this.tournament,
    required this.onTap,
    required this.onRegister,
    this.isRegistering = false,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and registration status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tournament.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                      ),
                    ),
                  ),
                  if (tournament.isRegistered)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Registered',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: AppSpacing.sm),

              // Tournament details
              _buildDetailRow(
                Icons.location_on_outlined,
                tournament.address.isEmpty
                    ? 'Location TBD'
                    : distance != null
                    ? '${tournament.address} • $distance'
                    : tournament.address,
                AppColors.error,
              ),

              SizedBox(height: AppSpacing.xs),

              _buildDetailRow(
                Icons.calendar_today_outlined,
                DateFormat('MMM dd, yyyy').format(tournament.startDateTime),
                AppColors.info,
              ),

              SizedBox(height: AppSpacing.xs),

              _buildDetailRow(
                Icons.attach_money_rounded,
                '\$${tournament.regFee.toStringAsFixed(0)}',
                AppColors.warning,
              ),

              SizedBox(height: AppSpacing.xs),

              _buildDetailRow(
                Icons.people_outline,
                tournament.format,
                AppColors.primaryLimeGreen,
              ),

              SizedBox(height: AppSpacing.xs),

              _buildDetailRow(
                Icons.access_time,
                'Register by ${DateFormat('MMM dd, yyyy').format(tournament.regDeadlineDateTime)}',
                AppColors.gray600,
              ),

              SizedBox(height: AppSpacing.md),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLimeGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: onTap,
                          child: Center(
                            child: Text(
                              'View Details',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: AppSpacing.sm),

                  Expanded(
                    child: Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: tournament.isRegistered
                            ? Colors.transparent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: tournament.isRegistered
                              ? AppColors.error
                              : AppColors.primaryLimeGreen,
                          width: 2,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: isRegistering ? null : onRegister,
                          child: Center(
                            child: isRegistering
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        tournament.isRegistered
                                            ? AppColors.error
                                            : AppColors.primaryLimeGreen,
                                      ),
                                    ),
                                  )
                                : Text(
                                    tournament.isRegistered
                                        ? 'Unregister'
                                        : 'Register',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: tournament.isRegistered
                                          ? AppColors.error
                                          : AppColors.primaryLimeGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
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

  Widget _buildDetailRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray600,
              fontSize: 12.sp,
            ),
          ),
        ),
      ],
    );
  }
}
