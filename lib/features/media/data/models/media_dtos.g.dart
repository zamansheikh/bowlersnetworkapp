// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaAuthorDto _$MediaAuthorDtoFromJson(Map<String, dynamic> json) =>
    MediaAuthorDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      profilePictureUrl: json['profile_picture_url'] as String?,
      isPro: json['is_pro'] as bool? ?? false,
    );

VideoDto _$VideoDtoFromJson(Map<String, dynamic> json) => VideoDto(
  id: (json['id'] as num).toInt(),
  uid: json['uid'] as String,
  title: json['title'] as String? ?? '',
  description: json['description'] as String? ?? '',
  videoUrl: json['video_url'] as String?,
  thumbnailUrl: json['thumbnail_url'] as String?,
  durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
  durationDisplay: json['duration_display'] as String?,
  audience: json['audience'] as String? ?? 'public',
  isPinned: json['is_pinned'] as bool? ?? false,
  isCommentsEnabled: json['is_comments_enabled'] as bool? ?? true,
  createdAt: json['created_at'] as String?,
  author: json['author'] == null
      ? null
      : MediaAuthorDto.fromJson(json['author'] as Map<String, dynamic>),
  likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
  commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
  savesCount: (json['saves_count'] as num?)?.toInt() ?? 0,
  viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
  isMine: json['is_mine'] as bool?,
  hasLiked: json['has_liked'] as bool?,
  hasSaved: json['has_saved'] as bool?,
);

SplitDto _$SplitDtoFromJson(Map<String, dynamic> json) => SplitDto(
  id: (json['id'] as num).toInt(),
  uid: json['uid'] as String,
  caption: json['caption'] as String? ?? '',
  videoUrl: json['video_url'] as String?,
  thumbnailUrl: json['thumbnail_url'] as String?,
  durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
  durationDisplay: json['duration_display'] as String?,
  audioLabel: json['audio_label'] as String?,
  audience: json['audience'] as String? ?? 'public',
  isPinned: json['is_pinned'] as bool? ?? false,
  isCommentsEnabled: json['is_comments_enabled'] as bool? ?? true,
  createdAt: json['created_at'] as String?,
  author: json['author'] == null
      ? null
      : MediaAuthorDto.fromJson(json['author'] as Map<String, dynamic>),
  likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
  commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
  savesCount: (json['saves_count'] as num?)?.toInt() ?? 0,
  viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
  isMine: json['is_mine'] as bool?,
  hasLiked: json['has_liked'] as bool?,
  hasSaved: json['has_saved'] as bool?,
);
