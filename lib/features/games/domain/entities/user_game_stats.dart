import 'package:equatable/equatable.dart';

/// Aggregated bowling stats for the current user. Empty object returned
/// by the backend when the user has no games yet → [hasRecord] is false.
class UserGameStats extends Equatable {
  const UserGameStats({
    required this.totalGames,
    required this.currentAverage,
    required this.highGame,
    required this.highSeries,
    required this.strikePercentage,
    required this.cleanGameCount,
    required this.perfectGameCount,
    this.allTimeAverage = 0,
    this.spareConversionRate = 0,
    this.splitFrequency = 0,
    this.splitConversionRate = 0,
    this.totalPins = 0,
    this.highGameDate,
    this.highGameCenter = '',
    this.highSeriesDate,
    this.highSeriesCenter = '',
  });

  final int totalGames;
  final int totalPins;
  final num currentAverage;
  final num allTimeAverage;
  final int highGame;
  final String? highGameDate;
  final String highGameCenter;
  final int highSeries;
  final String? highSeriesDate;
  final String highSeriesCenter;
  final num strikePercentage;
  final num spareConversionRate;
  final num splitFrequency;
  final num splitConversionRate;
  final int cleanGameCount;
  final int perfectGameCount;

  bool get hasRecord => totalGames > 0;

  @override
  List<Object?> get props => [
        totalGames,
        currentAverage,
        highGame,
        highSeries,
        strikePercentage,
        cleanGameCount,
        perfectGameCount,
      ];
}
