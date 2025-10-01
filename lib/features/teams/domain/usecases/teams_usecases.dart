import 'package:injectable/injectable.dart';
import '../entities/team.dart';
import '../entities/team_member.dart';
import '../entities/team_invitation.dart';
import '../repositories/teams_repository.dart';

@injectable
class GetUserTeamsUseCase {
  final TeamsRepository repository;

  GetUserTeamsUseCase({required this.repository});

  Future<List<Team>> call() async {
    return await repository.getUserTeams();
  }
}

@injectable
class CreateTeamUseCase {
  final TeamsRepository repository;

  CreateTeamUseCase({required this.repository});

  Future<Team> call({required String name}) async {
    return await repository.createTeam(name: name);
  }
}

@injectable
class DeleteTeamUseCase {
  final TeamsRepository repository;

  DeleteTeamUseCase({required this.repository});

  Future<void> call(int teamId) async {
    return await repository.deleteTeam(teamId);
  }
}

@injectable
class GetTeamDetailsUseCase {
  final TeamsRepository repository;

  GetTeamDetailsUseCase({required this.repository});

  Future<TeamDetails> call(int teamId) async {
    return await repository.getTeamDetails(teamId);
  }
}

@injectable
class GetAvailableMembersUseCase {
  final TeamsRepository repository;

  GetAvailableMembersUseCase({required this.repository});

  Future<List<AvailableMember>> call() async {
    return await repository.getAvailableMembers();
  }
}

@injectable
class InviteUserToTeamUseCase {
  final TeamsRepository repository;

  InviteUserToTeamUseCase({required this.repository});

  Future<void> call({required int teamId, required int invitedUserId}) async {
    return await repository.inviteUserToTeam(
      teamId: teamId,
      invitedUserId: invitedUserId,
    );
  }
}

@injectable
class GetTeamInvitationsUseCase {
  final TeamsRepository repository;

  GetTeamInvitationsUseCase({required this.repository});

  Future<TeamInvitations> call() async {
    return await repository.getTeamInvitations();
  }
}

@injectable
class RespondToInvitationUseCase {
  final TeamsRepository repository;

  RespondToInvitationUseCase({required this.repository});

  Future<void> call({
    required int invitationId,
    required bool isAccepted,
  }) async {
    return await repository.respondToInvitation(
      invitationId: invitationId,
      isAccepted: isAccepted,
    );
  }
}

@injectable
class WithdrawInvitationUseCase {
  final TeamsRepository repository;

  WithdrawInvitationUseCase({required this.repository});

  Future<void> call(int invitationId) async {
    return await repository.withdrawInvitation(invitationId);
  }
}

@injectable
class RemoveMemberFromTeamUseCase {
  final TeamsRepository repository;

  RemoveMemberFromTeamUseCase({required this.repository});

  Future<void> call({required int teamId, required int memberId}) async {
    return await repository.removeMemberFromTeam(
      teamId: teamId,
      memberId: memberId,
    );
  }
}
