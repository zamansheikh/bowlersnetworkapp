import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../cubit/teams_cubit.dart';
import '../cubit/teams_state.dart';
import '../widgets/team_member_card.dart';
import '../../domain/entities/team.dart';
import '../../domain/entities/team_member.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_utils.dart' as date_utils;
import '../../../../core/di/injection.dart';

class TeamDetailsPage extends StatefulWidget {
  final String teamId;

  const TeamDetailsPage({
    super.key,
    required this.teamId,
  });

  @override
  State<TeamDetailsPage> createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage>
    with SingleTickerProviderStateMixin {
  late final TeamsCubit _teamsCubit;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _teamsCubit = getIt<TeamsCubit>();
    _tabController = TabController(length: 2, vsync: this);
    _teamsCubit.getTeamDetails(int.parse(widget.teamId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _teamsCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<TeamsCubit, TeamsState>(
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
            if (state is TeamDetailsLoading) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black87,
                    ),
                  ),
                ),
                body: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryLimeGreen,
                  ),
                ),
              );
            }

            if (state is TeamDetailsError) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black87,
                    ),
                  ),
                  title: Text(
                    'Team Details',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                body: Center(
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
                        onPressed: () => _teamsCubit.getTeamDetails(int.parse(widget.teamId)),
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
                ),
              );
            }

            if (state is TeamDetailsLoaded) {
              return _buildTeamDetails(context, state.team, state.members);
            }

            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black87,
                  ),
                ),
              ),
              body: Center(
                child: Text('Loading team details...'),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTeamDetails(BuildContext context, Team team, List<TeamMember> members) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            pinned: true,
            expandedHeight: 200.h,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Icon(
                Icons.arrow_back,
                color: AppColors.onSurface,
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showEditTeamDialog(context, team);
                      break;
                    case 'invite':
                      _showInviteMemberDialog(context, team.teamId);
                      break;
                    case 'leave':
                      _showLeaveTeamDialog(context, team);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16.sp, color: AppColors.info),
                        SizedBox(width: 8.w),
                        Text('Edit Team', style: TextStyle(fontSize: 14.sp)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'invite',
                    child: Row(
                      children: [
                        Icon(Icons.person_add, size: 16.sp, color: AppColors.primaryLimeGreen),
                        SizedBox(width: 8.w),
                        Text('Invite Member', style: TextStyle(fontSize: 14.sp)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'leave',
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app, size: 16.sp, color: AppColors.error),
                        SizedBox(width: 8.w),
                        Text('Leave Team', style: TextStyle(fontSize: 14.sp)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryLimeGreen.withOpacity(0.1),
                      AppColors.white,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: kToolbarHeight + 20.h),
                    // Team Logo
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryLimeGreen.withOpacity(0.1),
                        border: Border.all(
                          color: AppColors.primaryLimeGreen.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: team.logoUrl != null && team.logoUrl!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                team.logoUrl!,
                                width: 80.w,
                                height: 80.w,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildDefaultTeamLogo(team.name),
                              ),
                            )
                          : _buildDefaultTeamLogo(team.name),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      team.name,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      team.displayMemberCount,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryLimeGreen,
              unselectedLabelColor: AppColors.gray500,
              indicatorColor: AppColors.primaryLimeGreen,
              tabs: [
                Tab(text: 'Members (${members.length})'),
                Tab(text: 'Activity'),
              ],
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMembersTab(members),
          _buildActivityTab(),
        ],
      ),
    );
  }

  Widget _buildMembersTab(List<TeamMember> members) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return TeamMemberCard(
          member: member,
          showRemoveAction: true,
          onTap: () {
            // Navigate to member profile
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Navigate to ${member.member.fullName}\'s profile'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onRemove: () => _showRemoveMemberDialog(context, member),
        );
      },
    );
  }

  Widget _buildActivityTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline,
            size: 48.sp,
            color: AppColors.gray300,
          ),
          SizedBox(height: 16.h),
          Text(
            'Team Activity',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.gray600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Activity feed will show team events,\nmember actions, and updates',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultTeamLogo(String teamName) {
    return Container(
      width: 80.w,
      height: 80.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLimeGreen.withOpacity(0.8),
            AppColors.primaryLimeGreen,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          teamName.isNotEmpty ? teamName[0].toUpperCase() : 'T',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showEditTeamDialog(BuildContext context, Team team) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Team editing functionality will be implemented'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInviteMemberDialog(BuildContext context, int teamId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Member invitation functionality will be implemented'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLeaveTeamDialog(BuildContext context, Team team) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Leave Team',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
        ),
        content: Text(
          'Are you sure you want to leave "${team.name}"? You will need to be re-invited to join again.',
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
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Leave team functionality will be implemented'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Leave',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveMemberDialog(BuildContext context, TeamMember member) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Remove Member',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
        ),
        content: Text(
          'Are you sure you want to remove ${member.member.fullName} from the team?',
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
                        _teamsCubit.removeMemberFromTeam(
                          teamId: int.parse(widget.teamId),
                          userId: member.member.userId,
                        );
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
                        'Remove',
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