// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationModel _$ConversationModelFromJson(Map<String, dynamic> json) =>
    ConversationModel(
      roomId: (json['room_id'] as num).toInt(),
      name: json['name'] as String,
      displayName: json['display_name'] as String,
      displayImageUrl: json['display_image_url'] as String,
      type: json['type'] as String,
      lastActivity: json['last_activity'] as String,
      lastMessage: json['last_message'] == null
          ? null
          : MessageModel.fromJson(json['last_message'] as Map<String, dynamic>),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ConversationModelToJson(ConversationModel instance) =>
    <String, dynamic>{
      'room_id': instance.roomId,
      'name': instance.name,
      'display_name': instance.displayName,
      'display_image_url': instance.displayImageUrl,
      'type': instance.type,
      'last_activity': instance.lastActivity,
      'last_message': instance.lastMessage,
      'unreadCount': instance.unreadCount,
    };
