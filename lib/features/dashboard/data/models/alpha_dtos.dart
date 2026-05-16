import 'package:json_annotation/json_annotation.dart';

part 'alpha_dtos.g.dart';

@JsonSerializable(createToJson: false)
class AlphaScoreDto {
  const AlphaScoreDto({
    this.alphaScore = 0,
    this.impactLevel = '',
    this.tips = const [],
  });

  @JsonKey(name: 'alpha_score', defaultValue: 0)
  final int alphaScore;
  @JsonKey(name: 'impact_level', defaultValue: '')
  final String impactLevel;
  @JsonKey(defaultValue: <AlphaTipDto>[])
  final List<AlphaTipDto> tips;

  factory AlphaScoreDto.fromJson(Map<String, dynamic> json) =>
      _$AlphaScoreDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class AlphaTipDto {
  const AlphaTipDto({this.text = '', this.action = ''});
  @JsonKey(defaultValue: '')
  final String text;
  @JsonKey(defaultValue: '')
  final String action;
  factory AlphaTipDto.fromJson(Map<String, dynamic> json) =>
      _$AlphaTipDtoFromJson(json);
}
