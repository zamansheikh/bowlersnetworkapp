import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/leaderboard.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../datasources/leaderboard_remote_datasource.dart';
import '../models/leaderboard_dtos.dart';

@LazySingleton(as: LeaderboardRepository)
class LeaderboardRepositoryImpl implements LeaderboardRepository {
  LeaderboardRepositoryImpl(this._remote);

  final LeaderboardRemoteDatasource _remote;

  @override
  Future<Either<Failure, LeaderboardPage>> getLeaderboard({
    required LeaderboardBoardType boardType,
    int page = 1,
    int pageSize = 20,
  }) =>
      _guard(() async {
        final dto = await _remote.getLeaderboard(
          boardType.apiValue,
          page: page,
          pageSize: pageSize,
        );
        return LeaderboardPage(
          entries: dto.entries.map(_entryToEntity).toList(growable: false),
          myPosition: dto.myPosition == null
              ? null
              : MyLeaderboardPosition(
                  position: dto.myPosition!.position,
                  xpEarned: dto.myPosition!.xpEarned,
                ),
          totalEntries: dto.totalEntries,
          hasNext: dto.hasNext,
        );
      });

  @override
  Future<Either<Failure, List<RankGroup>>> getRanks() => _guard(() async {
        final list = await _remote.getRanks();
        return list.map(_rankGroupToEntity).toList(growable: false);
      });

  @override
  Future<Either<Failure, XpDashboard>> getDashboard() => _guard(() async {
        final dto = await _remote.getDashboard();
        return XpDashboard(
          level: dto.level,
          totalXp: dto.totalPoints,
          weeklyXp: dto.weeklyPoints,
          monthlyXp: dto.monthlyPoints,
          weeklyXpChange: dto.weeklyXpChange,
          progressPercentage: dto.progressPercentage.toDouble(),
          xpRemaining: dto.xpRemaining,
          last7DaysXp: dto.last7DaysXp,
          weeklyLeaderboardPosition: dto.leaderboardPosition,
          rankDisplay: dto.rankDisplay,
          badgeIconUrl: dto.badgeIconUrl,
        );
      });

  // ── mappers ────────────────────────────────────────────────────────────────
  LeaderboardEntry _entryToEntity(LeaderboardEntryDto dto) => LeaderboardEntry(
        position: dto.position,
        xpEarned: dto.xpEarned,
        rankDisplay: dto.rankDisplay,
        user: LeaderboardUser(
          id: dto.user.id,
          username: dto.user.username,
          firstName: dto.user.firstName,
          lastName: dto.user.lastName,
          profilePictureUrl: dto.user.profilePictureUrl,
          isPro: dto.user.isPro,
          totalXp: dto.user.totalXp,
          level: dto.user.level,
          rankDisplay: dto.user.rankDisplay,
          badgeIconUrl: dto.user.badgeIconUrl,
          isFollowing: dto.user.isFollowing,
        ),
      );

  RankGroup _rankGroupToEntity(RankGroupDto dto) => RankGroup(
        rank: Rank(
          id: dto.rank.id,
          name: dto.rank.name,
          order: dto.rank.order,
          phase: dto.rank.phase,
        ),
        tiers: dto.tiers
            .map((t) => RankTier(
                  level: t.level,
                  badgeIconUrl: t.badgeIconUrl,
                  pointsRequired: t.pointsRequired,
                  tier: t.tier == null
                      ? null
                      : Tier(
                          id: t.tier!.id,
                          name: t.tier!.name,
                          order: t.tier!.order,
                          badgeIconUrl: t.tier!.badgeIconUrl,
                        ),
                ))
            .toList(growable: false),
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
