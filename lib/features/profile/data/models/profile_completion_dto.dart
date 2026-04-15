import 'package:json_annotation/json_annotation.dart';

part 'profile_completion_dto.g.dart';

/// GET /api/profile/completion
@JsonSerializable(createToJson: false)
class ProfileCompletionDto {
  const ProfileCompletionDto({
    required this.completionPercentage,
    required this.isComplete,
  });

  @JsonKey(name: 'completion_percentage')
  final int completionPercentage;
  @JsonKey(name: 'is_complete')
  final bool isComplete;

  factory ProfileCompletionDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileCompletionDtoFromJson(json);
}
