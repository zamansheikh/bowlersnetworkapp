import 'package:json_annotation/json_annotation.dart';

part 'recovery_request_models.g.dart';

@JsonSerializable()
class OtpInitiateModel {
  final String email;
  const OtpInitiateModel({required this.email});
  factory OtpInitiateModel.fromJson(Map<String, dynamic> json) =>
      _$OtpInitiateModelFromJson(json);
  Map<String, dynamic> toJson() => _$OtpInitiateModelToJson(this);
}

@JsonSerializable()
class OtpValidateModel {
  final String email;
  final String otp;
  const OtpValidateModel({required this.email, required this.otp});
  factory OtpValidateModel.fromJson(Map<String, dynamic> json) =>
      _$OtpValidateModelFromJson(json);
  Map<String, dynamic> toJson() => _$OtpValidateModelToJson(this);
}

@JsonSerializable()
class MagicLinkInitiateModel {
  final String email;
  const MagicLinkInitiateModel({required this.email});
  factory MagicLinkInitiateModel.fromJson(Map<String, dynamic> json) =>
      _$MagicLinkInitiateModelFromJson(json);
  Map<String, dynamic> toJson() => _$MagicLinkInitiateModelToJson(this);
}

@JsonSerializable()
class MagicKeyValidateModel {
  @JsonKey(name: 'magic_key')
  final String magicKey;
  const MagicKeyValidateModel({required this.magicKey});
  factory MagicKeyValidateModel.fromJson(Map<String, dynamic> json) =>
      _$MagicKeyValidateModelFromJson(json);
  Map<String, dynamic> toJson() => _$MagicKeyValidateModelToJson(this);
}

@JsonSerializable()
class PasswordResetModel {
  @JsonKey(name: 'new_password')
  final String newPassword;
  const PasswordResetModel({required this.newPassword});
  factory PasswordResetModel.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetModelFromJson(json);
  Map<String, dynamic> toJson() => _$PasswordResetModelToJson(this);
}
