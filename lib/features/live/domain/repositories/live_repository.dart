import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/live_broadcast.dart';
import '../entities/live_viewer.dart';

abstract class LiveRepository {
  // ── Broadcaster side ─────────────────────────────────────────────────────

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

  // ── Viewer side ──────────────────────────────────────────────────────────

  /// GET /api/games/lives?scope=...&cursor_id=...
  Future<Either<Failure, ({List<LiveBroadcastListItem> items, int? nextCursorId})>>
      getLives({
    required LiveListScope scope,
    int? cursorId,
  });

  /// GET /api/games/lives/by-uid/{uid}
  Future<Either<Failure, LiveBroadcastDetail>> getLiveByUid(String uid);

  /// GET /api/games/lives/{id}
  Future<Either<Failure, LiveBroadcastDetail>> getLiveById(int id);

  /// GET /api/games/lives/{id}/comments — newest first.
  Future<Either<Failure, LiveCommentsPage>> getComments({
    required int liveId,
    int? cursorId,
  });

  /// POST /api/games/lives/{id}/comments — returns the freshly-created row.
  Future<Either<Failure, LiveBroadcastComment>> postComment({
    required int liveId,
    required String body,
  });

  /// DELETE /api/games/lives/{id}/comments/{cid}.
  Future<Either<Failure, Unit>> deleteComment({
    required int liveId,
    required int commentId,
  });

  /// POST /api/games/lives/{id}/react — toggles to the new type.
  /// Returns the authoritative new reaction the backend persisted.
  Future<Either<Failure, LiveReactionType?>> react({
    required int liveId,
    required LiveReactionType type,
  });

  /// DELETE /api/games/lives/{id}/react — clears any existing reaction.
  Future<Either<Failure, Unit>> removeReaction(int liveId);

  // ── WebSocket payload parsers ────────────────────────────────────────────
  // The socket emits raw maps for `frame_update` / `game_started` /
  // `comment_added`. These mappers let the bloc convert them to entities
  // without reaching into the data layer.

  LiveGame parseLiveGame(Map<String, dynamic> raw);
  LiveBroadcastComment parseLiveComment(Map<String, dynamic> raw);
}
