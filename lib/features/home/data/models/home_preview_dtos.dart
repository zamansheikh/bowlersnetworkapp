import 'package:json_annotation/json_annotation.dart';

part 'home_preview_dtos.g.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Tiny author shape — every preview list payload nests a slimmed-down user.
// ──────────────────────────────────────────────────────────────────────────────
@JsonSerializable(createToJson: false)
class HomePreviewUserDto {
  const HomePreviewUserDto({
    this.id = 0,
    this.username = '',
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
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
  @JsonKey(name: 'badge_icon_url')
  final String? badgeIconUrl;

  factory HomePreviewUserDto.fromJson(Map<String, dynamic> json) =>
      _$HomePreviewUserDtoFromJson(json);
}

// ──────────────────────────────────────────────────────────────────────────────
// GET /api/chatter/discussions  →  `{discussions: [...]}` or `{results: [...]}`
// ──────────────────────────────────────────────────────────────────────────────
@JsonSerializable(createToJson: false)
class DiscussionsPageDto {
  const DiscussionsPageDto({this.discussions = const []});

  @JsonKey(defaultValue: [])
  final List<DiscussionDto> discussions;

  factory DiscussionsPageDto.fromJson(Map<String, dynamic> json) =>
      _$DiscussionsPageDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class DiscussionDto {
  const DiscussionDto({
    required this.uid,
    this.title = '',
    this.author,
    this.topic,
    this.upvoteCount = 0,
    this.opinionCount = 0,
    this.isResolved = false,
  });

  final String uid;
  @JsonKey(defaultValue: '')
  final String title;
  final HomePreviewUserDto? author;
  final DiscussionTopicDto? topic;
  @JsonKey(name: 'upvote_count', defaultValue: 0)
  final int upvoteCount;
  @JsonKey(name: 'opinion_count', defaultValue: 0)
  final int opinionCount;
  @JsonKey(name: 'is_resolved', defaultValue: false)
  final bool isResolved;

  factory DiscussionDto.fromJson(Map<String, dynamic> json) =>
      _$DiscussionDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class DiscussionTopicDto {
  const DiscussionTopicDto({this.name = ''});
  @JsonKey(defaultValue: '')
  final String name;
  factory DiscussionTopicDto.fromJson(Map<String, dynamic> json) =>
      _$DiscussionTopicDtoFromJson(json);
}

// ──────────────────────────────────────────────────────────────────────────────
// GET /api/media/videos  &  /api/media/splits  → media list payload
// ──────────────────────────────────────────────────────────────────────────────
@JsonSerializable(createToJson: false)
class VideosPageDto {
  const VideosPageDto({this.videos = const []});
  @JsonKey(defaultValue: [])
  final List<MediaItemDto> videos;
  factory VideosPageDto.fromJson(Map<String, dynamic> json) =>
      _$VideosPageDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class SplitsPageDto {
  const SplitsPageDto({this.splits = const []});
  @JsonKey(defaultValue: [])
  final List<MediaItemDto> splits;
  factory SplitsPageDto.fromJson(Map<String, dynamic> json) =>
      _$SplitsPageDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class MediaItemDto {
  const MediaItemDto({
    required this.uid,
    this.title = '',
    this.thumbnailUrl,
    this.viewsCount = 0,
    this.author,
  });

  final String uid;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @JsonKey(name: 'views_count', defaultValue: 0)
  final int viewsCount;
  final HomePreviewUserDto? author;

  factory MediaItemDto.fromJson(Map<String, dynamic> json) =>
      _$MediaItemDtoFromJson(json);
}

// ──────────────────────────────────────────────────────────────────────────────
// GET /api/events/feed?scope=upcoming
// ──────────────────────────────────────────────────────────────────────────────
@JsonSerializable(createToJson: false)
class EventsPageDto {
  const EventsPageDto({this.events = const []});
  @JsonKey(defaultValue: [])
  final List<EventItemDto> events;
  factory EventsPageDto.fromJson(Map<String, dynamic> json) =>
      _$EventsPageDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class EventItemDto {
  const EventItemDto({
    required this.uid,
    this.title = '',
    this.eventDate,
    this.eventType,
    this.location,
    this.isOnline = false,
  });

  final String uid;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(name: 'event_date')
  final String? eventDate;
  @JsonKey(name: 'event_type')
  final EventTypeRefDto? eventType;
  final EventLocationDto? location;
  @JsonKey(name: 'is_online', defaultValue: false)
  final bool isOnline;

  factory EventItemDto.fromJson(Map<String, dynamic> json) =>
      _$EventItemDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class EventTypeRefDto {
  const EventTypeRefDto({this.name = ''});
  @JsonKey(defaultValue: '')
  final String name;
  factory EventTypeRefDto.fromJson(Map<String, dynamic> json) =>
      _$EventTypeRefDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class EventLocationDto {
  const EventLocationDto({this.name, this.address, this.center});
  final String? name;
  final String? address;
  final EventCenterDto? center;
  factory EventLocationDto.fromJson(Map<String, dynamic> json) =>
      _$EventLocationDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class EventCenterDto {
  const EventCenterDto({this.name});
  final String? name;
  factory EventCenterDto.fromJson(Map<String, dynamic> json) =>
      _$EventCenterDtoFromJson(json);
}

// ──────────────────────────────────────────────────────────────────────────────
// GET /api/games/lives  → `{entries: [...]}`  (filtered with ?scope=following)
// ──────────────────────────────────────────────────────────────────────────────
@JsonSerializable(createToJson: false)
class LiveBroadcastsPageDto {
  const LiveBroadcastsPageDto({this.entries = const []});
  @JsonKey(defaultValue: [])
  final List<LiveBroadcastDto> entries;
  factory LiveBroadcastsPageDto.fromJson(Map<String, dynamic> json) =>
      _$LiveBroadcastsPageDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class LiveBroadcastDto {
  const LiveBroadcastDto({
    required this.id,
    required this.uid,
    this.title = '',
    this.viewerCount = 0,
    this.reactionsCount = 0,
    this.commentsCount = 0,
    this.user,
  });

  final int id;
  final String uid;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(name: 'viewer_count', defaultValue: 0)
  final int viewerCount;
  @JsonKey(name: 'reactions_count', defaultValue: 0)
  final int reactionsCount;
  @JsonKey(name: 'comments_count', defaultValue: 0)
  final int commentsCount;
  final HomePreviewUserDto? user;

  factory LiveBroadcastDto.fromJson(Map<String, dynamic> json) =>
      _$LiveBroadcastDtoFromJson(json);
}
