import 'package:json_annotation/json_annotation.dart';

part 'chatter_dtos.g.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Slim author shape — every author/user field in chatter payloads expands
// user_minimal with an `is_elite` flag from the credibility system.
// ──────────────────────────────────────────────────────────────────────────────
@JsonSerializable(createToJson: false)
class ChatterAuthorDto {
  const ChatterAuthorDto({
    this.id = 0,
    this.username = '',
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
    this.isPro = false,
    this.isElite = false,
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
  @JsonKey(name: 'is_elite', defaultValue: false)
  final bool isElite;
  @JsonKey(name: 'rank_display')
  final String? rankDisplay;
  @JsonKey(name: 'badge_icon_url')
  final String? badgeIconUrl;

  factory ChatterAuthorDto.fromJson(Map<String, dynamic> json) =>
      _$ChatterAuthorDtoFromJson(json);
}

// ──────────────────────────────────────────────────────────────────────────────
// Topic
// ──────────────────────────────────────────────────────────────────────────────
@JsonSerializable(createToJson: false)
class TopicDto {
  const TopicDto({
    this.id = 0,
    this.name = '',
    this.description = '',
    this.bannerUrl,
    this.threadCount = 0,
  });

  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: '')
  final String description;
  @JsonKey(name: 'banner_url')
  final String? bannerUrl;
  @JsonKey(name: 'thread_count', defaultValue: 0)
  final int threadCount;

  factory TopicDto.fromJson(Map<String, dynamic> json) =>
      _$TopicDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TopicsResponseDto {
  const TopicsResponseDto({this.topics = const []});
  final List<TopicDto> topics;
  factory TopicsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TopicsResponseDtoFromJson(json);
}

// ──────────────────────────────────────────────────────────────────────────────
// Discussion — full shape covers both list items and the detail endpoint.
// On list items, `body` and `tags` may be present or empty depending on the
// backend serializer; viewer flags may be absent for anonymous browsing.
// ──────────────────────────────────────────────────────────────────────────────
@JsonSerializable(createToJson: false)
class DiscussionFullDto {
  const DiscussionFullDto({
    required this.id,
    required this.uid,
    this.title = '',
    this.body = '',
    this.author,
    this.topic,
    this.tags = const [],
    this.upvoteCount = 0,
    this.downvoteCount = 0,
    this.opinionCount = 0,
    this.viewCount = 0,
    this.saveCount = 0,
    this.isResolved = false,
    this.isLocked = false,
    this.isPinned = false,
    this.isEdited = false,
    this.isMostRead = false,
    this.createdAt,
    this.isMine,
    this.hasUpvoted,
    this.hasDownvoted,
    this.hasSaved,
  });

  final int id;
  final String uid;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(defaultValue: '')
  final String body;
  final ChatterAuthorDto? author;
  final TopicDto? topic;
  final List<String> tags;
  @JsonKey(name: 'upvote_count', defaultValue: 0)
  final int upvoteCount;
  @JsonKey(name: 'downvote_count', defaultValue: 0)
  final int downvoteCount;
  @JsonKey(name: 'opinion_count', defaultValue: 0)
  final int opinionCount;
  @JsonKey(name: 'view_count', defaultValue: 0)
  final int viewCount;
  @JsonKey(name: 'save_count', defaultValue: 0)
  final int saveCount;
  @JsonKey(name: 'is_resolved', defaultValue: false)
  final bool isResolved;
  @JsonKey(name: 'is_locked', defaultValue: false)
  final bool isLocked;
  @JsonKey(name: 'is_pinned', defaultValue: false)
  final bool isPinned;
  @JsonKey(name: 'is_edited', defaultValue: false)
  final bool isEdited;
  @JsonKey(name: 'is_most_read', defaultValue: false)
  final bool isMostRead;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'is_mine')
  final bool? isMine;
  @JsonKey(name: 'has_upvoted')
  final bool? hasUpvoted;
  @JsonKey(name: 'has_downvoted')
  final bool? hasDownvoted;
  @JsonKey(name: 'has_saved')
  final bool? hasSaved;

  factory DiscussionFullDto.fromJson(Map<String, dynamic> json) =>
      _$DiscussionFullDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class DiscussionsPageDto {
  const DiscussionsPageDto({
    this.discussions = const [],
    this.page = 1,
    this.pageSize = 20,
  });

  final List<DiscussionFullDto> discussions;
  @JsonKey(defaultValue: 1)
  final int page;
  @JsonKey(name: 'page_size', defaultValue: 20)
  final int pageSize;

  factory DiscussionsPageDto.fromJson(Map<String, dynamic> json) =>
      _$DiscussionsPageDtoFromJson(json);
}

// ──────────────────────────────────────────────────────────────────────────────
// Opinion (comment)
// ──────────────────────────────────────────────────────────────────────────────
@JsonSerializable(createToJson: false)
class OpinionDto {
  const OpinionDto({
    required this.id,
    this.body = '',
    this.author,
    this.upvoteCount = 0,
    this.downvoteCount = 0,
    this.netScore = 0,
    this.replyCount = 0,
    this.isAcknowledged = false,
    this.isPinned = false,
    this.isEdited = false,
    this.isHidden = false,
    this.createdAt,
    this.parentId,
    this.isMine,
    this.hasUpvoted,
    this.hasDownvoted,
  });

  final int id;
  @JsonKey(defaultValue: '')
  final String body;
  final ChatterAuthorDto? author;
  @JsonKey(name: 'upvote_count', defaultValue: 0)
  final int upvoteCount;
  @JsonKey(name: 'downvote_count', defaultValue: 0)
  final int downvoteCount;
  @JsonKey(name: 'net_score', defaultValue: 0)
  final int netScore;
  @JsonKey(name: 'reply_count', defaultValue: 0)
  final int replyCount;
  @JsonKey(name: 'is_acknowledged', defaultValue: false)
  final bool isAcknowledged;
  @JsonKey(name: 'is_pinned', defaultValue: false)
  final bool isPinned;
  @JsonKey(name: 'is_edited', defaultValue: false)
  final bool isEdited;
  @JsonKey(name: 'is_hidden', defaultValue: false)
  final bool isHidden;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'parent_id')
  final int? parentId;
  @JsonKey(name: 'is_mine')
  final bool? isMine;
  @JsonKey(name: 'has_upvoted')
  final bool? hasUpvoted;
  @JsonKey(name: 'has_downvoted')
  final bool? hasDownvoted;

  factory OpinionDto.fromJson(Map<String, dynamic> json) =>
      _$OpinionDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class OpinionsPageDto {
  const OpinionsPageDto({
    this.opinions = const [],
    this.page = 1,
    this.pageSize = 20,
  });

  final List<OpinionDto> opinions;
  @JsonKey(defaultValue: 1)
  final int page;
  @JsonKey(name: 'page_size', defaultValue: 20)
  final int pageSize;

  factory OpinionsPageDto.fromJson(Map<String, dynamic> json) =>
      _$OpinionsPageDtoFromJson(json);
}

// ──────────────────────────────────────────────────────────────────────────────
// Vote toggle response — same shape for both discussions and opinions.
// `action` is one of `added`, `removed`, `changed`; `vote_type` is
// `upvote`, `downvote`, or null (when removed).
// ──────────────────────────────────────────────────────────────────────────────
@JsonSerializable(createToJson: false)
class VoteToggleDto {
  const VoteToggleDto({this.action = '', this.voteType});

  @JsonKey(defaultValue: '')
  final String action;
  @JsonKey(name: 'vote_type')
  final String? voteType;

  factory VoteToggleDto.fromJson(Map<String, dynamic> json) =>
      _$VoteToggleDtoFromJson(json);
}
