// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationPreferencesDto _$NotificationPreferencesDtoFromJson(
  Map<String, dynamic> json,
) => NotificationPreferencesDto(
  reactions: json['reactions'] as bool? ?? true,
  comments: json['comments'] as bool? ?? true,
  follows: json['follows'] as bool? ?? true,
  chatterVotes: json['chatter_votes'] as bool? ?? true,
  eventInvitations: json['event_invitations'] as bool? ?? true,
  teamInvitations: json['team_invitations'] as bool? ?? true,
  cardCollections: json['card_collections'] as bool? ?? true,
  messages: json['messages'] as bool? ?? true,
  xpLevelUps: json['xp_level_ups'] as bool? ?? true,
);

Map<String, dynamic> _$NotificationPreferencesDtoToJson(
  NotificationPreferencesDto instance,
) => <String, dynamic>{
  'reactions': instance.reactions,
  'comments': instance.comments,
  'follows': instance.follows,
  'chatter_votes': instance.chatterVotes,
  'event_invitations': instance.eventInvitations,
  'team_invitations': instance.teamInvitations,
  'card_collections': instance.cardCollections,
  'messages': instance.messages,
  'xp_level_ups': instance.xpLevelUps,
};
