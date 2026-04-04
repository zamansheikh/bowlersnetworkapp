import 'package:json_annotation/json_annotation.dart';

part 'post_models.g.dart';

@JsonSerializable(createToJson: false)
class PostModel {
  final int id;
  final String uid;
  @JsonKey(name: 'post_type')
  final String postType;
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
  final PostAuthorModel author;
  @JsonKey(name: 'likes_count', defaultValue: 0)
  final int likesCount;
  @JsonKey(name: 'comments_count', defaultValue: 0)
  final int commentsCount;
  @JsonKey(name: 'shares_count', defaultValue: 0)
  final int sharesCount;
  @JsonKey(name: 'saves_count', defaultValue: 0)
  final int savesCount;
  @JsonKey(name: 'type_data')
  final Map<String, dynamic>? typeData;
  @JsonKey(name: 'is_mine', defaultValue: false)
  final bool isMine;
  @JsonKey(name: 'has_reacted', defaultValue: false)
  final bool hasReacted;
  @JsonKey(name: 'reaction_type')
  final String? reactionType;
  @JsonKey(name: 'has_saved', defaultValue: false)
  final bool hasSaved;

  const PostModel({
    required this.id, required this.uid, required this.postType,
    required this.caption, required this.audience, required this.createdAt,
    required this.author, this.isEdited = false, this.isPinned = false,
    this.isCommentsEnabled = true, this.likesCount = 0, this.commentsCount = 0,
    this.sharesCount = 0, this.savesCount = 0, this.typeData,
    this.isMine = false, this.hasReacted = false, this.reactionType,
    this.hasSaved = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => _$PostModelFromJson(json);

  // Convenience getters for type_data
  List<String> get mediaUrls => (typeData?['media_urls'] as List?)?.cast<String>() ?? [];
  String? get videoUrl => typeData?['video_url'] as String?;
  String? get thumbnailUrl => typeData?['thumbnail_url'] as String?;
  int? get totalScore => typeData?['total_score'] as int?;
  String? get gameType => typeData?['game_type'] as String?;
  String? get templateStyle => typeData?['template_style'] as String?;
  double? get strikePercentage => (typeData?['strike_percentage'] as num?)?.toDouble();
  String? get pollQuestion => typeData?['question'] as String?;
  bool get isPollClosed => typeData?['is_closed'] as bool? ?? false;
  int get totalVotes => typeData?['total_votes'] as int? ?? 0;
  List<Map<String, dynamic>> get pollOptions =>
      (typeData?['options'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  PostModel? get sharedOriginal {
    final orig = typeData?['original'];
    if (orig is Map<String, dynamic>) return PostModel.fromJson(orig);
    return null;
  }
}

@JsonSerializable(createToJson: false)
class PostAuthorModel {
  final int id;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name', defaultValue: '')
  final String lastName;
  final String username;
  @JsonKey(name: 'profile_picture_url', defaultValue: '')
  final String profilePictureUrl;
  @JsonKey(name: 'is_pro', defaultValue: false)
  final bool isPro;

  const PostAuthorModel({
    required this.id, required this.firstName, this.lastName = '',
    required this.username, this.profilePictureUrl = '', this.isPro = false,
  });

  factory PostAuthorModel.fromJson(Map<String, dynamic> json) => _$PostAuthorModelFromJson(json);

  String get fullName => '$firstName $lastName'.trim();
}

@JsonSerializable(createToJson: false)
class CommentModel {
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
  @JsonKey(name: 'created_at')
  final String createdAt;
  final CommentAuthorModel author;
  @JsonKey(name: 'reply_count', defaultValue: 0)
  final int replyCount;
  @JsonKey(name: 'is_mine', defaultValue: false)
  final bool isMine;
  @JsonKey(name: 'has_liked', defaultValue: false)
  final bool hasLiked;

  const CommentModel({
    required this.id, required this.text, this.mediaUrl, this.isHidden = false,
    this.isPinned = false, this.isEdited = false, this.likesCount = 0,
    required this.createdAt, required this.author, this.replyCount = 0,
    this.isMine = false, this.hasLiked = false,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => _$CommentModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class CommentAuthorModel {
  final int id;
  @JsonKey(name: 'first_name')
  final String firstName;
  final String username;

  const CommentAuthorModel({required this.id, required this.firstName, required this.username});

  factory CommentAuthorModel.fromJson(Map<String, dynamic> json) => _$CommentAuthorModelFromJson(json);
}
