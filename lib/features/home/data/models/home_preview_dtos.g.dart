// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_preview_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomePreviewUserDto _$HomePreviewUserDtoFromJson(Map<String, dynamic> json) =>
    HomePreviewUserDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      profilePictureUrl: json['profile_picture_url'] as String?,
      badgeIconUrl: json['badge_icon_url'] as String?,
    );

DiscussionsPageDto _$DiscussionsPageDtoFromJson(Map<String, dynamic> json) =>
    DiscussionsPageDto(
      discussions:
          (json['discussions'] as List<dynamic>?)
              ?.map((e) => DiscussionDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

DiscussionDto _$DiscussionDtoFromJson(Map<String, dynamic> json) =>
    DiscussionDto(
      uid: json['uid'] as String,
      title: json['title'] as String? ?? '',
      author: json['author'] == null
          ? null
          : HomePreviewUserDto.fromJson(json['author'] as Map<String, dynamic>),
      topic: json['topic'] == null
          ? null
          : DiscussionTopicDto.fromJson(json['topic'] as Map<String, dynamic>),
      upvoteCount: (json['upvote_count'] as num?)?.toInt() ?? 0,
      opinionCount: (json['opinion_count'] as num?)?.toInt() ?? 0,
      isResolved: json['is_resolved'] as bool? ?? false,
    );

DiscussionTopicDto _$DiscussionTopicDtoFromJson(Map<String, dynamic> json) =>
    DiscussionTopicDto(name: json['name'] as String? ?? '');

VideosPageDto _$VideosPageDtoFromJson(Map<String, dynamic> json) =>
    VideosPageDto(
      videos:
          (json['videos'] as List<dynamic>?)
              ?.map((e) => MediaItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

SplitsPageDto _$SplitsPageDtoFromJson(Map<String, dynamic> json) =>
    SplitsPageDto(
      splits:
          (json['splits'] as List<dynamic>?)
              ?.map((e) => MediaItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

MediaItemDto _$MediaItemDtoFromJson(Map<String, dynamic> json) => MediaItemDto(
  uid: json['uid'] as String,
  title: json['title'] as String? ?? '',
  thumbnailUrl: json['thumbnail_url'] as String?,
  viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
  author: json['author'] == null
      ? null
      : HomePreviewUserDto.fromJson(json['author'] as Map<String, dynamic>),
);

EventsPageDto _$EventsPageDtoFromJson(Map<String, dynamic> json) =>
    EventsPageDto(
      events:
          (json['events'] as List<dynamic>?)
              ?.map((e) => EventItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

EventItemDto _$EventItemDtoFromJson(Map<String, dynamic> json) => EventItemDto(
  uid: json['uid'] as String,
  title: json['title'] as String? ?? '',
  eventDate: json['event_date'] as String?,
  eventType: json['event_type'] == null
      ? null
      : EventTypeRefDto.fromJson(json['event_type'] as Map<String, dynamic>),
  location: json['location'] == null
      ? null
      : EventLocationDto.fromJson(json['location'] as Map<String, dynamic>),
  isOnline: json['is_online'] as bool? ?? false,
);

EventTypeRefDto _$EventTypeRefDtoFromJson(Map<String, dynamic> json) =>
    EventTypeRefDto(name: json['name'] as String? ?? '');

EventLocationDto _$EventLocationDtoFromJson(Map<String, dynamic> json) =>
    EventLocationDto(
      name: json['name'] as String?,
      address: json['address'] as String?,
      center: json['center'] == null
          ? null
          : EventCenterDto.fromJson(json['center'] as Map<String, dynamic>),
    );

EventCenterDto _$EventCenterDtoFromJson(Map<String, dynamic> json) =>
    EventCenterDto(name: json['name'] as String?);

LiveBroadcastsPageDto _$LiveBroadcastsPageDtoFromJson(
  Map<String, dynamic> json,
) => LiveBroadcastsPageDto(
  entries:
      (json['entries'] as List<dynamic>?)
          ?.map((e) => LiveBroadcastDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

LiveBroadcastDto _$LiveBroadcastDtoFromJson(Map<String, dynamic> json) =>
    LiveBroadcastDto(
      id: (json['id'] as num).toInt(),
      uid: json['uid'] as String,
      title: json['title'] as String? ?? '',
      viewerCount: (json['viewer_count'] as num?)?.toInt() ?? 0,
      reactionsCount: (json['reactions_count'] as num?)?.toInt() ?? 0,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      user: json['user'] == null
          ? null
          : HomePreviewUserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
