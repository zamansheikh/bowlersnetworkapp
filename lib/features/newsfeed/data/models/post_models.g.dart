// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModel _$PostModelFromJson(Map<String, dynamic> json) => PostModel(
  id: (json['id'] as num).toInt(),
  uid: json['uid'] as String,
  postType: json['post_type'] as String,
  caption: json['caption'] as String,
  audience: json['audience'] as String,
  createdAt: json['created_at'] as String,
  author: PostAuthorModel.fromJson(json['author'] as Map<String, dynamic>),
  isEdited: json['is_edited'] as bool? ?? false,
  isPinned: json['is_pinned'] as bool? ?? false,
  isCommentsEnabled: json['is_comments_enabled'] as bool? ?? true,
  likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
  commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
  sharesCount: (json['shares_count'] as num?)?.toInt() ?? 0,
  savesCount: (json['saves_count'] as num?)?.toInt() ?? 0,
  typeData: json['type_data'] as Map<String, dynamic>?,
  isMine: json['is_mine'] as bool? ?? false,
  hasReacted: json['has_reacted'] as bool? ?? false,
  reactionType: json['reaction_type'] as String?,
  hasSaved: json['has_saved'] as bool? ?? false,
);

PostAuthorModel _$PostAuthorModelFromJson(Map<String, dynamic> json) =>
    PostAuthorModel(
      id: (json['id'] as num).toInt(),
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String? ?? '',
      username: json['username'] as String,
      profilePictureUrl: json['profile_picture_url'] as String? ?? '',
      isPro: json['is_pro'] as bool? ?? false,
    );

CommentModel _$CommentModelFromJson(Map<String, dynamic> json) => CommentModel(
  id: (json['id'] as num).toInt(),
  text: json['text'] as String,
  mediaUrl: json['media_url'] as String?,
  isHidden: json['is_hidden'] as bool? ?? false,
  isPinned: json['is_pinned'] as bool? ?? false,
  isEdited: json['is_edited'] as bool? ?? false,
  likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
  createdAt: json['created_at'] as String,
  author: CommentAuthorModel.fromJson(json['author'] as Map<String, dynamic>),
  replyCount: (json['reply_count'] as num?)?.toInt() ?? 0,
  isMine: json['is_mine'] as bool? ?? false,
  hasLiked: json['has_liked'] as bool? ?? false,
);

CommentAuthorModel _$CommentAuthorModelFromJson(Map<String, dynamic> json) =>
    CommentAuthorModel(
      id: (json['id'] as num).toInt(),
      firstName: json['first_name'] as String,
      username: json['username'] as String,
    );
