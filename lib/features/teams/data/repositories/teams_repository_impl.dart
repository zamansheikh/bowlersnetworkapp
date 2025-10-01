import 'package:injectable/injectable.dart';
import '../../domain/entities/team.dart';
import '../../domain/entities/team_member.dart';
import '../../domain/entities/team_invitation.dart';
import '../../domain/repositories/teams_repository.dart';
import '../datasources/teams_remote_data_source.dart';

@Injectable(as: TeamsRepository)
class TeamsRepositoryImpl implements TeamsRepository {
  final TeamsRemoteDataSource remoteDataSource;

  TeamsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Team>> getUserTeams() async {
    try {
      return await remoteDataSource.getUserTeams();
    } catch (e) {
      throw Exception('Failed to get user teams: $e');
    }
  }

  @override
  Future<Team> createTeam({required String name}) async {
    try {
      return await remoteDataSource.createTeam(name: name);
    } catch (e) {
      throw Exception('Failed to create team: $e');
    }
  }

  @override
  Future<void> deleteTeam(int teamId) async {
    try {
      return await remoteDataSource.deleteTeam(teamId);
    } catch (e) {
      throw Exception('Failed to delete team: $e');
    }
  }

  @override
  Future<TeamDetails> getTeamDetails(int teamId) async {
    try {
      return await remoteDataSource.getTeamDetails(teamId);
    } catch (e) {
      throw Exception('Failed to get team details: $e');
    }
  }

  @override
  Future<List<AvailableMember>> getAvailableMembers() async {
    try {
      return await remoteDataSource.getAvailableMembers();
    } catch (e) {
      throw Exception('Failed to get available members: $e');
    }
  }

  @override
  Future<void> inviteUserToTeam({
    required int teamId,
    required int invitedUserId,
  }) async {
    try {
      return await remoteDataSource.inviteUserToTeam(
        teamId: teamId,
        invitedUserId: invitedUserId,
      );
    } catch (e) {
      throw Exception('Failed to invite user to team: $e');
    }
  }

  @override
  Future<TeamInvitations> getTeamInvitations() async {
    try {
      return await remoteDataSource.getTeamInvitations();
    } catch (e) {
      throw Exception('Failed to get team invitations: $e');
    }
  }

  @override
  Future<void> respondToInvitation({
    required int invitationId,
    required bool isAccepted,
  }) async {
    try {
      return await remoteDataSource.respondToInvitation(
        invitationId: invitationId,
        isAccepted: isAccepted,
      );
    } catch (e) {
      throw Exception('Failed to respond to invitation: $e');
    }
  }

  @override
  Future<void> withdrawInvitation(int invitationId) async {
    try {
      return await remoteDataSource.withdrawInvitation(invitationId);
    } catch (e) {
      throw Exception('Failed to withdraw invitation: $e');
    }
  }

  @override
  Future<void> removeMemberFromTeam({
    required int teamId,
    required int memberId,
  }) async {
    try {
      return await remoteDataSource.removeMemberFromTeam(
        teamId: teamId,
        memberId: memberId,
      );
    } catch (e) {
      throw Exception('Failed to remove member from team: $e');
    }
  }
}