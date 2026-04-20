// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'games_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionDto _$SessionDtoFromJson(Map<String, dynamic> json) => SessionDto(
  uid: json['uid'] as String,
  name: json['name'] as String,
  games: (json['games'] as List<dynamic>)
      .map((e) => GameSummaryDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  center: json['center'] == null
      ? null
      : CenterRefDto.fromJson(json['center'] as Map<String, dynamic>),
  laneNumbers: json['lane_numbers'] as String? ?? '',
  gameContext: json['game_context'] as String? ?? 'practice',
  oilPatternName: json['oil_pattern_name'] as String? ?? '',
  oilPatternLength: (json['oil_pattern_length'] as num?)?.toInt(),
  notes: json['notes'] as String? ?? '',
  seriesTotal: (json['series_total'] as num?)?.toInt() ?? 0,
  createdAt: json['created_at'] as String?,
);

CenterRefDto _$CenterRefDtoFromJson(Map<String, dynamic> json) =>
    CenterRefDto(id: (json['id'] as num).toInt(), name: json['name'] as String);

GameSummaryDto _$GameSummaryDtoFromJson(Map<String, dynamic> json) =>
    GameSummaryDto(
      id: (json['id'] as num).toInt(),
      gameNumber: (json['game_number'] as num).toInt(),
      totalScore: (json['total_score'] as num?)?.toInt() ?? 0,
      strikeCount: (json['strike_count'] as num?)?.toInt() ?? 0,
      spareCount: (json['spare_count'] as num?)?.toInt() ?? 0,
      isComplete: json['is_complete'] as bool? ?? false,
    );

UserGameStatsDto _$UserGameStatsDtoFromJson(Map<String, dynamic> json) =>
    UserGameStatsDto(
      totalGames: (json['total_games'] as num?)?.toInt() ?? 0,
      totalPins: (json['total_pins'] as num?)?.toInt() ?? 0,
      currentAverage: json['current_average'] as num? ?? 0,
      allTimeAverage: json['all_time_average'] as num? ?? 0,
      highGame: (json['high_game'] as num?)?.toInt() ?? 0,
      highGameDate: json['high_game_date'] as String?,
      highGameCenterName: json['high_game_center_name'] as String? ?? '',
      highSeries: (json['high_series'] as num?)?.toInt() ?? 0,
      highSeriesDate: json['high_series_date'] as String?,
      highSeriesCenterName: json['high_series_center_name'] as String? ?? '',
      strikePercentage: json['strike_percentage'] as num? ?? 0,
      spareConversionRate: json['spare_conversion_rate'] as num? ?? 0,
      splitFrequency: json['split_frequency'] as num? ?? 0,
      splitConversionRate: json['split_conversion_rate'] as num? ?? 0,
      cleanGameCount: (json['clean_game_count'] as num?)?.toInt() ?? 0,
      perfectGameCount: (json['perfect_game_count'] as num?)?.toInt() ?? 0,
    );

BallDto _$BallDtoFromJson(Map<String, dynamic> json) => BallDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  brand: json['brand'] == null
      ? null
      : BrandRefDto.fromJson(json['brand'] as Map<String, dynamic>),
  ballName: json['ball_name'] as String? ?? '',
  weight: (json['weight'] as num?)?.toInt(),
  surface: json['surface'] as String? ?? '',
  isActive: json['is_active'] as bool? ?? true,
);

BrandRefDto _$BrandRefDtoFromJson(Map<String, dynamic> json) =>
    BrandRefDto(id: (json['id'] as num).toInt(), name: json['name'] as String);

GameDetailDto _$GameDetailDtoFromJson(Map<String, dynamic> json) =>
    GameDetailDto(
      id: (json['id'] as num).toInt(),
      gameNumber: (json['game_number'] as num).toInt(),
      totalScore: (json['total_score'] as num?)?.toInt() ?? 0,
      frames: (json['frames'] as List<dynamic>)
          .map((e) => FrameDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      strikeCount: (json['strike_count'] as num?)?.toInt() ?? 0,
      spareCount: (json['spare_count'] as num?)?.toInt() ?? 0,
      openCount: (json['open_count'] as num?)?.toInt() ?? 0,
      splitCount: (json['split_count'] as num?)?.toInt() ?? 0,
      firstBallAverage: json['first_ball_average'] as num? ?? 0,
      isClean: json['is_clean'] as bool? ?? false,
      isPerfect: json['is_perfect'] as bool? ?? false,
      isComplete: json['is_complete'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
    );

FrameDto _$FrameDtoFromJson(Map<String, dynamic> json) => FrameDto(
  frameNumber: (json['frame_number'] as num).toInt(),
  isStrike: json['is_strike'] as bool? ?? false,
  isSpare: json['is_spare'] as bool? ?? false,
  isSplit: json['is_split'] as bool? ?? false,
  splitName: json['split_name'] as String? ?? '',
  isPocketHit: json['is_pocket_hit'] as bool? ?? false,
  isWashout: json['is_washout'] as bool? ?? false,
  pinfall: (json['pinfall'] as num?)?.toInt() ?? 0,
  frameScore: (json['frame_score'] as num?)?.toInt() ?? 0,
);
