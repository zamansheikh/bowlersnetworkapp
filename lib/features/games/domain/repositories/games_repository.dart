import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/session.dart';
import '../entities/user_game_stats.dart';

abstract class GamesRepository {
  Future<Either<Failure, List<Session>>> getSessions({
    int? page,
    int pageSize = 20,
  });

  Future<Either<Failure, UserGameStats>> getStats();

  Future<Either<Failure, Session>> getSession(String uid);
}
