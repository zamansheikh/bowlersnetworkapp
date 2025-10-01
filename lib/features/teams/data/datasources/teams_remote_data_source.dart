import '../../domain/entities/team.dart';
import '../../domain/entities/team_member.dart';
import '../../domain/entities/team_invitation.dart';

abstract class TeamsRemoteDataSource {
  // Team management
  Future<List<Team>> getUserTeams();
  Future<Team> createTeam({required String name});
  Future<void> deleteTeam(int teamId);

  // Team details and members
  Future<TeamDetails> getTeamDetails(int teamId);
  Future<List<AvailableMember>> getAvailableMembers();

  // Team invitations
  Future<void> inviteUserToTeam({
    required int teamId,
    required int invitedUserId,
  });
  Future<TeamInvitations> getTeamInvitations();
  Future<void> respondToInvitation({
    required int invitationId,
    required bool isAccepted,
  });
  Future<void> withdrawInvitation(int invitationId);

  // Team member management
  Future<void> removeMemberFromTeam({
    required int teamId,
    required int memberId,
  });
}
