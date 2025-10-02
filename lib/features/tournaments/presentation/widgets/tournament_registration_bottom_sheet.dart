import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../teams/domain/entities/team.dart';
import '../../../teams/presentation/cubit/teams_cubit.dart';
import '../../../teams/presentation/cubit/teams_state.dart';
import '../../domain/entities/tournament.dart';
import '../bloc/tournament_cubit.dart';

class TournamentRegistrationBottomSheet extends StatefulWidget {
  final Tournament tournament;

  const TournamentRegistrationBottomSheet({
    super.key,
    required this.tournament,
  });

  @override
  State<TournamentRegistrationBottomSheet> createState() =>
      _TournamentRegistrationBottomSheetState();
}

class _TournamentRegistrationBottomSheetState
    extends State<TournamentRegistrationBottomSheet> {
  Team? _selectedTeam;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    // Load teams if it's not a singles tournament
    if (widget.tournament.format != 'Singles') {
      context.read<TeamsCubit>().getUserTeams();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: AppSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Register for Tournament',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray900,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        widget.tournament.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.gray500),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tournament info card
                  _buildTournamentInfoCard(),

                  SizedBox(height: AppSpacing.lg),

                  // Registration type info
                  _buildRegistrationTypeInfo(),

                  SizedBox(height: AppSpacing.lg),

                  // Team selection (if not singles)
                  if (widget.tournament.format != 'Singles') ...[
                    _buildTeamSelection(),
                    SizedBox(height: AppSpacing.lg),
                  ],
                ],
              ),
            ),
          ),

          // Action buttons
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.gray200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                    backgroundColor: Colors.transparent,
                    textColor: AppColors.gray700,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: CustomButton(
                    text: _isRegistering ? 'Registering...' : 'Register Now',
                    onPressed: _canRegister() ? _handleRegistration : null,
                    isLoading: _isRegistering,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentInfoCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: AppColors.primaryLimeGreen,
                size: 20,
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  widget.tournament.name,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            Icons.location_on_outlined,
            widget.tournament.address.isNotEmpty
                ? widget.tournament.address
                : 'Location TBD',
          ),
          SizedBox(height: AppSpacing.xs),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            DateFormat('MMM dd, yyyy').format(widget.tournament.startDateTime),
          ),
          SizedBox(height: AppSpacing.xs),
          _buildInfoRow(
            Icons.attach_money_outlined,
            '\$${widget.tournament.regFee.toStringAsFixed(2)}',
          ),
          SizedBox(height: AppSpacing.xs),
          _buildInfoRow(Icons.group_outlined, widget.tournament.format),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.gray500),
        SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray700),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationTypeInfo() {
    if (widget.tournament.format == 'Singles') {
      return Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.primaryLimeGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primaryLimeGreen.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primaryLimeGreen,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Individual Registration',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primaryLimeGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'You will be registered as an individual player for this singles tournament.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.info.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.info,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Team Registration Required',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Select a team to register for this ${widget.tournament.format.toLowerCase()} tournament.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTeamSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Team *',
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.gray800,
          ),
        ),
        SizedBox(height: AppSpacing.sm),

        BlocBuilder<TeamsCubit, TeamsState>(
          builder: (context, state) {
            if (state is TeamsLoading) {
              return Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gray300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: CircularProgressIndicator()),
              );
            } else if (state is TeamsError) {
              return Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        state.message,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is TeamsLoaded) {
              if (state.teams.isEmpty) {
                return _buildNoTeamsState();
              }

              return _buildTeamsList(state.teams);
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildNoTeamsState() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.group_outlined,
              color: AppColors.gray400,
              size: 24,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'No teams available',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.gray700,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Create a team first to register for this tournament',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsList(List<Team> teams) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: teams.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final team = teams[index];
          final isSelected = _selectedTeam?.teamId == team.teamId;

          return ListTile(
            onTap: () => setState(() => _selectedTeam = team),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: team.logoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        team.logoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.group, color: AppColors.gray500),
                      ),
                    )
                  : const Icon(Icons.group, color: AppColors.gray500),
            ),
            title: Text(
              team.name,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
            subtitle: Text(
              '${team.memberCount ?? 0} members',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray500),
            ),
            trailing: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryLimeGreen
                      : AppColors.gray300,
                  width: 2,
                ),
                color: isSelected
                    ? AppColors.primaryLimeGreen
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: AppColors.white)
                  : null,
            ),
          );
        },
      ),
    );
  }

  bool _canRegister() {
    if (_isRegistering) return false;
    if (widget.tournament.format == 'Singles') return true;
    return _selectedTeam != null;
  }

  Future<void> _handleRegistration() async {
    if (!_canRegister()) return;

    setState(() => _isRegistering = true);

    try {
      final tournamentCubit = context.read<TournamentCubit>();
      final authState = context.read<AuthCubit>().state;

      if (widget.tournament.format == 'Singles') {
        // Get user ID from auth state
        int userId;
        if (authState is Authenticated) {
          userId = authState.user.id;
        } else if (authState is AuthenticatedIncompleteProfile) {
          userId = authState.user.id;
        } else {
          throw Exception('User not authenticated');
        }

        // Register for singles tournament
        await tournamentCubit.handleSinglesRegistration(
          widget.tournament,
          userId,
        );
      } else {
        // Register team for tournament
        await tournamentCubit.handleTeamRegistration(
          widget.tournament,
          _selectedTeam!.teamId,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully registered for ${widget.tournament.name}!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }
}
