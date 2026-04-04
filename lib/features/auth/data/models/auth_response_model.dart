import 'package:json_annotation/json_annotation.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  final String token;

  @JsonKey(name: 'requires_consent', defaultValue: false)
  final bool requiresConsent;

  const AuthResponseModel({
    required this.token,
    this.requiresConsent = false,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}
