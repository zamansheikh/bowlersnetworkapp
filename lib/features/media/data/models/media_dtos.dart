import 'package:json_annotation/json_annotation.dart';

part 'media_dtos.g.dart';

/// Shared slim author for both videos and splits.
@JsonSerializable(createToJson: false)
class MediaAuthorDto {
  const MediaAuthorDto({
    this.id = 0,
    this.username = '',
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
    this.isPro = false,
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

  factory MediaAuthorDto.fromJson(Map<String, dynamic> json) =>
      _$MediaAuthorDtoFromJson(json);
}

/// One video item under `/api/media/channels/{username}/videos`. The
/// endpoint wraps the array in `{videos: [...], page, page_size}` —
/// see [VideosPageDto].
@JsonSerializable(createToJson: false)
class VideoDto {
  const VideoDto({
    required this.id,
    required this.uid,
    this.title = '',
    this.description = '',
    this.videoUrl,
    this.thumbnailUrl,
    this.durationSeconds,
    this.durationDisplay,
    this.audience = 'public',
    this.isPinned = false,
    this.isCommentsEnabled = true,
    this.createdAt,
    this.author,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.savesCount = 0,
    this.viewsCount = 0,
    this.isMine,
    this.hasLiked,
    this.hasSaved,
  });

  final int id;
  final String uid;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(defaultValue: '')
  final String description;
  @JsonKey(name: 'video_url')
  final String? videoUrl;
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @JsonKey(name: 'duration_seconds')
  final int? durationSeconds;
  @JsonKey(name: 'duration_display')
  final String? durationDisplay;
  @JsonKey(defaultValue: 'public')
  final String audience;
  @JsonKey(name: 'is_pinned', defaultValue: false)
  final bool isPinned;
  @JsonKey(name: 'is_comments_enabled', defaultValue: true)
  final bool isCommentsEnabled;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final MediaAuthorDto? author;
  @JsonKey(name: 'likes_count', defaultValue: 0)
  final int likesCount;
  @JsonKey(name: 'comments_count', defaultValue: 0)
  final int commentsCount;
  @JsonKey(name: 'saves_count', defaultValue: 0)
  final int savesCount;
  @JsonKey(name: 'views_count', defaultValue: 0)
  final int viewsCount;
  @JsonKey(name: 'is_mine')
  final bool? isMine;
  @JsonKey(name: 'has_liked')
  final bool? hasLiked;
  @JsonKey(name: 'has_saved')
  final bool? hasSaved;

  factory VideoDto.fromJson(Map<String, dynamic> json) =>
      _$VideoDtoFromJson(json);
}

/// One split (short-form) item — same wire shape as a video except for
/// `caption` (instead of `title`) and an optional `audio_label`.
@JsonSerializable(createToJson: false)
class SplitDto {
  const SplitDto({
    required this.id,
    required this.uid,
    this.caption = '',
    this.videoUrl,
    this.thumbnailUrl,
    this.durationSeconds,
    this.durationDisplay,
    this.audioLabel,
    this.audience = 'public',
    this.isPinned = false,
    this.isCommentsEnabled = true,
    this.createdAt,
    this.author,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.savesCount = 0,
    this.viewsCount = 0,
    this.isMine,
    this.hasLiked,
    this.hasSaved,
  });

  final int id;
  final String uid;
  @JsonKey(defaultValue: '')
  final String caption;
  @JsonKey(name: 'video_url')
  final String? videoUrl;
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @JsonKey(name: 'duration_seconds')
  final int? durationSeconds;
  @JsonKey(name: 'duration_display')
  final String? durationDisplay;
  @JsonKey(name: 'audio_label')
  final String? audioLabel;
  @JsonKey(defaultValue: 'public')
  final String audience;
  @JsonKey(name: 'is_pinned', defaultValue: false)
  final bool isPinned;
  @JsonKey(name: 'is_comments_enabled', defaultValue: true)
  final bool isCommentsEnabled;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final MediaAuthorDto? author;
  @JsonKey(name: 'likes_count', defaultValue: 0)
  final int likesCount;
  @JsonKey(name: 'comments_count', defaultValue: 0)
  final int commentsCount;
  @JsonKey(name: 'saves_count', defaultValue: 0)
  final int savesCount;
  @JsonKey(name: 'views_count', defaultValue: 0)
  final int viewsCount;
  @JsonKey(name: 'is_mine')
  final bool? isMine;
  @JsonKey(name: 'has_liked')
  final bool? hasLiked;
  @JsonKey(name: 'has_saved')
  final bool? hasSaved;

  factory SplitDto.fromJson(Map<String, dynamic> json) =>
      _$SplitDtoFromJson(json);
}

/// Page envelope returned by `/api/media/channels/{username}/videos`.
@JsonSerializable(createToJson: false)
class VideosPageDto {
  const VideosPageDto({
    this.videos = const [],
    this.page = 1,
    this.pageSize = 20,
  });

  final List<VideoDto> videos;
  @JsonKey(defaultValue: 1)
  final int page;
  @JsonKey(name: 'page_size', defaultValue: 20)
  final int pageSize;

  factory VideosPageDto.fromJson(Map<String, dynamic> json) =>
      _$VideosPageDtoFromJson(json);
}

/// Page envelope returned by `/api/media/channels/{username}/splits`.
@JsonSerializable(createToJson: false)
class SplitsPageDto {
  const SplitsPageDto({
    this.splits = const [],
    this.page = 1,
    this.pageSize = 20,
  });

  final List<SplitDto> splits;
  @JsonKey(defaultValue: 1)
  final int page;
  @JsonKey(name: 'page_size', defaultValue: 20)
  final int pageSize;

  factory SplitsPageDto.fromJson(Map<String, dynamic> json) =>
      _$SplitsPageDtoFromJson(json);
}
