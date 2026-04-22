import 'package:json_annotation/json_annotation.dart';

part 'comment_dto.g.dart';

/// GET /api/newsfeed/{post_uid}/comments → `{comments: [...], page, page_size}`.
@JsonSerializable(createToJson: false)
class CommentsPageDto {
  const CommentsPageDto({
    required this.comments,
    this.page = 1,
    this.pageSize = 20,
  });

  final List<CommentDto> comments;
  @JsonKey(defaultValue: 1)
  final int page;
  @JsonKey(name: 'page_size', defaultValue: 20)
  final int pageSize;

  factory CommentsPageDto.fromJson(Map<String, dynamic> json) =>
      _$CommentsPageDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class CommentDto {
  const CommentDto({
    required this.id,
    required this.text,
    required this.author,
    this.mediaUrl,
    this.isHidden = false,
    this.isPinned = false,
    this.isEdited = false,
    this.likesCount = 0,
    this.replyCount = 0,
    this.isMine = false,
    this.hasLiked = false,
    this.isPostAuthor = false,
    this.createdAt,
  });

  final int id;
  final String text;
  @JsonKey(name: 'media_url')
  final String? mediaUrl;
  @JsonKey(name: 'is_hidden', defaultValue: false)
  final bool isHidden;
  @JsonKey(name: 'is_pinned', defaultValue: false)
  final bool isPinned;
  @JsonKey(name: 'is_edited', defaultValue: false)
  final bool isEdited;
  @JsonKey(name: 'likes_count', defaultValue: 0)
  final int likesCount;
  @JsonKey(name: 'reply_count', defaultValue: 0)
  final int replyCount;
  @JsonKey(name: 'is_mine', defaultValue: false)
  final bool isMine;
  @JsonKey(name: 'has_liked', defaultValue: false)
  final bool hasLiked;
  @JsonKey(name: 'is_post_author', defaultValue: false)
  final bool isPostAuthor;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  final CommentAuthorDto author;

  factory CommentDto.fromJson(Map<String, dynamic> json) =>
      _$CommentDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class CommentAuthorDto {
  const CommentAuthorDto({
    required this.id,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
    this.level,
    this.rankDisplay,
    this.badgeIconUrl,
  });

  final int id;
  final String username;
  @JsonKey(name: 'first_name', defaultValue: '')
  final String firstName;
  @JsonKey(name: 'last_name', defaultValue: '')
  final String lastName;
  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;
  final int? level;
  @JsonKey(name: 'rank_display')
  final String? rankDisplay;
  @JsonKey(name: 'badge_icon_url')
  final String? badgeIconUrl;

  factory CommentAuthorDto.fromJson(Map<String, dynamic> json) =>
      _$CommentAuthorDtoFromJson(json);
}

/// Replies pagination: `{replies: [...], page, page_size}`.
@JsonSerializable(createToJson: false)
class RepliesPageDto {
  const RepliesPageDto({required this.replies, this.page = 1, this.pageSize = 20});

  final List<CommentDto> replies;
  @JsonKey(defaultValue: 1)
  final int page;
  @JsonKey(name: 'page_size', defaultValue: 20)
  final int pageSize;

  factory RepliesPageDto.fromJson(Map<String, dynamic> json) =>
      _$RepliesPageDtoFromJson(json);
}

/// Shared `{like: bool}` / `{is_pinned: bool}` / `{is_hidden: bool}` response.
@JsonSerializable(createToJson: false)
class FlagToggleResponseDto {
  const FlagToggleResponseDto({this.liked, this.isPinned, this.isHidden});

  final bool? liked;
  @JsonKey(name: 'is_pinned')
  final bool? isPinned;
  @JsonKey(name: 'is_hidden')
  final bool? isHidden;

  factory FlagToggleResponseDto.fromJson(Map<String, dynamic> json) =>
      _$FlagToggleResponseDtoFromJson(json);
}
