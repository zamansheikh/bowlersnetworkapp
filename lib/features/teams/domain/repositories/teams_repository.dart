import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/team.dart';

abstract class TeamsRepository {
  // ── Browse ────────────────────────────────────────────────────────────────

  Future<Either<Failure, List<Team>>> getMyTeams();

  Future<Either<Failure, TeamInvitationsBundle>> getInvitations();

  Future<Either<Failure, TeamNameAvailability>> validateName(String name);

  Future<Either<Failure, Team>> getTeam(int teamId);

  // ── Team CRUD ─────────────────────────────────────────────────────────────

  Future<Either<Failure, Team>> createTeam({
    required String name,
    String? description,
    int? maxSize,
    int? homeCenterId,
  });

  Future<Either<Failure, Team>> updateTeam({
    required int teamId,
    String? name,
    String? description,
    int? maxSize,
    int? homeCenterId,
    bool clearHomeCenter = false,
  });

  Future<Either<Failure, Unit>> deleteTeam(int teamId);

  Future<Either<Failure, Team>> updateLogo({
    required int teamId,
    required String logoUrl,
  });

  // ── Membership ────────────────────────────────────────────────────────────

  Future<Either<Failure, Unit>> leaveTeam(int teamId);

  Future<Either<Failure, Unit>> removeMember({
    required int teamId,
    required int userId,
  });

  Future<Either<Failure, TeamMember>> setMemberRole({
    required int teamId,
    required int userId,
    required TeamRole role,
  });

  Future<Either<Failure, TeamMember>> setMemberJersey({
    required int teamId,
    required int userId,
    required int? jerseyNumber,
  });

  // ── Invitations ───────────────────────────────────────────────────────────

  Future<Either<Failure, TeamInviteResult>> sendInvitations({
    required int teamId,
    required List<int> userIds,
  });

  Future<Either<Failure, TeamInvitation>> acceptInvitation(int invitationId);

  Future<Either<Failure, Unit>> declineInvitation(int invitationId);

  Future<Either<Failure, Unit>> cancelInvitation(int invitationId);
}
