import 'package:json_annotation/json_annotation.dart';

part 'post_dto.g.dart';

/// GET /api/newsfeed/feed → `{"posts": [...]}`.
///
/// Cursor pagination: the next call passes the lowest post `id` from the
/// current page as `cursor`. Backend does not return a discrete `next_cursor`
/// field; we track it client-side.
@JsonSerializable(createToJson: false)
class FeedResponseDto {
  const FeedResponseDto({required this.posts});

  final List<PostDto> posts;

  factory FeedResponseDto.fromJson(Map<String, dynamic> json) =>
      _$FeedResponseDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class PostDto {
  const PostDto({
    required this.id,
    required this.uid,
    required this.postType,
    required this.author,
    required this.createdAt,
    this.caption = '',
    this.audience = 'public',
    this.isEdited = false,
    this.isPinned = false,
    this.isCommentsEnabled = true,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.savesCount = 0,
    this.isMine = false,
    this.hasReacted = false,
    this.reactionType,
    this.hasSaved = false,
    this.typeData,
  });

  final int id;
  final String uid;

  @JsonKey(name: 'post_type')
  final String postType;

  final PostAuthorDto author;

  final String caption;
  final String audience;

  @JsonKey(name: 'is_edited', defaultValue: false)
  final bool isEdited;
  @JsonKey(name: 'is_pinned', defaultValue: false)
  final bool isPinned;
  @JsonKey(name: 'is_comments_enabled', defaultValue: true)
  final bool isCommentsEnabled;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'likes_count', defaultValue: 0)
  final int likesCount;
  @JsonKey(name: 'comments_count', defaultValue: 0)
  final int commentsCount;
  @JsonKey(name: 'shares_count', defaultValue: 0)
  final int sharesCount;
  @JsonKey(name: 'saves_count', defaultValue: 0)
  final int savesCount;

  @JsonKey(name: 'is_mine', defaultValue: false)
  final bool isMine;

  @JsonKey(name: 'has_reacted', defaultValue: false)
  final bool hasReacted;

  @JsonKey(name: 'reaction_type')
  final String? reactionType;

  @JsonKey(name: 'has_saved', defaultValue: false)
  final bool hasSaved;

  /// Free-form per-post-type payload. For a photo: `{media_urls: [...]}`.
  /// For a video: `{video_url, thumbnail_url}`. For a score: `{total_score,
  /// game_type, ...}`. For a poll: `{question, options: [...]}`.
  @JsonKey(name: 'type_data')
  final Map<String, dynamic>? typeData;

  factory PostDto.fromJson(Map<String, dynamic> json) =>
      _$PostDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class PostAuthorDto {
  const PostAuthorDto({
    required this.id,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
    this.isPro = false,
    this.level,
    this.rank,
    this.isFollowing = false,
  });

  final int id;
  @JsonKey(name: 'first_name', defaultValue: '')
  final String firstName;
  @JsonKey(name: 'last_name', defaultValue: '')
  final String lastName;
  final String username;
  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;
  @JsonKey(name: 'is_pro', defaultValue: false)
  final bool isPro;
  final int? level;
  final String? rank;
  @JsonKey(name: 'is_following', defaultValue: false)
  final bool isFollowing;

  factory PostAuthorDto.fromJson(Map<String, dynamic> json) =>
      _$PostAuthorDtoFromJson(json);
}

/// POST /api/newsfeed/{id}/react → `{action, reaction_type}`.
@JsonSerializable(createToJson: false)
class ReactionResponseDto {
  const ReactionResponseDto({required this.action, this.reactionType});

  /// `added | removed | changed`.
  final String action;

  @JsonKey(name: 'reaction_type')
  final String? reactionType;

  factory ReactionResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ReactionResponseDtoFromJson(json);
}

/// POST /api/newsfeed/{id}/react body.
@JsonSerializable(createFactory: false)
class ReactionRequestDto {
  const ReactionRequestDto({required this.reactionType});

  @JsonKey(name: 'reaction_type')
  final String reactionType;

  Map<String, dynamic> toJson() => _$ReactionRequestDtoToJson(this);
}

/// POST /api/newsfeed/{id}/save → `{saved: bool}`.
@JsonSerializable(createToJson: false)
class SaveResponseDto {
  const SaveResponseDto({required this.saved});
  final bool saved;

  factory SaveResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SaveResponseDtoFromJson(json);
}

/// POST /api/newsfeed/{id}/pin → `{is_pinned: bool}`.
@JsonSerializable(createToJson: false)
class PinResponseDto {
  const PinResponseDto({this.isPinned = false});

  @JsonKey(name: 'is_pinned', defaultValue: false)
  final bool isPinned;

  factory PinResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PinResponseDtoFromJson(json);
}

/// PATCH /api/newsfeed/{id}/comments-toggle → `{is_comments_enabled: bool}`.
@JsonSerializable(createToJson: false)
class CommentsToggleResponseDto {
  const CommentsToggleResponseDto({this.isCommentsEnabled = true});

  @JsonKey(name: 'is_comments_enabled', defaultValue: true)
  final bool isCommentsEnabled;

  factory CommentsToggleResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CommentsToggleResponseDtoFromJson(json);
}
