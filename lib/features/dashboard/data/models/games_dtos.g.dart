// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'games_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GamesReportDto _$GamesReportDtoFromJson(Map<String, dynamic> json) =>
    GamesReportDto(
      month: json['month'] as String?,
      gamesBowled: (json['games_bowled'] as num?)?.toInt() ?? 0,
      average: json['average'] as num? ?? 0,
      highGame: (json['high_game'] as num?)?.toInt() ?? 0,
      highSeries: (json['high_series'] as num?)?.toInt() ?? 0,
      strikePercentage: json['strike_percentage'] as num? ?? 0,
      spareConversionRate: json['spare_conversion_rate'] as num? ?? 0,
      previousMonthAverage: json['previous_month_average'] as num?,
      strengths:
          (json['strengths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      improvements:
          (json['improvements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      practicePriorities:
          (json['practice_priorities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      milestones: json['milestones'] as List<dynamic>? ?? [],
    );

GamesTrendsDto _$GamesTrendsDtoFromJson(
  Map<String, dynamic> json,
) => GamesTrendsDto(
  labels:
      (json['labels'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  averages:
      (json['averages'] as List<dynamic>?)?.map((e) => e as num).toList() ?? [],
  strikePcts:
      (json['strike_pcts'] as List<dynamic>?)?.map((e) => e as num).toList() ??
      [],
  spareRates:
      (json['spare_rates'] as List<dynamic>?)?.map((e) => e as num).toList() ??
      [],
);
