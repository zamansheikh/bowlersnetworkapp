import 'package:json_annotation/json_annotation.dart';

part 'xp_level_info_dto.g.dart';

/// GET /api/xp/level-info — lightweight endpoint the profile hero uses
/// to render rank name, level, and progress bar.
///
/// The backend returns an empty object (`{}`) if the user has no XP record
/// yet — all fields are therefore nullable and default-friendly.
@JsonSerializable(createToJson: false)
class XpLevelInfoDto {
  const XpLevelInfoDto({
    this.level = 0,
    this.rank,
    this.tier,
    this.rankDisplay,
    this.badgeIconUrl,
    this.progressPercentage = 0,
    this.totalXp = 0,
    this.weeklyXpChange,
    this.xpToNextLevel,
    this.nextLevel,
    this.nextRankDisplay,
    this.nextBadgeIconUrl,
  });

  @JsonKey(defaultValue: 0)
  final int level;
  final String? rank;
  final String? tier;

  @JsonKey(name: 'rank_display')
  final String? rankDisplay;

  @JsonKey(name: 'badge_icon_url')
  final String? badgeIconUrl;

  @JsonKey(name: 'progress_percentage', defaultValue: 0)
  final num progressPercentage;

  @JsonKey(name: 'total_xp', defaultValue: 0)
  final int totalXp;

  /// XP delta this week (positive or negative). `null` if the user has no
  /// XP record yet.
  @JsonKey(name: 'weekly_xp_change')
  final int? weeklyXpChange;

  @JsonKey(name: 'xp_to_next_level')
  final int? xpToNextLevel;

  @JsonKey(name: 'next_level')
  final int? nextLevel;

  @JsonKey(name: 'next_rank_display')
  final String? nextRankDisplay;

  @JsonKey(name: 'next_badge_icon_url')
  final String? nextBadgeIconUrl;

  factory XpLevelInfoDto.fromJson(Map<String, dynamic> json) =>
      _$XpLevelInfoDtoFromJson(json);
}
