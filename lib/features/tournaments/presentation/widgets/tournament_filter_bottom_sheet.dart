import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../bloc/tournament_cubit.dart';
import '../bloc/tournament_state.dart';

class TournamentFilterBottomSheet extends StatelessWidget {
  final TournamentLoaded state;

  const TournamentFilterBottomSheet({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          SizedBox(height: AppSpacing.md),

          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Filter Tournaments',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<TournamentCubit>().resetFilters();
                  Navigator.pop(context);
                },
                child: Text(
                  'Reset',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.lg),

          // Format Filter Section
          Text(
            'Tournament Format',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.gray800,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          _buildFormatFilters(context, state),

          SizedBox(height: AppSpacing.lg),

          // Access Level Filter Section
          Text(
            'Entry Fee',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.gray800,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          _buildAccessLevelFilters(context, state),

          SizedBox(height: AppSpacing.xl),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLimeGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatFilters(BuildContext context, TournamentLoaded state) {
    final formats = ['Singles', 'Doubles', 'Teams'];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: formats.map((format) {
        final isSelected = state.selectedFormats.contains(format);
        
        return GestureDetector(
          onTap: () => context.read<TournamentCubit>().toggleFormatFilter(format),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.primaryLimeGreen 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected 
                    ? AppColors.primaryLimeGreen 
                    : AppColors.gray400,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getFormatIcon(format),
                  size: 16,
                  color: isSelected ? AppColors.white : AppColors.gray600,
                ),
                SizedBox(width: 6),
                Text(
                  format,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? AppColors.white : AppColors.gray600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAccessLevelFilters(BuildContext context, TournamentLoaded state) {
    final accessLevels = ['Under \$50'];
    
    return Column(
      children: accessLevels.map((level) {
        final isSelected = state.selectedAccessLevels.contains(level);
        
        return GestureDetector(
          onTap: () => context.read<TournamentCubit>().toggleAccessLevelFilter(level),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.primaryLimeGreen.withValues(alpha: 0.15)
                  : AppColors.gray50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? AppColors.primaryLimeGreen 
                    : AppColors.gray200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.attach_money,
                  size: 20,
                  color: isSelected ? AppColors.primaryLimeGreen : AppColors.gray600,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    level,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected ? AppColors.primaryLimeGreen : AppColors.gray700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    size: 20,
                    color: AppColors.primaryLimeGreen,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getFormatIcon(String format) {
    switch (format) {
      case 'Singles':
        return Icons.person;
      case 'Doubles':
        return Icons.people;
      case 'Teams':
        return Icons.groups;
      default:
        return Icons.emoji_events;
    }
  }
}