import 'package:equatable/equatable.dart';

/// Reaction enum aligned with the backend's newsfeed reactions. Mirrors the
/// web frontend's 6 reactions — emoji + colored text variant.
enum ReactionType {
  like('like', '❤️', 'Like', 0xFFEF4444),
  fire('fire', '🔥', 'Fire', 0xFFF97316),
  strike('strike', '🎳', 'Strike', 0xFFEAB308),
  clap('clap', '👏', 'Clap', 0xFF3B82F6),
  wow('wow', '😮', 'Wow', 0xFFA855F7),
  haha('haha', '😂', 'Haha', 0xFF22C55E);

  const ReactionType(this.apiValue, this.emoji, this.label, this.colorValue);
  final String apiValue;
  final String emoji;
  final String label;
  final int colorValue;

  static ReactionType? fromString(String? s) {
    if (s == null) return null;
    for (final r in ReactionType.values) {
      if (r.apiValue == s) return r;
    }
    return null;
  }
}

enum PostType {
  text,
  photo,
  video,
  score,
  poll,
  share,
  unknown;

  static PostType fromString(String s) {
    switch (s) {
      case 'text':
        return PostType.text;
      case 'photo':
        return PostType.photo;
      case 'video':
        return PostType.video;
      case 'score':
        return PostType.score;
      case 'poll':
        return PostType.poll;
      case 'share':
        return PostType.share;
      default:
        return PostType.unknown;
    }
  }
}

class PostAuthor extends Equatable {
  const PostAuthor({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.profilePictureUrl,
    this.isPro = false,
    this.level,
    this.rank,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? profilePictureUrl;
  final bool isPro;
  final int? level;
  final String? rank;

  String get displayName => '$firstName $lastName'.trim().isEmpty
      ? username
      : '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
        id,
        username,
        firstName,
        lastName,
        profilePictureUrl,
        isPro,
        level,
        rank,
      ];
}

/// A single post in the newsfeed. Intentionally immutable so BLoC can swap
/// one post in a list via [copyWith] to reflect reaction / save changes
/// without refetching the whole page.
class Post extends Equatable {
  const Post({
    required this.id,
    required this.uid,
    required this.type,
    required this.author,
    required this.createdAt,
    required this.caption,
    required this.audience,
    required this.isEdited,
    required this.isPinned,
    required this.isCommentsEnabled,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.savesCount,
    required this.isMine,
    required this.hasReacted,
    required this.hasSaved,
    this.reaction,
    this.typeData,
  });

  final int id;
  final String uid;
  final PostType type;
  final PostAuthor author;
  final DateTime createdAt;
  final String caption;
  final String audience;
  final bool isEdited;
  final bool isPinned;
  final bool isCommentsEnabled;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int savesCount;
  final bool isMine;
  final bool hasReacted;
  final bool hasSaved;
  final ReactionType? reaction;

  /// Type-specific payload straight from the backend response.
  final Map<String, dynamic>? typeData;

  // Convenience accessors for common type_data fields.
  List<String> get mediaUrls {
    final raw = typeData?['media_urls'];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return const [];
  }

  String? get videoUrl => typeData?['video_url'] as String?;
  String? get videoThumbnailUrl => typeData?['thumbnail_url'] as String?;

  Post copyWith({
    int? likesCount,
    int? commentsCount,
    int? savesCount,
    bool? hasReacted,
    bool? hasSaved,
    ReactionType? reaction,
    bool clearReaction = false,
  }) {
    return Post(
      id: id,
      uid: uid,
      type: type,
      author: author,
      createdAt: createdAt,
      caption: caption,
      audience: audience,
      isEdited: isEdited,
      isPinned: isPinned,
      isCommentsEnabled: isCommentsEnabled,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount,
      savesCount: savesCount ?? this.savesCount,
      isMine: isMine,
      hasReacted: hasReacted ?? this.hasReacted,
      hasSaved: hasSaved ?? this.hasSaved,
      reaction: clearReaction ? null : (reaction ?? this.reaction),
      typeData: typeData,
    );
  }

  @override
  List<Object?> get props => [
        id,
        uid,
        type,
        author,
        createdAt,
        caption,
        likesCount,
        commentsCount,
        savesCount,
        hasReacted,
        hasSaved,
        reaction,
      ];
}

/// A page of posts + the cursor to fetch the next page.
class FeedPage extends Equatable {
  const FeedPage({required this.posts, required this.nextCursor});

  final List<Post> posts;

  /// Pass this as `?cursor=` on the next fetch. Null means no more pages.
  final int? nextCursor;

  @override
  List<Object?> get props => [posts, nextCursor];
}
