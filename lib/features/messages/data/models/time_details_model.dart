import 'package:json_annotation/json_annotation.dart';

part 'time_details_model.g.dart';

@JsonSerializable()
class TimeDetailsModel {
  @JsonKey(name: 'sent_at')
  final String sentAt;
  final String timesince;

  const TimeDetailsModel({required this.sentAt, required this.timesince});

  factory TimeDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$TimeDetailsModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimeDetailsModelToJson(this);
}
