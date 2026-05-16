// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alpha_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlphaScoreDto _$AlphaScoreDtoFromJson(Map<String, dynamic> json) =>
    AlphaScoreDto(
      alphaScore: (json['alpha_score'] as num?)?.toInt() ?? 0,
      impactLevel: json['impact_level'] as String? ?? '',
      tips:
          (json['tips'] as List<dynamic>?)
              ?.map((e) => AlphaTipDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

AlphaTipDto _$AlphaTipDtoFromJson(Map<String, dynamic> json) => AlphaTipDto(
  text: json['text'] as String? ?? '',
  action: json['action'] as String? ?? '',
);
