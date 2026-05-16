import 'package:json_annotation/json_annotation.dart';

part 'feedback_dtos.g.dart';

/// Response wrapper for `POST /api/feedback/submit`. Backend returns the
/// full created feedback object but for now we only need the uid + the
/// fact that it succeeded.
@JsonSerializable(createToJson: false)
class FeedbackCreatedDto {
  const FeedbackCreatedDto({
    this.uid,
    this.title = '',
    this.category = '',
    this.featureArea = '',
  });

  final String? uid;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(defaultValue: '')
  final String category;
  @JsonKey(name: 'feature_area', defaultValue: '')
  final String featureArea;

  factory FeedbackCreatedDto.fromJson(Map<String, dynamic> json) =>
      _$FeedbackCreatedDtoFromJson(json);
}
