import 'package:equatable/equatable.dart';

/// A live game-scoring broadcast. The user is "on air" while this exists.
/// [currentGameId] is the Game row the player is currently filling — every
/// per-frame PUT targets it. Without it the player isn't actively bowling
/// (e.g. paused between games).
class LiveBroadcast extends Equatable {
  const LiveBroadcast({
    required this.id,
    required this.uid,
    this.title = '',
    this.viewerCount = 0,
    this.sessionUid,
    this.currentGameId,
    this.currentGameNumber,
  });

  /// Numeric LiveScore id — used by the end + frame-sync endpoints.
  final int id;

  /// Public-facing slug — used in deep links / share URLs.
  final String uid;

  final String title;

  /// Live viewer count. Updated by the WebSocket once we wire it; until
  /// then it stays at whatever the start / rehydrate response gave us.
  final int viewerCount;

  final String? sessionUid;
  final int? currentGameId;
  final int? currentGameNumber;

  LiveBroadcast copyWith({
    int? viewerCount,
    int? currentGameId,
    int? currentGameNumber,
  }) =>
      LiveBroadcast(
        id: id,
        uid: uid,
        title: title,
        viewerCount: viewerCount ?? this.viewerCount,
        sessionUid: sessionUid,
        currentGameId: currentGameId ?? this.currentGameId,
        currentGameNumber: currentGameNumber ?? this.currentGameNumber,
      );

  @override
  List<Object?> get props => [
        id,
        uid,
        title,
        viewerCount,
        sessionUid,
        currentGameId,
        currentGameNumber,
      ];
}
