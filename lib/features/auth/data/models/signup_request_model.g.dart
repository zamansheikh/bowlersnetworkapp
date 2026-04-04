// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignupRequestModel _$SignupRequestModelFromJson(Map<String, dynamic> json) =>
    SignupRequestModel(
      signupData: SignupData.fromJson(
        json['signup_data'] as Map<String, dynamic>,
      ),
      verificationCode: json['verification_code'] as String,
      referrerUsername: json['referrer_username'] as String?,
    );

Map<String, dynamic> _$SignupRequestModelToJson(SignupRequestModel instance) =>
    <String, dynamic>{
      'signup_data': instance.signupData.toJson(),
      'verification_code': instance.verificationCode,
      'referrer_username': ?instance.referrerUsername,
    };

SignupData _$SignupDataFromJson(Map<String, dynamic> json) => SignupData(
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  email: json['email'] as String,
  username: json['username'] as String,
  password: json['password'] as String,
  dateOfBirth: json['date_of_birth'] as String,
  parentEmail: json['parent_email'] as String?,
  isCoach: json['is_coach'] as bool?,
);

Map<String, dynamic> _$SignupDataToJson(SignupData instance) =>
    <String, dynamic>{
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'username': instance.username,
      'password': instance.password,
      'date_of_birth': instance.dateOfBirth,
      'parent_email': ?instance.parentEmail,
      'is_coach': ?instance.isCoach,
    };
