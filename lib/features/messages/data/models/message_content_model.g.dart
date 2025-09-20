// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_content_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageContentModel _$MessageContentModelFromJson(Map<String, dynamic> json) =>
    MessageContentModel(
      text: json['text'] as String,
      media: (json['media'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$MessageContentModelToJson(
  MessageContentModel instance,
) => <String, dynamic>{'text': instance.text, 'media': instance.media};
