import 'package:json_annotation/json_annotation.dart';

part 'games_dtos.g.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Session (list item + detail use the same shape)
// ──────────────────────────────────────────────────────────────────────────────
@JsonSerializable(createToJson: false)
class SessionDto {
  const SessionDto({
    required this.uid,
    required this.name,
    required this.games,
    this.center,
    this.laneNumbers = '',
    this.gameContext = 'practice',
    this.oilPatternName = '',
    this.oilPatternLength,
    this.notes = '',
    this.seriesTotal = 0,
    this.createdAt,
  });

  final String uid;
  final String name;
  final CenterRefDto? center;

  @JsonKey(name: 'lane_numbers', defaultValue: '')
  final String laneNumbers;

  @JsonKey(name: 'game_context', defaultValue: 'practice')
  final String gameContext;

  @JsonKey(name: 'oil_pattern_name', defaultValue: '')
  final String oilPatternName;

  @JsonKey(name: 'oil_pattern_length')
  final int? oilPatternLength;

  @JsonKey(defaultValue: '')
  final String notes;

  final List<GameSummaryDto> games;

  @JsonKey(name: 'series_total', defaultValue: 0)
  final int seriesTotal;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  factory SessionDto.fromJson(Map<String, dynamic> json) =>
      _$SessionDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class CenterRefDto {
  const CenterRefDto({required this.id, required this.name});

  final int id;
  final String name;

  factory CenterRefDto.fromJson(Map<String, dynamic> json) =>
      _$CenterRefDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class GameSummaryDto {
  const GameSummaryDto({
    required this.id,
    required this.gameNumber,
    required this.totalScore,
    this.strikeCount = 0,
    this.spareCount = 0,
    this.isComplete = false,
  });

  final int id;
  @JsonKey(name: 'game_number')
  final int gameNumber;
  @JsonKey(name: 'total_score', defaultValue: 0)
  final int totalScore;
  @JsonKey(name: 'strike_count', defaultValue: 0)
  final int strikeCount;
  @JsonKey(name: 'spare_count', defaultValue: 0)
  final int spareCount;
  @JsonKey(name: 'is_complete', defaultValue: false)
  final bool isComplete;

  factory GameSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$GameSummaryDtoFromJson(json);
}

// ──────────────────────────────────────────────────────────────────────────────
// GET /api/games/stats
// ──────────────────────────────────────────────────────────────────────────────
@JsonSerializable(createToJson: false)
class UserGameStatsDto {
  const UserGameStatsDto({
    this.totalGames = 0,
    this.totalPins = 0,
    this.currentAverage = 0,
    this.allTimeAverage = 0,
    this.highGame = 0,
    this.highGameDate,
    this.highGameCenterName = '',
    this.highSeries = 0,
    this.highSeriesDate,
    this.highSeriesCenterName = '',
    this.strikePercentage = 0,
    this.spareConversionRate = 0,
    this.splitFrequency = 0,
    this.splitConversionRate = 0,
    this.cleanGameCount = 0,
    this.perfectGameCount = 0,
  });

  @JsonKey(name: 'total_games', defaultValue: 0)
  final int totalGames;
  @JsonKey(name: 'total_pins', defaultValue: 0)
  final int totalPins;
  @JsonKey(name: 'current_average', defaultValue: 0)
  final num currentAverage;
  @JsonKey(name: 'all_time_average', defaultValue: 0)
  final num allTimeAverage;
  @JsonKey(name: 'high_game', defaultValue: 0)
  final int highGame;
  @JsonKey(name: 'high_game_date')
  final String? highGameDate;
  @JsonKey(name: 'high_game_center_name', defaultValue: '')
  final String highGameCenterName;
  @JsonKey(name: 'high_series', defaultValue: 0)
  final int highSeries;
  @JsonKey(name: 'high_series_date')
  final String? highSeriesDate;
  @JsonKey(name: 'high_series_center_name', defaultValue: '')
  final String highSeriesCenterName;
  @JsonKey(name: 'strike_percentage', defaultValue: 0)
  final num strikePercentage;
  @JsonKey(name: 'spare_conversion_rate', defaultValue: 0)
  final num spareConversionRate;
  @JsonKey(name: 'split_frequency', defaultValue: 0)
  final num splitFrequency;
  @JsonKey(name: 'split_conversion_rate', defaultValue: 0)
  final num splitConversionRate;
  @JsonKey(name: 'clean_game_count', defaultValue: 0)
  final int cleanGameCount;
  @JsonKey(name: 'perfect_game_count', defaultValue: 0)
  final int perfectGameCount;

  factory UserGameStatsDto.fromJson(Map<String, dynamic> json) =>
      _$UserGameStatsDtoFromJson(json);
}

// ──────────────────────────────────────────────────────────────────────────────
// GET /api/games/equipment  →  array of UserBall ({id, ball, weight, ...})
// ──────────────────────────────────────────────────────────────────────────────
@JsonSerializable(createToJson: false)
class UserBallDto {
  const UserBallDto({
    required this.id,
    required this.ball,
    this.weight = 15,
    this.createdAt,
  });

  final int id;
  final BallCatalogDto ball;
  @JsonKey(defaultValue: 15)
  final int weight;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  factory UserBallDto.fromJson(Map<String, dynamic> json) =>
      _$UserBallDtoFromJson(json);
}

/// Catalog ball — the full spec returned by `/api/balls` and nested
/// inside each UserBall.
@JsonSerializable(createToJson: false)
class BallCatalogDto {
  const BallCatalogDto({
    required this.id,
    required this.name,
    this.brand,
    this.core = '',
    this.surface = '',
    this.rg = '',
    this.diff = '',
    this.intDiff = '',
    this.arc = '',
    this.ballImage = '',
  });

  final int id;
  final String name;
  final BrandRefDto? brand;
  @JsonKey(defaultValue: '')
  final String core;
  @JsonKey(defaultValue: '')
  final String surface;
  @JsonKey(defaultValue: '')
  final String rg;
  @JsonKey(defaultValue: '')
  final String diff;
  @JsonKey(name: 'int_diff', defaultValue: '')
  final String intDiff;
  @JsonKey(defaultValue: '')
  final String arc;
  @JsonKey(name: 'ball_image', defaultValue: '')
  final String ballImage;

  factory BallCatalogDto.fromJson(Map<String, dynamic> json) =>
      _$BallCatalogDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class BrandRefDto {
  const BrandRefDto({
    required this.id,
    required this.name,
    this.logoUrl,
  });

  final int id;
  final String name;
  @JsonKey(name: 'logo_url')
  final String? logoUrl;

  factory BrandRefDto.fromJson(Map<String, dynamic> json) =>
      _$BrandRefDtoFromJson(json);
}

/// GET /api/balls  →  `{balls: [...], has_next: bool}`.
@JsonSerializable(createToJson: false)
class BallCatalogPageDto {
  const BallCatalogPageDto({this.balls = const [], this.hasNext = false});

  @JsonKey(defaultValue: [])
  final List<BallCatalogDto> balls;
  @JsonKey(name: 'has_next', defaultValue: false)
  final bool hasNext;

  factory BallCatalogPageDto.fromJson(Map<String, dynamic> json) =>
      _$BallCatalogPageDtoFromJson(json);
}

/// GET /api/games/stats/pin-leaves entry.
@JsonSerializable(createToJson: false)
class PinLeaveStatDto {
  const PinLeaveStatDto({
    this.leavePattern = '',
    this.name = '',
    this.occurrenceCount = 0,
    this.conversionCount = 0,
    this.conversionRate = 0,
  });

  @JsonKey(name: 'leave_pattern', defaultValue: '')
  final String leavePattern;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(name: 'occurrence_count', defaultValue: 0)
  final int occurrenceCount;
  @JsonKey(name: 'conversion_count', defaultValue: 0)
  final int conversionCount;
  @JsonKey(name: 'conversion_rate', defaultValue: 0)
  final num conversionRate;

  factory PinLeaveStatDto.fromJson(Map<String, dynamic> json) =>
      _$PinLeaveStatDtoFromJson(json);
}

/// GET /api/games/stats/spares entry.
@JsonSerializable(createToJson: false)
class SpareCategoryStatDto {
  const SpareCategoryStatDto({
    this.category = '',
    this.total = 0,
    this.converted = 0,
    this.conversionRate = 0,
  });

  @JsonKey(defaultValue: '')
  final String category;
  @JsonKey(defaultValue: 0)
  final int total;
  @JsonKey(defaultValue: 0)
  final int converted;
  @JsonKey(name: 'conversion_rate', defaultValue: 0)
  final num conversionRate;

  factory SpareCategoryStatDto.fromJson(Map<String, dynamic> json) =>
      _$SpareCategoryStatDtoFromJson(json);
}

/// GET /api/games/stats/trends entry.
@JsonSerializable(createToJson: false)
class TrendPointDto {
  const TrendPointDto({
    this.score = 0,
    this.rollingAverage = 0,
    this.date,
    this.gameContext = '',
  });

  @JsonKey(defaultValue: 0)
  final int score;
  @JsonKey(name: 'rolling_average', defaultValue: 0)
  final num rollingAverage;
  final String? date;
  @JsonKey(name: 'game_context', defaultValue: '')
  final String gameContext;

  factory TrendPointDto.fromJson(Map<String, dynamic> json) =>
      _$TrendPointDtoFromJson(json);
}

/// GET /api/games/stats/by-center entry.
@JsonSerializable(createToJson: false)
class CenterPerformanceDto {
  const CenterPerformanceDto({
    this.centerId = 0,
    this.centerName = '',
    this.avgScore = 0,
    this.gamesCount = 0,
  });

  @JsonKey(name: 'center_id', defaultValue: 0)
  final int centerId;
  @JsonKey(name: 'center_name', defaultValue: '')
  final String centerName;
  @JsonKey(name: 'avg_score', defaultValue: 0)
  final num avgScore;
  @JsonKey(name: 'games_count', defaultValue: 0)
  final int gamesCount;

  factory CenterPerformanceDto.fromJson(Map<String, dynamic> json) =>
      _$CenterPerformanceDtoFromJson(json);
}

/// GET /api/games/stats/by-context entry.
@JsonSerializable(createToJson: false)
class ContextPerformanceDto {
  const ContextPerformanceDto({
    this.gameContext = '',
    this.avgScore = 0,
    this.gamesCount = 0,
  });

  @JsonKey(name: 'game_context', defaultValue: '')
  final String gameContext;
  @JsonKey(name: 'avg_score', defaultValue: 0)
  final num avgScore;
  @JsonKey(name: 'games_count', defaultValue: 0)
  final int gamesCount;

  factory ContextPerformanceDto.fromJson(Map<String, dynamic> json) =>
      _$ContextPerformanceDtoFromJson(json);
}

/// GET /api/games/equipment/stats  →  `[{user_ball_id, ...}]`.
@JsonSerializable(createToJson: false)
class BallStatsDto {
  const BallStatsDto({
    required this.userBallId,
    this.gamesPlayed = 0,
    this.framesThrown = 0,
    this.firstBallCount = 0,
    this.firstBallAvg = 0,
    this.strikeRate = 0,
  });

  @JsonKey(name: 'user_ball_id')
  final int userBallId;
  @JsonKey(name: 'games_played', defaultValue: 0)
  final int gamesPlayed;
  @JsonKey(name: 'frames_thrown', defaultValue: 0)
  final int framesThrown;
  @JsonKey(name: 'first_ball_count', defaultValue: 0)
  final int firstBallCount;
  @JsonKey(name: 'first_ball_avg', defaultValue: 0)
  final num firstBallAvg;
  @JsonKey(name: 'strike_rate', defaultValue: 0)
  final num strikeRate;

  factory BallStatsDto.fromJson(Map<String, dynamic> json) =>
      _$BallStatsDtoFromJson(json);
}

// ──────────────────────────────────────────────────────────────────────────────
// GET /api/games/<id> — full game with frames
// ──────────────────────────────────────────────────────────────────────────────
@JsonSerializable(createToJson: false)
class GameDetailDto {
  const GameDetailDto({
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
  @JsonKey(name: 'game_number')
  final int gameNumber;
  @JsonKey(name: 'total_score', defaultValue: 0)
  final int totalScore;
  @JsonKey(name: 'strike_count', defaultValue: 0)
  final int strikeCount;
  @JsonKey(name: 'spare_count', defaultValue: 0)
  final int spareCount;
  @JsonKey(name: 'open_count', defaultValue: 0)
  final int openCount;
  @JsonKey(name: 'split_count', defaultValue: 0)
  final int splitCount;
  @JsonKey(name: 'first_ball_average', defaultValue: 0)
  final num firstBallAverage;
  @JsonKey(name: 'is_clean', defaultValue: false)
  final bool isClean;
  @JsonKey(name: 'is_perfect', defaultValue: false)
  final bool isPerfect;
  @JsonKey(name: 'is_complete', defaultValue: false)
  final bool isComplete;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  final List<FrameDto> frames;

  factory GameDetailDto.fromJson(Map<String, dynamic> json) =>
      _$GameDetailDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class FrameDto {
  const FrameDto({
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

  @JsonKey(name: 'frame_number')
  final int frameNumber;
  @JsonKey(name: 'is_strike', defaultValue: false)
  final bool isStrike;
  @JsonKey(name: 'is_spare', defaultValue: false)
  final bool isSpare;
  @JsonKey(name: 'is_split', defaultValue: false)
  final bool isSplit;
  @JsonKey(name: 'split_name', defaultValue: '')
  final String splitName;
  @JsonKey(name: 'is_pocket_hit', defaultValue: false)
  final bool isPocketHit;
  @JsonKey(name: 'is_washout', defaultValue: false)
  final bool isWashout;
  @JsonKey(defaultValue: 0)
  final int pinfall;
  @JsonKey(name: 'frame_score', defaultValue: 0)
  final int frameScore;

  factory FrameDto.fromJson(Map<String, dynamic> json) =>
      _$FrameDtoFromJson(json);
}
