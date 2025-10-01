// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'available_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailableMemberModel _$AvailableMemberModelFromJson(
  Map<String, dynamic> json,
) => AvailableMemberModel(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  email: json['email'] as String,
  fullName: json['full_name'] as String?,
  profilePicture: json['profile_picture'] as String?,
  bowlingAverage: (json['bowling_average'] as num?)?.toDouble(),
  isPremium: json['is_premium'] as bool,
);

Map<String, dynamic> _$AvailableMemberModelToJson(
  AvailableMemberModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'full_name': instance.fullName,
  'profile_picture': instance.profilePicture,
  'bowling_average': instance.bowlingAverage,
  'is_premium': instance.isPremium,
};
