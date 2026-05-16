import 'package:equatable/equatable.dart';

/// Monthly report from /api/dashboard/games/report. `month` query
/// defaults to the previous month if omitted — `monthLabel` is the
/// pretty version for the card header.
class GamesReport extends Equatable {
  const GamesReport({
    this.month,
    this.gamesBowled = 0,
    this.average = 0,
    this.highGame = 0,
    this.highSeries = 0,
    this.strikePercentage = 0,
    this.spareConversionRate = 0,
    this.previousMonthAverage,
    this.strengths = const [],
    this.improvements = const [],
    this.practicePriorities = const [],
    this.milestones = const [],
  });

  final DateTime? month;
  final int gamesBowled;
  final double average;
  final int highGame;
  final int highSeries;
  final double strikePercentage;
  final double spareConversionRate;
  final double? previousMonthAverage;
  final List<String> strengths;
  final List<String> improvements;
  final List<String> practicePriorities;
  final List<String> milestones;

  bool get isEmpty => gamesBowled == 0 && average == 0;

  @override
  List<Object?> get props => [
        month,
        gamesBowled,
        average,
        highGame,
        highSeries,
        strikePercentage,
        spareConversionRate,
        previousMonthAverage,
        strengths,
        improvements,
        practicePriorities,
        milestones,
      ];
}

/// Per-date trend lines from /api/dashboard/games/trends — three
/// parallel arrays of the same length as [labels].
class GamesTrends extends Equatable {
  const GamesTrends({
    this.labels = const [],
    this.averages = const [],
    this.strikePcts = const [],
    this.spareRates = const [],
  });

  final List<String> labels;
  final List<double> averages;
  final List<double> strikePcts;
  final List<double> spareRates;

  bool get isEmpty => labels.isEmpty;

  @override
  List<Object?> get props => [labels, averages, strikePcts, spareRates];
}
