import 'package:equatable/equatable.dart';

/// One row in `/api/games/stats/pin-leaves` — a leave pattern (e.g. "10
/// pin", "7-10 split") and how often it's encountered + converted.
class PinLeaveStat extends Equatable {
  const PinLeaveStat({
    required this.leavePattern,
    required this.name,
    this.occurrenceCount = 0,
    this.conversionCount = 0,
    this.conversionRate = 0,
  });

  final String leavePattern;
  final String name;
  final int occurrenceCount;
  final int conversionCount;
  final double conversionRate;

  @override
  List<Object?> get props =>
      [leavePattern, name, occurrenceCount, conversionCount, conversionRate];
}

/// One row in `/api/games/stats/spares` — spare conversion grouped by
/// category (single-pin, splits, etc.).
class SpareCategoryStat extends Equatable {
  const SpareCategoryStat({
    required this.category,
    this.total = 0,
    this.converted = 0,
    this.conversionRate = 0,
  });

  /// Backend categories: single_pin, left_side, right_side, center,
  /// multi_pin, splits. The screen maps these to user-facing labels.
  final String category;
  final int total;
  final int converted;
  final double conversionRate;

  String get label => switch (category) {
        'single_pin' => 'Single Pin',
        'left_side' => 'Left Side',
        'right_side' => 'Right Side',
        'center' => 'Center',
        'multi_pin' => 'Multi-Pin (3+)',
        'splits' => 'Splits',
        _ => category,
      };

  @override
  List<Object?> get props => [category, total, converted, conversionRate];
}

/// One point in the rolling-average trends chart.
class TrendPoint extends Equatable {
  const TrendPoint({
    required this.score,
    this.rollingAverage = 0,
    this.date,
    this.gameContext = '',
  });

  final int score;
  final double rollingAverage;
  final DateTime? date;
  final String gameContext;

  @override
  List<Object?> get props => [score, rollingAverage, date, gameContext];
}

/// Aggregate stats grouped by bowling center.
class CenterPerformance extends Equatable {
  const CenterPerformance({
    required this.centerId,
    required this.centerName,
    this.avgScore = 0,
    this.gamesCount = 0,
  });

  final int centerId;
  final String centerName;
  final double avgScore;
  final int gamesCount;

  @override
  List<Object?> get props => [centerId, centerName, avgScore, gamesCount];
}

/// Aggregate stats grouped by session context (practice / league / etc.).
class ContextPerformance extends Equatable {
  const ContextPerformance({
    required this.gameContext,
    this.avgScore = 0,
    this.gamesCount = 0,
  });

  final String gameContext;
  final double avgScore;
  final int gamesCount;

  @override
  List<Object?> get props => [gameContext, avgScore, gamesCount];
}
