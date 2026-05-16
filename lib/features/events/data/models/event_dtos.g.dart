// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventUserDto _$EventUserDtoFromJson(Map<String, dynamic> json) => EventUserDto(
  id: (json['id'] as num?)?.toInt() ?? 0,
  username: json['username'] as String? ?? '',
  firstName: json['first_name'] as String? ?? '',
  lastName: json['last_name'] as String? ?? '',
  profilePictureUrl: json['profile_picture_url'] as String?,
  isPro: json['is_pro'] as bool? ?? false,
  rankDisplay: json['rank_display'] as String?,
  badgeIconUrl: json['badge_icon_url'] as String?,
);

EventTypeDto _$EventTypeDtoFromJson(Map<String, dynamic> json) => EventTypeDto(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
);

EventCenterDto _$EventCenterDtoFromJson(Map<String, dynamic> json) =>
    EventCenterDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String?,
      lanes: (json['lanes'] as num?)?.toInt(),
    );

EventLocationDto _$EventLocationDtoFromJson(Map<String, dynamic> json) =>
    EventLocationDto(
      isCenter: json['is_center'] as bool? ?? false,
      center: json['center'] == null
          ? null
          : EventCenterDto.fromJson(json['center'] as Map<String, dynamic>),
      address: json['address'] as String? ?? '',
      zipCode: json['zip_code'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

EventDto _$EventDtoFromJson(Map<String, dynamic> json) => EventDto(
  uid: json['uid'] as String,
  title: json['title'] as String? ?? '',
  description: json['description'] as String? ?? '',
  eventType: json['event_type'] == null
      ? null
      : EventTypeDto.fromJson(json['event_type'] as Map<String, dynamic>),
  creator: json['creator'] == null
      ? null
      : EventUserDto.fromJson(json['creator'] as Map<String, dynamic>),
  flyerUrl: json['flyer_url'] as String?,
  isOnline: json['is_online'] as bool? ?? false,
  eventDate: json['event_date'] as String?,
  location: json['location'] == null
      ? null
      : EventLocationDto.fromJson(json['location'] as Map<String, dynamic>),
  interestedCount: (json['interested_count'] as num?)?.toInt() ?? 0,
  goingCount: (json['going_count'] as num?)?.toInt() ?? 0,
  notesCount: (json['notes_count'] as num?)?.toInt() ?? 0,
  isInterested: json['is_interested'] as bool?,
  invitationStatus: json['invitation_status'] as String?,
  isCreator: json['is_creator'] as bool?,
  createdAt: json['created_at'] as String?,
);

EventsFeedDto _$EventsFeedDtoFromJson(Map<String, dynamic> json) =>
    EventsFeedDto(
      events:
          (json['events'] as List<dynamic>?)
              ?.map((e) => EventDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
    );

EventInterestToggleDto _$EventInterestToggleDtoFromJson(
  Map<String, dynamic> json,
) => EventInterestToggleDto(
  isInterested: json['is_interested'] as bool? ?? false,
  interestedCount: (json['interested_count'] as num?)?.toInt() ?? 0,
);

EventTypeListItemDto _$EventTypeListItemDtoFromJson(
  Map<String, dynamic> json,
) => EventTypeListItemDto(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
);

EventUserListPageDto _$EventUserListPageDtoFromJson(
  Map<String, dynamic> json,
) => EventUserListPageDto(
  users:
      (json['users'] as List<dynamic>?)
          ?.map((e) => EventUserDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  page: (json['page'] as num?)?.toInt() ?? 1,
  pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
);

EventNoteDto _$EventNoteDtoFromJson(Map<String, dynamic> json) => EventNoteDto(
  id: (json['id'] as num).toInt(),
  author: json['author'] == null
      ? null
      : EventUserDto.fromJson(json['author'] as Map<String, dynamic>),
  content: json['content'] as String? ?? '',
  reply: json['reply'] as String? ?? '',
  repliedAt: json['replied_at'] as String?,
  isByCreator: json['is_by_creator'] as bool? ?? false,
  createdAt: json['created_at'] as String?,
);

EventNotesPageDto _$EventNotesPageDtoFromJson(Map<String, dynamic> json) =>
    EventNotesPageDto(
      notes:
          (json['notes'] as List<dynamic>?)
              ?.map((e) => EventNoteDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
    );

EventReferenceDto _$EventReferenceDtoFromJson(Map<String, dynamic> json) =>
    EventReferenceDto(
      uid: json['uid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      eventDate: json['event_date'] as String?,
    );

EventInvitationDto _$EventInvitationDtoFromJson(Map<String, dynamic> json) =>
    EventInvitationDto(
      id: (json['id'] as num).toInt(),
      event: json['event'] == null
          ? null
          : EventReferenceDto.fromJson(json['event'] as Map<String, dynamic>),
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] as String?,
      respondedAt: json['responded_at'] as String?,
    );

EventInvitationsPageDto _$EventInvitationsPageDtoFromJson(
  Map<String, dynamic> json,
) => EventInvitationsPageDto(
  invitations:
      (json['invitations'] as List<dynamic>?)
          ?.map((e) => EventInvitationDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  page: (json['page'] as num?)?.toInt() ?? 1,
  pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
);

EventInviteDiscoverDto _$EventInviteDiscoverDtoFromJson(
  Map<String, dynamic> json,
) => EventInviteDiscoverDto(
  users:
      (json['users'] as List<dynamic>?)
          ?.map((e) => EventUserDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

EventInviteSentDto _$EventInviteSentDtoFromJson(Map<String, dynamic> json) =>
    EventInviteSentDto(
      invitationsSent: (json['invitations_sent'] as num?)?.toInt() ?? 0,
    );
