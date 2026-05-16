import 'package:json_annotation/json_annotation.dart';

part 'games_dtos.g.dart';

@JsonSerializable(createToJson: false)
class GamesReportDto {
  const GamesReportDto({
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

  final String? month;
  @JsonKey(name: 'games_bowled', defaultValue: 0)
  final int gamesBowled;
  @JsonKey(defaultValue: 0)
  final num average;
  @JsonKey(name: 'high_game', defaultValue: 0)
  final int highGame;
  @JsonKey(name: 'high_series', defaultValue: 0)
  final int highSeries;
  @JsonKey(name: 'strike_percentage', defaultValue: 0)
  final num strikePercentage;
  @JsonKey(name: 'spare_conversion_rate', defaultValue: 0)
  final num spareConversionRate;
  @JsonKey(name: 'previous_month_average')
  final num? previousMonthAverage;
  @JsonKey(defaultValue: <String>[])
  final List<String> strengths;
  @JsonKey(defaultValue: <String>[])
  final List<String> improvements;
  @JsonKey(name: 'practice_priorities', defaultValue: <String>[])
  final List<String> practicePriorities;

  /// Backend returns `[object]` — milestones might be strings or rich
  /// objects depending on the data. We accept either; the bloc/repo
  /// flattens to strings for the UI.
  @JsonKey(defaultValue: <dynamic>[])
  final List<dynamic> milestones;

  factory GamesReportDto.fromJson(Map<String, dynamic> json) =>
      _$GamesReportDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class GamesTrendsDto {
  const GamesTrendsDto({
    this.labels = const [],
    this.averages = const [],
    this.strikePcts = const [],
    this.spareRates = const [],
  });
  @JsonKey(defaultValue: <String>[])
  final List<String> labels;
  @JsonKey(defaultValue: <num>[])
  final List<num> averages;
  @JsonKey(name: 'strike_pcts', defaultValue: <num>[])
  final List<num> strikePcts;
  @JsonKey(name: 'spare_rates', defaultValue: <num>[])
  final List<num> spareRates;

  factory GamesTrendsDto.fromJson(Map<String, dynamic> json) =>
      _$GamesTrendsDtoFromJson(json);
}
