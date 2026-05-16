import 'package:json_annotation/json_annotation.dart';

part 'notification_preferences_dto.g.dart';

/// `GET /api/notifications/preferences` response. PATCH accepts the same
/// shape (any subset of fields). Every flag defaults true server-side
/// so a missing key in the response means "on".
@JsonSerializable(createToJson: true)
class NotificationPreferencesDto {
  const NotificationPreferencesDto({
    this.reactions = true,
    this.comments = true,
    this.follows = true,
    this.chatterVotes = true,
    this.eventInvitations = true,
    this.teamInvitations = true,
    this.cardCollections = true,
    this.messages = true,
    this.xpLevelUps = true,
  });

  @JsonKey(defaultValue: true)
  final bool reactions;
  @JsonKey(defaultValue: true)
  final bool comments;
  @JsonKey(defaultValue: true)
  final bool follows;
  @JsonKey(name: 'chatter_votes', defaultValue: true)
  final bool chatterVotes;
  @JsonKey(name: 'event_invitations', defaultValue: true)
  final bool eventInvitations;
  @JsonKey(name: 'team_invitations', defaultValue: true)
  final bool teamInvitations;
  @JsonKey(name: 'card_collections', defaultValue: true)
  final bool cardCollections;
  @JsonKey(defaultValue: true)
  final bool messages;
  @JsonKey(name: 'xp_level_ups', defaultValue: true)
  final bool xpLevelUps;

  factory NotificationPreferencesDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$NotificationPreferencesDtoToJson(this);
}
