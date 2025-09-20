// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'available_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailableMemberModel _$AvailableMemberModelFromJson(
  Map<String, dynamic> json,
) => AvailableMemberModel(
  userId: (json['user_id'] as num).toInt(),
  username: json['username'] as String,
  name: json['name'] as String,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  email: json['email'] as String,
  profilePictureUrl: json['profile_picture_url'] as String,
);

Map<String, dynamic> _$AvailableMemberModelToJson(
  AvailableMemberModel instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'username': instance.username,
  'name': instance.name,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'email': instance.email,
  'profile_picture_url': instance.profilePictureUrl,
};
