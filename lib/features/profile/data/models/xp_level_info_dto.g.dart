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
    );
