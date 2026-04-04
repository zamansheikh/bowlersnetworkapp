// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovery_request_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpInitiateModel _$OtpInitiateModelFromJson(Map<String, dynamic> json) =>
    OtpInitiateModel(email: json['email'] as String);

Map<String, dynamic> _$OtpInitiateModelToJson(OtpInitiateModel instance) =>
    <String, dynamic>{'email': instance.email};

OtpValidateModel _$OtpValidateModelFromJson(Map<String, dynamic> json) =>
    OtpValidateModel(
      email: json['email'] as String,
      otp: json['otp'] as String,
    );

Map<String, dynamic> _$OtpValidateModelToJson(OtpValidateModel instance) =>
    <String, dynamic>{'email': instance.email, 'otp': instance.otp};

MagicLinkInitiateModel _$MagicLinkInitiateModelFromJson(
  Map<String, dynamic> json,
) => MagicLinkInitiateModel(email: json['email'] as String);

Map<String, dynamic> _$MagicLinkInitiateModelToJson(
  MagicLinkInitiateModel instance,
) => <String, dynamic>{'email': instance.email};

MagicKeyValidateModel _$MagicKeyValidateModelFromJson(
  Map<String, dynamic> json,
) => MagicKeyValidateModel(magicKey: json['magic_key'] as String);

Map<String, dynamic> _$MagicKeyValidateModelToJson(
  MagicKeyValidateModel instance,
) => <String, dynamic>{'magic_key': instance.magicKey};

PasswordResetModel _$PasswordResetModelFromJson(Map<String, dynamic> json) =>
    PasswordResetModel(newPassword: json['new_password'] as String);

Map<String, dynamic> _$PasswordResetModelToJson(PasswordResetModel instance) =>
    <String, dynamic>{'new_password': instance.newPassword};
