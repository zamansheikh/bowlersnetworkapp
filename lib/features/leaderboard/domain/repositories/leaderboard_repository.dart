import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/leaderboard.dart';

abstract class LeaderboardRepository {
  Future<Either<Failure, LeaderboardPage>> getLeaderboard({
    required LeaderboardBoardType boardType,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, List<RankGroup>>> getRanks();

  Future<Either<Failure, XpDashboard>> getDashboard();
}
