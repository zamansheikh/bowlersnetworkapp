import 'package:equatable/equatable.dart';

enum GameContext {
  practice('practice', 'Practice'),
  league('league', 'League'),
  tournament('tournament', 'Tournament'),
  casual('casual', 'Casual');

  const GameContext(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static GameContext fromString(String s) {
    for (final c in GameContext.values) {
      if (c.apiValue == s) return c;
    }
    return GameContext.practice;
  }
}

class CenterRef extends Equatable {
  const CenterRef({required this.id, required this.name});
  final int id;
  final String name;
  @override
  List<Object?> get props => [id, name];
}

class GameSummary extends Equatable {
  const GameSummary({
    required this.id,
    required this.gameNumber,
    required this.totalScore,
    this.strikeCount = 0,
    this.spareCount = 0,
    this.isComplete = false,
  });

  final int id;
  final int gameNumber;
  final int totalScore;
  final int strikeCount;
  final int spareCount;
  final bool isComplete;

  @override
  List<Object?> get props =>
      [id, gameNumber, totalScore, strikeCount, spareCount, isComplete];
}

class Session extends Equatable {
  const Session({
    required this.uid,
    required this.name,
    required this.context,
    required this.games,
    this.center,
    this.laneNumbers = '',
    this.oilPatternName = '',
    this.oilPatternLength,
    this.notes = '',
    this.seriesTotal = 0,
    this.createdAt,
  });

  final String uid;
  final String name;
  final GameContext context;
  final CenterRef? center;
  final String laneNumbers;
  final String oilPatternName;
  final int? oilPatternLength;
  final String notes;
  final List<GameSummary> games;
  final int seriesTotal;
  final DateTime? createdAt;

  int get gamesPlayed => games.where((g) => g.isComplete).length;

  int get highestScore => games.isEmpty
      ? 0
      : games.map((g) => g.totalScore).reduce((a, b) => a > b ? a : b);

  @override
  List<Object?> get props => [
        uid,
        name,
        context,
        center,
        laneNumbers,
        oilPatternName,
        oilPatternLength,
        notes,
        games,
        seriesTotal,
        createdAt,
      ];
}
