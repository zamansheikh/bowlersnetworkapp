// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedResponseDto _$FeedResponseDtoFromJson(Map<String, dynamic> json) =>
    FeedResponseDto(
      posts: (json['posts'] as List<dynamic>)
          .map((e) => PostDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

PostDto _$PostDtoFromJson(Map<String, dynamic> json) => PostDto(
  id: (json['id'] as num).toInt(),
  uid: json['uid'] as String,
  postType: json['post_type'] as String,
  author: PostAuthorDto.fromJson(json['author'] as Map<String, dynamic>),
  createdAt: json['created_at'] as String,
  caption: json['caption'] as String? ?? '',
  audience: json['audience'] as String? ?? 'public',
  isEdited: json['is_edited'] as bool? ?? false,
  isPinned: json['is_pinned'] as bool? ?? false,
  isCommentsEnabled: json['is_comments_enabled'] as bool? ?? true,
  likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
  commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
  sharesCount: (json['shares_count'] as num?)?.toInt() ?? 0,
  savesCount: (json['saves_count'] as num?)?.toInt() ?? 0,
  isMine: json['is_mine'] as bool? ?? false,
  hasReacted: json['has_reacted'] as bool? ?? false,
  reactionType: json['reaction_type'] as String?,
  hasSaved: json['has_saved'] as bool? ?? false,
  typeData: json['type_data'] as Map<String, dynamic>?,
);

PostAuthorDto _$PostAuthorDtoFromJson(Map<String, dynamic> json) =>
    PostAuthorDto(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      profilePictureUrl: json['profile_picture_url'] as String?,
      isPro: json['is_pro'] as bool? ?? false,
      level: (json['level'] as num?)?.toInt(),
      rank: json['rank'] as String?,
    );

ReactionResponseDto _$ReactionResponseDtoFromJson(Map<String, dynamic> json) =>
    ReactionResponseDto(
      action: json['action'] as String,
      reactionType: json['reaction_type'] as String?,
    );

Map<String, dynamic> _$ReactionRequestDtoToJson(ReactionRequestDto instance) =>
    <String, dynamic>{'reaction_type': instance.reactionType};

SaveResponseDto _$SaveResponseDtoFromJson(Map<String, dynamic> json) =>
    SaveResponseDto(saved: json['saved'] as bool);

PinResponseDto _$PinResponseDtoFromJson(Map<String, dynamic> json) =>
    PinResponseDto(isPinned: json['is_pinned'] as bool? ?? false);

CommentsToggleResponseDto _$CommentsToggleResponseDtoFromJson(
  Map<String, dynamic> json,
) => CommentsToggleResponseDto(
  isCommentsEnabled: json['is_comments_enabled'] as bool? ?? true,
);
