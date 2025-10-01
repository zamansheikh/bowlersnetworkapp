import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../cubit/teams_cubit.dart';
import '../cubit/teams_state.dart';
import '../widgets/team_card.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/di/injection.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  final TextEditingController _searchController = TextEditingController();
  late final TeamsCubit _teamsCubit;

  @override
  void initState() {
    super.initState();
    _teamsCubit = getIt<TeamsCubit>();
    _teamsCubit.getUserTeams();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _teamsCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Column(
                  children: [
                    // Search Bar
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search teams...',
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.gray400,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.gray400,
                    size: 20.sp,
                  ),
                  filled: true,
                  fillColor: AppColors.gray50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                onChanged: (value) {
                  // Implement search filtering if needed
                },
              ),
            ),
            
                    // Teams List
                    Expanded(
                      child: BlocConsumer<TeamsCubit, TeamsState>(
                listener: (context, state) {
                  if (state is TeamsActionSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else if (state is TeamsActionError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is TeamsLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryLimeGreen,
                      ),
                    );
                  }
                  
                  if (state is TeamsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48.sp,
                            color: AppColors.error,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            state.message,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.gray600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () => _teamsCubit.getUserTeams(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryLimeGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  if (state is TeamsLoaded) {
                    if (state.teams.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.group_outlined,
                              size: 64.sp,
                              color: AppColors.gray300,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No Teams Yet',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray600,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Create your first team to start\ncollaborating with other players',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.gray500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24.h),
                            ElevatedButton.icon(
                              onPressed: () => _showCreateTeamDialog(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryLimeGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 12.h,
                                ),
                              ),
                              icon: Icon(Icons.add, size: 18.sp),
                              label: Text(
                                'Create Team',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return RefreshIndicator(
                      onRefresh: () async => _teamsCubit.getUserTeams(),
                      color: AppColors.primaryLimeGreen,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        itemCount: state.teams.length,
                        itemBuilder: (context, index) {
                          final team = state.teams[index];
                          return TeamCard(
                            team: team,
                            onTap: () {
                              context.push('/teams/${team.teamId}');
                            },
                            onEdit: () => _showEditTeamDialog(context, team.name, team.teamId),
                            onDelete: () => _showDeleteTeamDialog(context, team.teamId, team.name),
                          );
                        },
                      ),
                    );
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray200, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'My Teams',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showCreateTeamDialog(context),
            icon: Icon(
              Icons.add,
              color: AppColors.primaryLimeGreen,
              size: 24.sp,
            ),
            tooltip: 'Create Team',
          ),
        ],
      ),
    );
  }

  void _showCreateTeamDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Create Team',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Team Name',
                hintText: 'Enter team name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md.w,
                  vertical: AppSpacing.md.h,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.gray600,
                fontSize: 14.sp,
              ),
            ),
          ),
          BlocProvider.value(
            value: _teamsCubit,
            child: BlocConsumer<TeamsCubit, TeamsState>(
              listener: (blocContext, state) {
                if (state is TeamCreationSuccess) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Team "${state.createdTeam.name}" created successfully!'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (state is TeamCreationError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (blocContext, state) {
              final isLoading = state is TeamCreationLoading;
              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        final teamName = nameController.text.trim();
                        if (teamName.isNotEmpty) {
                          _teamsCubit.createTeam(name: teamName);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLimeGreen,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Create',
                        style: TextStyle(fontSize: 14.sp),
                      ),
              );
            },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditTeamDialog(BuildContext context, String currentName, int teamId) {
    final TextEditingController nameController = TextEditingController(text: currentName);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Edit Team',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Team Name',
                hintText: 'Enter team name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.gray600,
                fontSize: 14.sp,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final teamName = nameController.text.trim();
              if (teamName.isNotEmpty && teamName != currentName) {
                // TODO: Implement team update functionality
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Team edit functionality will be implemented'),
                  ),
                );
              } else {
                Navigator.of(dialogContext).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLimeGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Update',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteTeamDialog(BuildContext context, int teamId, String teamName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Delete Team',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$teamName"? This action cannot be undone.',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.gray600,
                fontSize: 14.sp,
              ),
            ),
          ),
          BlocConsumer<TeamsCubit, TeamsState>(
            listener: (context, state) {
              if (state is TeamsActionSuccess) {
                Navigator.of(dialogContext).pop();
              }
            },
            builder: (context, state) {
              final isLoading = state is TeamsActionLoading;
              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        _teamsCubit.deleteTeam(teamId);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Delete',
                        style: TextStyle(fontSize: 14.sp),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}