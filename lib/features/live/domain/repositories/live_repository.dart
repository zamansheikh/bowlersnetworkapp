import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/live_broadcast.dart';

abstract class LiveRepository {
  /// POST /api/games/lives/start — kicks off a broadcast for [sessionUid].
  /// Returns the new broadcast incl. its `currentGameId` if the engine
  /// auto-created one.
  Future<Either<Failure, LiveBroadcast>> startBroadcast({
    required String sessionUid,
    String title = '',
  });

  /// POST /api/games/lives/{id}/end.
  Future<Either<Failure, Unit>> endBroadcast(int livescoreId);

  /// GET /api/games/lives/me/active — `null` when the user has none.
  /// Used on play-screen mount to rehydrate after a process restart.
  Future<Either<Failure, LiveBroadcast?>> getMyActive();
}
