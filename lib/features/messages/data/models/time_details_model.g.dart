// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeDetailsModel _$TimeDetailsModelFromJson(Map<String, dynamic> json) =>
    TimeDetailsModel(
      sentAt: json['sent_at'] as String,
      timesince: json['timesince'] as String,
    );

Map<String, dynamic> _$TimeDetailsModelToJson(TimeDetailsModel instance) =>
    <String, dynamic>{
      'sent_at': instance.sentAt,
      'timesince': instance.timesince,
    };
