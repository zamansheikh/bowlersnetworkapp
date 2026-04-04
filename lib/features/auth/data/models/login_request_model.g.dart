// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequestModel _$LoginRequestModelFromJson(Map<String, dynamic> json) =>
    LoginRequestModel(
      credential: json['credential'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestModelToJson(LoginRequestModel instance) =>
    <String, dynamic>{
      'credential': instance.credential,
      'password': instance.password,
    };
