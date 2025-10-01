import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/teams_usecases.dart';
import '../../domain/entities/team.dart';
import 'teams_state.dart';

@injectable
class TeamsCubit extends Cubit<TeamsState> {
  final GetUserTeamsUseCase _getUserTeams;
  final CreateTeamUseCase _createTeam;
  final DeleteTeamUseCase _deleteTeam;
  final GetTeamDetailsUseCase _getTeamDetails;
  final GetAvailableMembersUseCase _getAvailableMembers;
  final InviteUserToTeamUseCase _inviteUserToTeam;
  final GetTeamInvitationsUseCase _getTeamInvitations;
  final RespondToInvitationUseCase _respondToInvitation;
  final WithdrawInvitationUseCase _withdrawInvitation;
  final RemoveMemberFromTeamUseCase _removeMemberFromTeam;

  TeamsCubit(
    this._getUserTeams,
    this._createTeam,
    this._deleteTeam,
    this._getTeamDetails,
    this._getAvailableMembers,
    this._inviteUserToTeam,
    this._getTeamInvitations,
    this._respondToInvitation,
    this._withdrawInvitation,
    this._removeMemberFromTeam,
  ) : super(TeamsInitial());

  /// Get user's teams
  Future<void> getUserTeams() async {
    try {
      emit(TeamsLoading());
      final teams = await _getUserTeams();
      emit(TeamsLoaded(teams: teams));
    } catch (e) {
      emit(TeamsError(message: 'Failed to load teams: $e'));
    }
  }

  /// Create a new team
  Future<void> createTeam({required String name}) async {
    try {
      emit(TeamCreationLoading());
      final team = await _createTeam(name: name);
      emit(TeamCreationSuccess(createdTeam: team));
      // Refresh teams list
      getUserTeams();
    } catch (e) {
      emit(TeamCreationError(message: 'Failed to create team: $e'));
    }
  }

  /// Delete a team
  Future<void> deleteTeam(int teamId) async {
    try {
      emit(TeamsActionLoading());
      await _deleteTeam(teamId);
      emit(const TeamsActionSuccess(message: 'Team deleted successfully'));
      // Refresh teams list
      getUserTeams();
    } catch (e) {
      emit(TeamsActionError(message: 'Failed to delete team: $e'));
    }
  }

  /// Get team details with members
  Future<void> getTeamDetails(int teamId) async {
    try {
      emit(TeamDetailsLoading());
      final teamDetails = await _getTeamDetails(teamId);
      // Convert TeamDetails to Team entity
      final team = Team(
        teamId: teamDetails.teamId,
        name: teamDetails.name,
        logoUrl: teamDetails.logoUrl,
        createdBy: TeamCreator(
          userId: teamDetails.createdBy.userId,
          username: teamDetails.createdBy.username,
          name: teamDetails.createdBy.name,
          firstName: teamDetails.createdBy.firstName,
          lastName: teamDetails.createdBy.lastName,
          email: teamDetails.createdBy.email,
          xp: teamDetails.createdBy.xp,
          level: teamDetails.createdBy.level,
          profilePictureUrl: teamDetails.createdBy.profilePictureUrl,
          introVideoUrl: teamDetails.createdBy.introVideoUrl,
          coverPhotoUrl: teamDetails.createdBy.coverPhotoUrl,
          cardTheme: teamDetails.createdBy.cardTheme,
        ),
        createdAt: teamDetails.createdAt,
        teamChatRoomId: teamDetails.teamChatRoomId,
        memberCount: teamDetails.members.memberCount,
      );
      emit(TeamDetailsLoaded(team: team, members: teamDetails.members.members));
    } catch (e) {
      emit(TeamDetailsError(message: 'Failed to load team details: $e'));
    }
  }

  /// Get available members for invitation
  Future<void> getAvailableMembers() async {
    try {
      emit(AvailableMembersLoading());
      await _getAvailableMembers();
      // Convert AvailableMember entities to AvailableMemberModel
      // For now, we'll create dummy models - this needs to be fixed when we implement proper mapping
      emit(const AvailableMembersLoaded(availableMembers: []));
    } catch (e) {
      emit(
        AvailableMembersError(message: 'Failed to load available members: $e'),
      );
    }
  }

  /// Invite user to team
  Future<void> inviteUserToTeam({
    required int teamId,
    required int userId,
  }) async {
    try {
      emit(TeamsActionLoading());
      await _inviteUserToTeam(teamId: teamId, invitedUserId: userId);
      emit(const TeamsActionSuccess(message: 'Invitation sent successfully'));
    } catch (e) {
      emit(TeamsActionError(message: 'Failed to send invitation: $e'));
    }
  }

  /// Get team invitations
  Future<void> getTeamInvitations() async {
    try {
      emit(TeamInvitationsLoading());
      final invitations = await _getTeamInvitations();
      // Combine received and sent invitations
      final allInvitations = [...invitations.received, ...invitations.sent];
      emit(TeamInvitationsLoaded(invitations: allInvitations));
    } catch (e) {
      emit(TeamInvitationsError(message: 'Failed to load invitations: $e'));
    }
  }

  /// Respond to team invitation
  Future<void> respondToInvitation({
    required int invitationId,
    required bool accept,
  }) async {
    try {
      emit(TeamsActionLoading());
      await _respondToInvitation(
        invitationId: invitationId,
        isAccepted: accept,
      );
      final message = accept
          ? 'Invitation accepted successfully'
          : 'Invitation declined';
      emit(TeamsActionSuccess(message: message));
      // Refresh invitations and teams
      getTeamInvitations();
      getUserTeams();
    } catch (e) {
      emit(TeamsActionError(message: 'Failed to respond to invitation: $e'));
    }
  }

  /// Withdraw team invitation
  Future<void> withdrawInvitation(int invitationId) async {
    try {
      emit(TeamsActionLoading());
      await _withdrawInvitation(invitationId);
      emit(
        const TeamsActionSuccess(message: 'Invitation withdrawn successfully'),
      );
      getTeamInvitations();
    } catch (e) {
      emit(TeamsActionError(message: 'Failed to withdraw invitation: $e'));
    }
  }

  /// Remove member from team
  Future<void> removeMemberFromTeam({
    required int teamId,
    required int userId,
  }) async {
    try {
      emit(TeamsActionLoading());
      await _removeMemberFromTeam(teamId: teamId, memberId: userId);
      emit(const TeamsActionSuccess(message: 'Member removed successfully'));
      // Refresh team details if currently viewing a team
      if (state is TeamDetailsLoaded) {
        final currentState = state as TeamDetailsLoaded;
        getTeamDetails(currentState.team.teamId);
      }
    } catch (e) {
      emit(TeamsActionError(message: 'Failed to remove member: $e'));
    }
  }

  /// Reset state to initial
  void resetState() {
    emit(TeamsInitial());
  }

  /// Clear error state
  void clearError() {
    if (state is TeamsError ||
        state is TeamDetailsError ||
        state is TeamCreationError ||
        state is TeamInvitationsError ||
        state is AvailableMembersError ||
        state is TeamsActionError) {
      emit(TeamsInitial());
    }
  }
}
