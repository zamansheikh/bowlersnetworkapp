// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageResponse _$MessageResponseFromJson(Map<String, dynamic> json) =>
    MessageResponse(message: json['message'] as String);

Map<String, dynamic> _$SignupDataToJson(SignupData instance) =>
    <String, dynamic>{
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'username': instance.username,
      'password': instance.password,
      'date_of_birth': instance.dateOfBirth,
      'is_coach': ?instance.isCoach,
      'parent_email': ?instance.parentEmail,
    };

Map<String, dynamic> _$ValidateRegistrationRequestToJson(
  ValidateRegistrationRequest instance,
) => <String, dynamic>{
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'email': instance.email,
  'username': instance.username,
  'password': instance.password,
  'date_of_birth': instance.dateOfBirth,
  'parent_email': ?instance.parentEmail,
};

Map<String, dynamic> _$SignupSubmitRequestToJson(
  SignupSubmitRequest instance,
) => <String, dynamic>{'registration': instance.registration};

Map<String, dynamic> _$SignupCompleteRequestToJson(
  SignupCompleteRequest instance,
) => <String, dynamic>{
  'registration': instance.registration,
  'verification_code': instance.verificationCode,
  'favorite_brand_ids': instance.favoriteBrandIds,
  'referrer_username': ?instance.referrerUsername,
};

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'credential': instance.credential,
      'password': instance.password,
    };

AuthTokenResponse _$AuthTokenResponseFromJson(Map<String, dynamic> json) =>
    AuthTokenResponse(
      token: json['token'] as String,
      requiresConsent: json['requires_consent'] as bool? ?? false,
    );

Map<String, dynamic> _$EmailRequestToJson(EmailRequest instance) =>
    <String, dynamic>{'email': instance.email};

Map<String, dynamic> _$ValidateOtpRequestToJson(ValidateOtpRequest instance) =>
    <String, dynamic>{'email': instance.email, 'otp': instance.otp};

Map<String, dynamic> _$ValidateMagicKeyRequestToJson(
  ValidateMagicKeyRequest instance,
) => <String, dynamic>{'magic_key': instance.magicKey};

Map<String, dynamic> _$ResetPasswordRequestToJson(
  ResetPasswordRequest instance,
) => <String, dynamic>{'new_password': instance.newPassword};
