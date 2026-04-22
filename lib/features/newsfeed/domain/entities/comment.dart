import 'package:equatable/equatable.dart';

class CommentAuthor extends Equatable {
  const CommentAuthor({
    required this.id,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
    this.level,
    this.rankDisplay,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? profilePictureUrl;
  final int? level;
  final String? rankDisplay;

  String get displayName =>
      '$firstName $lastName'.trim().isEmpty ? username : '$firstName $lastName'.trim();

  @override
  List<Object?> get props =>
      [id, username, firstName, lastName, profilePictureUrl, level, rankDisplay];
}

class Comment extends Equatable {
  const Comment({
    required this.id,
    required this.text,
    required this.author,
    required this.createdAt,
    this.mediaUrl,
    this.isHidden = false,
    this.isPinned = false,
    this.isEdited = false,
    this.likesCount = 0,
    this.replyCount = 0,
    this.isMine = false,
    this.hasLiked = false,
    this.isPostAuthor = false,
    this.replies = const [],
    this.repliesExpanded = false,
    this.loadingReplies = false,
  });

  final int id;
  final String text;
  final String? mediaUrl;
  final bool isHidden;
  final bool isPinned;
  final bool isEdited;
  final int likesCount;
  final int replyCount;
  final bool isMine;
  final bool hasLiked;
  final bool isPostAuthor;
  final DateTime createdAt;

  final CommentAuthor author;

  /// Client-side: loaded reply list (nested one level).
  final List<Comment> replies;
  final bool repliesExpanded;
  final bool loadingReplies;

  Comment copyWith({
    String? text,
    bool? isPinned,
    bool? isHidden,
    bool? hasLiked,
    int? likesCount,
    int? replyCount,
    bool? isEdited,
    List<Comment>? replies,
    bool? repliesExpanded,
    bool? loadingReplies,
  }) {
    return Comment(
      id: id,
      text: text ?? this.text,
      author: author,
      createdAt: createdAt,
      mediaUrl: mediaUrl,
      isHidden: isHidden ?? this.isHidden,
      isPinned: isPinned ?? this.isPinned,
      isEdited: isEdited ?? this.isEdited,
      likesCount: likesCount ?? this.likesCount,
      replyCount: replyCount ?? this.replyCount,
      isMine: isMine,
      hasLiked: hasLiked ?? this.hasLiked,
      isPostAuthor: isPostAuthor,
      replies: replies ?? this.replies,
      repliesExpanded: repliesExpanded ?? this.repliesExpanded,
      loadingReplies: loadingReplies ?? this.loadingReplies,
    );
  }

  @override
  List<Object?> get props => [
        id,
        text,
        isHidden,
        isPinned,
        isEdited,
        likesCount,
        replyCount,
        hasLiked,
        replies,
        repliesExpanded,
        loadingReplies,
      ];
}
