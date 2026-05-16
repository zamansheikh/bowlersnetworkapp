import 'package:json_annotation/json_annotation.dart';

part 'event_dtos.g.dart';

/// Slim creator/organiser shape — every event payload nests this.
/// Mirrors `user_minimal` plus rank/badge fields the detail card uses.
@JsonSerializable(createToJson: false)
class EventUserDto {
  const EventUserDto({
    this.id = 0,
    this.username = '',
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
    this.isPro = false,
    this.rankDisplay,
    this.badgeIconUrl,
  });

  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String username;
  @JsonKey(name: 'first_name', defaultValue: '')
  final String firstName;
  @JsonKey(name: 'last_name', defaultValue: '')
  final String lastName;
  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;
  @JsonKey(name: 'is_pro', defaultValue: false)
  final bool isPro;
  @JsonKey(name: 'rank_display')
  final String? rankDisplay;
  @JsonKey(name: 'badge_icon_url')
  final String? badgeIconUrl;

  factory EventUserDto.fromJson(Map<String, dynamic> json) =>
      _$EventUserDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class EventTypeDto {
  const EventTypeDto({this.id = 0, this.name = ''});
  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String name;
  factory EventTypeDto.fromJson(Map<String, dynamic> json) =>
      _$EventTypeDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class EventCenterDto {
  const EventCenterDto({
    this.id = 0,
    this.name = '',
    this.logo,
    this.lanes,
  });
  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String name;
  final String? logo;
  final int? lanes;
  factory EventCenterDto.fromJson(Map<String, dynamic> json) =>
      _$EventCenterDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class EventLocationDto {
  const EventLocationDto({
    this.isCenter = false,
    this.center,
    this.address = '',
    this.zipCode = '',
    this.latitude,
    this.longitude,
  });
  @JsonKey(name: 'is_center', defaultValue: false)
  final bool isCenter;
  final EventCenterDto? center;
  @JsonKey(defaultValue: '')
  final String address;
  @JsonKey(name: 'zip_code', defaultValue: '')
  final String zipCode;
  final double? latitude;
  final double? longitude;

  factory EventLocationDto.fromJson(Map<String, dynamic> json) =>
      _$EventLocationDtoFromJson(json);
}

/// Full event payload — list endpoint + detail endpoint return the same
/// shape modulo a handful of detail-only fields. List items still have
/// title/date/location/counts; detail adds full description, capacity,
/// registration metadata.
@JsonSerializable(createToJson: false)
class EventDto {
  const EventDto({
    required this.uid,
    this.title = '',
    this.description = '',
    this.eventType,
    this.creator,
    this.flyerUrl,
    this.isOnline = false,
    this.eventDate,
    this.location,
    this.interestedCount = 0,
    this.goingCount = 0,
    this.notesCount = 0,
    this.isInterested,
    this.invitationStatus,
    this.isCreator,
    this.createdAt,
  });

  final String uid;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(defaultValue: '')
  final String description;
  @JsonKey(name: 'event_type')
  final EventTypeDto? eventType;
  final EventUserDto? creator;
  @JsonKey(name: 'flyer_url')
  final String? flyerUrl;
  @JsonKey(name: 'is_online', defaultValue: false)
  final bool isOnline;
  @JsonKey(name: 'event_date')
  final String? eventDate;
  final EventLocationDto? location;
  @JsonKey(name: 'interested_count', defaultValue: 0)
  final int interestedCount;
  @JsonKey(name: 'going_count', defaultValue: 0)
  final int goingCount;
  @JsonKey(name: 'notes_count', defaultValue: 0)
  final int notesCount;
  @JsonKey(name: 'is_interested')
  final bool? isInterested;

  /// One of `pending` | `accepted` | `declined` | null.
  @JsonKey(name: 'invitation_status')
  final String? invitationStatus;
  @JsonKey(name: 'is_creator')
  final bool? isCreator;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  factory EventDto.fromJson(Map<String, dynamic> json) =>
      _$EventDtoFromJson(json);
}

/// Wrapper for `GET /api/events/feed`.
@JsonSerializable(createToJson: false)
class EventsFeedDto {
  const EventsFeedDto({
    this.events = const [],
    this.page = 1,
    this.pageSize = 20,
  });

  final List<EventDto> events;
  @JsonKey(defaultValue: 1)
  final int page;
  @JsonKey(name: 'page_size', defaultValue: 20)
  final int pageSize;

  factory EventsFeedDto.fromJson(Map<String, dynamic> json) =>
      _$EventsFeedDtoFromJson(json);
}

/// Response from `POST /api/events/{uid}/interest`. Mirrors the
/// authoritative state the backend hands back.
@JsonSerializable(createToJson: false)
class EventInterestToggleDto {
  const EventInterestToggleDto({
    this.isInterested = false,
    this.interestedCount = 0,
  });
  @JsonKey(name: 'is_interested', defaultValue: false)
  final bool isInterested;
  @JsonKey(name: 'interested_count', defaultValue: 0)
  final int interestedCount;
  factory EventInterestToggleDto.fromJson(Map<String, dynamic> json) =>
      _$EventInterestToggleDtoFromJson(json);
}

/// `GET /api/events/types` — bare list response.
@JsonSerializable(createToJson: false)
class EventTypeListItemDto {
  const EventTypeListItemDto({this.id = 0, this.name = ''});
  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String name;
  factory EventTypeListItemDto.fromJson(Map<String, dynamic> json) =>
      _$EventTypeListItemDtoFromJson(json);
}

/// `GET /api/events/{uid}/interested` and `/going` page envelope.
@JsonSerializable(createToJson: false)
class EventUserListPageDto {
  const EventUserListPageDto({
    this.users = const [],
    this.page = 1,
    this.pageSize = 20,
  });

  final List<EventUserDto> users;
  @JsonKey(defaultValue: 1)
  final int page;
  @JsonKey(name: 'page_size', defaultValue: 20)
  final int pageSize;

  factory EventUserListPageDto.fromJson(Map<String, dynamic> json) =>
      _$EventUserListPageDtoFromJson(json);
}

/// One Q&A note. `reply` + `replied_at` are populated only after the
/// event creator answers.
@JsonSerializable(createToJson: false)
class EventNoteDto {
  const EventNoteDto({
    required this.id,
    this.author,
    this.content = '',
    this.reply = '',
    this.repliedAt,
    this.isByCreator = false,
    this.createdAt,
  });

  final int id;
  final EventUserDto? author;
  @JsonKey(defaultValue: '')
  final String content;
  @JsonKey(defaultValue: '')
  final String reply;
  @JsonKey(name: 'replied_at')
  final String? repliedAt;
  @JsonKey(name: 'is_by_creator', defaultValue: false)
  final bool isByCreator;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  factory EventNoteDto.fromJson(Map<String, dynamic> json) =>
      _$EventNoteDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class EventNotesPageDto {
  const EventNotesPageDto({
    this.notes = const [],
    this.page = 1,
    this.pageSize = 20,
  });
  final List<EventNoteDto> notes;
  @JsonKey(defaultValue: 1)
  final int page;
  @JsonKey(name: 'page_size', defaultValue: 20)
  final int pageSize;
  factory EventNotesPageDto.fromJson(Map<String, dynamic> json) =>
      _$EventNotesPageDtoFromJson(json);
}

/// Thin event reference embedded inside an invitation.
@JsonSerializable(createToJson: false)
class EventReferenceDto {
  const EventReferenceDto({this.uid = '', this.title = '', this.eventDate});
  @JsonKey(defaultValue: '')
  final String uid;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(name: 'event_date')
  final String? eventDate;
  factory EventReferenceDto.fromJson(Map<String, dynamic> json) =>
      _$EventReferenceDtoFromJson(json);
}

/// One invitation the viewer has received. `status` is one of
/// `pending` | `accepted` | `declined`.
@JsonSerializable(createToJson: false)
class EventInvitationDto {
  const EventInvitationDto({
    required this.id,
    this.event,
    this.status = 'pending',
    this.createdAt,
    this.respondedAt,
  });

  final int id;
  final EventReferenceDto? event;
  @JsonKey(defaultValue: 'pending')
  final String status;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'responded_at')
  final String? respondedAt;

  factory EventInvitationDto.fromJson(Map<String, dynamic> json) =>
      _$EventInvitationDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class EventInvitationsPageDto {
  const EventInvitationsPageDto({
    this.invitations = const [],
    this.page = 1,
    this.pageSize = 20,
  });
  final List<EventInvitationDto> invitations;
  @JsonKey(defaultValue: 1)
  final int page;
  @JsonKey(name: 'page_size', defaultValue: 20)
  final int pageSize;
  factory EventInvitationsPageDto.fromJson(Map<String, dynamic> json) =>
      _$EventInvitationsPageDtoFromJson(json);
}

/// `GET /api/events/{uid}/invite/discover` — bare `{users: [...]}`
/// (no pagination — server caps at 50).
@JsonSerializable(createToJson: false)
class EventInviteDiscoverDto {
  const EventInviteDiscoverDto({this.users = const []});
  final List<EventUserDto> users;
  factory EventInviteDiscoverDto.fromJson(Map<String, dynamic> json) =>
      _$EventInviteDiscoverDtoFromJson(json);
}

/// `POST /api/events/{uid}/invite` response — we only surface the count.
@JsonSerializable(createToJson: false)
class EventInviteSentDto {
  const EventInviteSentDto({this.invitationsSent = 0});
  @JsonKey(name: 'invitations_sent', defaultValue: 0)
  final int invitationsSent;
  factory EventInviteSentDto.fromJson(Map<String, dynamic> json) =>
      _$EventInviteSentDtoFromJson(json);
}
