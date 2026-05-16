import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/team.dart';
import '../../domain/repositories/teams_repository.dart';
import '../datasources/teams_remote_datasource.dart';
import '../models/team_dtos.dart';

@LazySingleton(as: TeamsRepository)
class TeamsRepositoryImpl implements TeamsRepository {
  TeamsRepositoryImpl(this._remote);

  final TeamsRemoteDatasource _remote;

  // ── Browse ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Team>>> getMyTeams() => _guard(() async {
        final res = await _remote.getMyTeams();
        return res.map(_toTeam).toList(growable: false);
      });

  @override
  Future<Either<Failure, TeamInvitationsBundle>> getInvitations() =>
      _guard(() async {
        final res = await _remote.getInvitations();
        return TeamInvitationsBundle(
          received:
              res.received.map(_toInvitation).toList(growable: false),
          sent: res.sent.map(_toInvitation).toList(growable: false),
        );
      });

  @override
  Future<Either<Failure, TeamNameAvailability>> validateName(String name) =>
      _guard(() async {
        final res = await _remote.validateName(name);
        return TeamNameAvailability(
          available: res.isAvailable,
          reason: res.reason,
        );
      });

  @override
  Future<Either<Failure, Team>> getTeam(int teamId) =>
      _guard(() async => _toTeam(await _remote.getTeam(teamId)));

  // ── Team CRUD ─────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Team>> createTeam({
    required String name,
    String? description,
    int? maxSize,
    int? homeCenterId,
  }) =>
      _guard(() async {
        final body = <String, dynamic>{
          'name': name,
          'description': ?description,
          'max_size': ?maxSize,
          'home_center_id': ?homeCenterId,
        };
        return _toTeam(await _remote.createTeam(body));
      });

  @override
  Future<Either<Failure, Team>> updateTeam({
    required int teamId,
    String? name,
    String? description,
    int? maxSize,
    int? homeCenterId,
    bool clearHomeCenter = false,
  }) =>
      _guard(() async {
        final body = <String, dynamic>{
          'name': ?name,
          'description': ?description,
          'max_size': ?maxSize,
          'home_center_id': ?homeCenterId,
          if (clearHomeCenter) 'clear_home_center': true,
        };
        return _toTeam(await _remote.updateTeam(teamId, body));
      });

  @override
  Future<Either<Failure, Unit>> deleteTeam(int teamId) => _guard(() async {
        await _remote.deleteTeam(teamId);
        return unit;
      });

  @override
  Future<Either<Failure, Team>> updateLogo({
    required int teamId,
    required String logoUrl,
  }) =>
      _guard(() async => _toTeam(
            await _remote.updateLogo(teamId, {'logo_url': logoUrl}),
          ));

  // ── Membership ────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> leaveTeam(int teamId) => _guard(() async {
        await _remote.leaveTeam(teamId);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> removeMember({
    required int teamId,
    required int userId,
  }) =>
      _guard(() async {
        await _remote.removeMember(teamId, userId);
        return unit;
      });

  @override
  Future<Either<Failure, TeamMember>> setMemberRole({
    required int teamId,
    required int userId,
    required TeamRole role,
  }) =>
      _guard(() async => _toMember(
            await _remote.setMemberRole(teamId, userId, {'role': role.wire}),
          ));

  @override
  Future<Either<Failure, TeamMember>> setMemberJersey({
    required int teamId,
    required int userId,
    required int? jerseyNumber,
  }) =>
      _guard(() async => _toMember(
            await _remote.setMemberJersey(teamId, userId, {
              'jersey_number': jerseyNumber,
            }),
          ));

  // ── Invitations ───────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, TeamInviteResult>> sendInvitations({
    required int teamId,
    required List<int> userIds,
  }) =>
      _guard(() async {
        final res = await _remote.sendInvitations({
          'team_id': teamId,
          'invited_user_ids': userIds,
        });
        return TeamInviteResult(
          sent: res.sent.map(_toInvitation).toList(growable: false),
          skipped: res.skipped
              .map((s) => TeamInviteSkip(userId: s.userId, reason: s.reason))
              .toList(growable: false),
        );
      });

  @override
  Future<Either<Failure, TeamInvitation>> acceptInvitation(int invitationId) =>
      _guard(() async => _toInvitation(
            await _remote.acceptInvitation(invitationId),
          ));

  @override
  Future<Either<Failure, Unit>> declineInvitation(int invitationId) =>
      _guard(() async {
        await _remote.declineInvitation(invitationId);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> cancelInvitation(int invitationId) =>
      _guard(() async {
        await _remote.cancelInvitation(invitationId);
        return unit;
      });

  // ── Mappers ───────────────────────────────────────────────────────────────

  TeamUser _toUser(TeamUserDto? dto) {
    if (dto == null) {
      return const TeamUser(id: 0, username: '');
    }
    return TeamUser(
      id: dto.id,
      username: dto.username,
      firstName: dto.firstName,
      lastName: dto.lastName,
      profilePictureUrl: dto.profilePictureUrl,
      isPro: dto.isPro,
      level: dto.level,
      rank: dto.rank,
      tier: dto.tier,
      rankDisplay: dto.rankDisplay,
      badgeIconUrl: dto.badgeIconUrl,
      totalXp: dto.totalXp,
    );
  }

  TeamMember _toMember(TeamMemberDto dto) => TeamMember(
        user: TeamUser(
          id: dto.id,
          username: dto.username,
          firstName: dto.firstName,
          lastName: dto.lastName,
          profilePictureUrl: dto.profilePictureUrl,
          isPro: dto.isPro,
          level: dto.level,
          rank: dto.rank,
          tier: dto.tier,
          rankDisplay: dto.rankDisplay,
          badgeIconUrl: dto.badgeIconUrl,
          totalXp: dto.totalXp,
        ),
        role: TeamRole.fromWire(dto.role),
        jerseyNumber: dto.jerseyNumber,
        joinedAt:
            dto.joinedAt == null ? null : DateTime.tryParse(dto.joinedAt!),
      );

  Team _toTeam(TeamDto dto) => Team(
        id: dto.teamId,
        name: dto.name,
        description: dto.description,
        logoUrl: dto.logoUrl,
        maxSize: dto.maxSize,
        isActive: dto.isActive,
        homeCenter: dto.homeCenter == null
            ? null
            : TeamHomeCenter(
                id: dto.homeCenter!.id,
                name: dto.homeCenter!.name,
                logo: dto.homeCenter!.logo,
              ),
        createdBy: _toUser(dto.createdBy),
        memberCount: dto.memberCount,
        conversationUid: dto.conversationUid,
        createdAt:
            dto.createdAt == null ? null : DateTime.tryParse(dto.createdAt!),
        members: dto.members.map(_toMember).toList(growable: false),
      );

  TeamInvitation _toInvitation(TeamInvitationDto dto) => TeamInvitation(
        id: dto.invitationId,
        team: dto.team == null
            ? const TeamInvitationTeam(id: 0, name: '')
            : TeamInvitationTeam(
                id: dto.team!.teamId,
                name: dto.team!.name,
                logoUrl: dto.team!.logoUrl,
              ),
        invitedUser: _toUser(dto.invitedUser),
        invitedBy: dto.invitedBy == null ? null : _toUser(dto.invitedBy),
        isAccepted: dto.isAccepted,
        createdAt:
            dto.createdAt == null ? null : DateTime.tryParse(dto.createdAt!),
      );

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on DioException catch (e) {
      final parsed = e.error;
      if (parsed is NetworkException) return const Left(NetworkFailure());
      if (parsed is ApiException) {
        if (parsed.statusCode == 401) {
          return Left(UnauthorizedFailure(messages: parsed.messages));
        }
        return Left(ServerFailure(
          messages: parsed.messages,
          statusCode: parsed.statusCode,
        ));
      }
      return const Left(ServerFailure());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
