import 'package:equatable/equatable.dart';

/// One frame in a completed game — backend-computed flags + pinfall +
/// running frame score. Returned by `submitGame` and `getGame`.
class GameFrame extends Equatable {
  const GameFrame({
    required this.frameNumber,
    this.isStrike = false,
    this.isSpare = false,
    this.isSplit = false,
    this.splitName = '',
    this.isPocketHit = false,
    this.isWashout = false,
    this.pinfall = 0,
    this.frameScore = 0,
  });

  final int frameNumber;
  final bool isStrike;
  final bool isSpare;
  final bool isSplit;
  final String splitName;
  final bool isPocketHit;
  final bool isWashout;

  /// Pins knocked across all deliveries in this frame.
  final int pinfall;

  /// Running game total at this frame (server-computed; null = pending bonus).
  final int frameScore;

  @override
  List<Object?> get props => [
        frameNumber,
        isStrike,
        isSpare,
        isSplit,
        splitName,
        isPocketHit,
        isWashout,
        pinfall,
        frameScore,
      ];
}

/// Full game payload returned by `GET /api/games/{id}` and
/// `POST /api/games/sessions/{uid}/submit-game`.
class GameDetail extends Equatable {
  const GameDetail({
    required this.id,
    required this.gameNumber,
    required this.totalScore,
    required this.frames,
    this.strikeCount = 0,
    this.spareCount = 0,
    this.openCount = 0,
    this.splitCount = 0,
    this.firstBallAverage = 0,
    this.isClean = false,
    this.isPerfect = false,
    this.isComplete = false,
    this.createdAt,
  });

  final int id;
  final int gameNumber;
  final int totalScore;
  final List<GameFrame> frames;
  final int strikeCount;
  final int spareCount;
  final int openCount;
  final int splitCount;
  final double firstBallAverage;
  final bool isClean;
  final bool isPerfect;
  final bool isComplete;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        id,
        gameNumber,
        totalScore,
        frames,
        strikeCount,
        spareCount,
        openCount,
        splitCount,
        firstBallAverage,
        isClean,
        isPerfect,
        isComplete,
        createdAt,
      ];
}
