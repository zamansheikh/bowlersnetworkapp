// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xp_level_info_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

XpLevelInfoDto _$XpLevelInfoDtoFromJson(Map<String, dynamic> json) =>
    XpLevelInfoDto(
      level: (json['level'] as num?)?.toInt() ?? 0,
      rank: json['rank'] as String?,
      tier: json['tier'] as String?,
      rankDisplay: json['rank_display'] as String?,
      badgeIconUrl: json['badge_icon_url'] as String?,
      progressPercentage: json['progress_percentage'] as num? ?? 0,
      totalXp: (json['total_xp'] as num?)?.toInt() ?? 0,
      weeklyXpChange: (json['weekly_xp_change'] as num?)?.toInt(),
      xpToNextLevel: (json['xp_to_next_level'] as num?)?.toInt(),
      nextLevel: (json['next_level'] as num?)?.toInt(),
      nextRankDisplay: json['next_rank_display'] as String?,
      nextBadgeIconUrl: json['next_badge_icon_url'] as String?,
    );
