// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatter_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatterAuthorDto _$ChatterAuthorDtoFromJson(Map<String, dynamic> json) =>
    ChatterAuthorDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      profilePictureUrl: json['profile_picture_url'] as String?,
      isPro: json['is_pro'] as bool? ?? false,
      isElite: json['is_elite'] as bool? ?? false,
      rankDisplay: json['rank_display'] as String?,
      badgeIconUrl: json['badge_icon_url'] as String?,
    );

TopicDto _$TopicDtoFromJson(Map<String, dynamic> json) => TopicDto(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  description: json['description'] as String? ?? '',
  bannerUrl: json['banner_url'] as String?,
  threadCount: (json['thread_count'] as num?)?.toInt() ?? 0,
);

TopicsResponseDto _$TopicsResponseDtoFromJson(Map<String, dynamic> json) =>
    TopicsResponseDto(
      topics:
          (json['topics'] as List<dynamic>?)
              ?.map((e) => TopicDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

DiscussionFullDto _$DiscussionFullDtoFromJson(Map<String, dynamic> json) =>
    DiscussionFullDto(
      id: (json['id'] as num).toInt(),
      uid: json['uid'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      author: json['author'] == null
          ? null
          : ChatterAuthorDto.fromJson(json['author'] as Map<String, dynamic>),
      topic: json['topic'] == null
          ? null
          : TopicDto.fromJson(json['topic'] as Map<String, dynamic>),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      upvoteCount: (json['upvote_count'] as num?)?.toInt() ?? 0,
      downvoteCount: (json['downvote_count'] as num?)?.toInt() ?? 0,
      opinionCount: (json['opinion_count'] as num?)?.toInt() ?? 0,
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      saveCount: (json['save_count'] as num?)?.toInt() ?? 0,
      isResolved: json['is_resolved'] as bool? ?? false,
      isLocked: json['is_locked'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      isEdited: json['is_edited'] as bool? ?? false,
      isMostRead: json['is_most_read'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
      isMine: json['is_mine'] as bool?,
      hasUpvoted: json['has_upvoted'] as bool?,
      hasDownvoted: json['has_downvoted'] as bool?,
      hasSaved: json['has_saved'] as bool?,
    );

DiscussionsPageDto _$DiscussionsPageDtoFromJson(Map<String, dynamic> json) =>
    DiscussionsPageDto(
      discussions:
          (json['discussions'] as List<dynamic>?)
              ?.map(
                (e) => DiscussionFullDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
    );

OpinionDto _$OpinionDtoFromJson(Map<String, dynamic> json) => OpinionDto(
  id: (json['id'] as num).toInt(),
  body: json['body'] as String? ?? '',
  author: json['author'] == null
      ? null
      : ChatterAuthorDto.fromJson(json['author'] as Map<String, dynamic>),
  upvoteCount: (json['upvote_count'] as num?)?.toInt() ?? 0,
  downvoteCount: (json['downvote_count'] as num?)?.toInt() ?? 0,
  netScore: (json['net_score'] as num?)?.toInt() ?? 0,
  replyCount: (json['reply_count'] as num?)?.toInt() ?? 0,
  isAcknowledged: json['is_acknowledged'] as bool? ?? false,
  isPinned: json['is_pinned'] as bool? ?? false,
  isEdited: json['is_edited'] as bool? ?? false,
  isHidden: json['is_hidden'] as bool? ?? false,
  createdAt: json['created_at'] as String?,
  parentId: (json['parent_id'] as num?)?.toInt(),
  isMine: json['is_mine'] as bool?,
  hasUpvoted: json['has_upvoted'] as bool?,
  hasDownvoted: json['has_downvoted'] as bool?,
);

OpinionsPageDto _$OpinionsPageDtoFromJson(Map<String, dynamic> json) =>
    OpinionsPageDto(
      opinions:
          (json['opinions'] as List<dynamic>?)
              ?.map((e) => OpinionDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
    );

VoteToggleDto _$VoteToggleDtoFromJson(Map<String, dynamic> json) =>
    VoteToggleDto(
      action: json['action'] as String? ?? '',
      voteType: json['vote_type'] as String?,
    );
