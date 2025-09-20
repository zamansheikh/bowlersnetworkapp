// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
  sentByMe: json['sentByMe'] as bool,
  roomId: (json['roomID'] as num).toInt(),
  sender: MessageSenderModel.fromJson(json['sender'] as Map<String, dynamic>),
  timeDetails: TimeDetailsModel.fromJson(
    json['timeDetails'] as Map<String, dynamic>,
  ),
  message: MessageContentModel.fromJson(
    json['message'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'sentByMe': instance.sentByMe,
      'roomID': instance.roomId,
      'sender': instance.sender,
      'timeDetails': instance.timeDetails,
      'message': instance.message,
    };
