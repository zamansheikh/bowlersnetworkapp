import 'package:json_annotation/json_annotation.dart';

part 'signup_request_model.g.dart';

@JsonSerializable(explicitToJson: true)
class SignupRequestModel {
  @JsonKey(name: 'signup_data')
  final SignupData signupData;

  @JsonKey(name: 'verification_code')
  final String verificationCode;

  @JsonKey(name: 'referrer_username', includeIfNull: false)
  final String? referrerUsername;

  const SignupRequestModel({
    required this.signupData,
    required this.verificationCode,
    this.referrerUsername,
  });

  factory SignupRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SignupRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$SignupRequestModelToJson(this);
}

@JsonSerializable()
class SignupData {
  @JsonKey(name: 'first_name')
  final String firstName;

  @JsonKey(name: 'last_name')
  final String lastName;

  final String email;
  final String username;
  final String password;

  @JsonKey(name: 'date_of_birth')
  final String dateOfBirth;

  @JsonKey(name: 'parent_email', includeIfNull: false)
  final String? parentEmail;

  @JsonKey(name: 'is_coach', includeIfNull: false)
  final bool? isCoach;

  const SignupData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.password,
    required this.dateOfBirth,
    this.parentEmail,
    this.isCoach,
  });

  factory SignupData.fromJson(Map<String, dynamic> json) =>
      _$SignupDataFromJson(json);

  Map<String, dynamic> toJson() => _$SignupDataToJson(this);
}
