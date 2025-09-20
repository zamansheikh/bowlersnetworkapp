// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_rooms_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRoomsResponseModel _$ChatRoomsResponseModelFromJson(
  Map<String, dynamic> json,
) => ChatRoomsResponseModel(
  private: (json['private'] as List<dynamic>)
      .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  group: (json['group'] as List<dynamic>)
      .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ChatRoomsResponseModelToJson(
  ChatRoomsResponseModel instance,
) => <String, dynamic>{'private': instance.private, 'group': instance.group};
