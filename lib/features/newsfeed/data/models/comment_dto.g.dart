// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentsPageDto _$CommentsPageDtoFromJson(Map<String, dynamic> json) =>
    CommentsPageDto(
      comments: (json['comments'] as List<dynamic>)
          .map((e) => CommentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
    );

CommentDto _$CommentDtoFromJson(Map<String, dynamic> json) => CommentDto(
  id: (json['id'] as num).toInt(),
  text: json['text'] as String,
  author: CommentAuthorDto.fromJson(json['author'] as Map<String, dynamic>),
  mediaUrl: json['media_url'] as String?,
  isHidden: json['is_hidden'] as bool? ?? false,
  isPinned: json['is_pinned'] as bool? ?? false,
  isEdited: json['is_edited'] as bool? ?? false,
  likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
  replyCount: (json['reply_count'] as num?)?.toInt() ?? 0,
  isMine: json['is_mine'] as bool? ?? false,
  hasLiked: json['has_liked'] as bool? ?? false,
  isPostAuthor: json['is_post_author'] as bool? ?? false,
  createdAt: json['created_at'] as String?,
);

CommentAuthorDto _$CommentAuthorDtoFromJson(Map<String, dynamic> json) =>
    CommentAuthorDto(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      profilePictureUrl: json['profile_picture_url'] as String?,
      level: (json['level'] as num?)?.toInt(),
      rankDisplay: json['rank_display'] as String?,
      badgeIconUrl: json['badge_icon_url'] as String?,
    );

RepliesPageDto _$RepliesPageDtoFromJson(Map<String, dynamic> json) =>
    RepliesPageDto(
      replies: (json['replies'] as List<dynamic>)
          .map((e) => CommentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
    );

FlagToggleResponseDto _$FlagToggleResponseDtoFromJson(
  Map<String, dynamic> json,
) => FlagToggleResponseDto(
  liked: json['liked'] as bool?,
  isPinned: json['is_pinned'] as bool?,
  isHidden: json['is_hidden'] as bool?,
);
