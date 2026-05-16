import 'package:equatable/equatable.dart';

class MediaAuthor extends Equatable {
  const MediaAuthor({
    required this.id,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
    this.isPro = false,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? profilePictureUrl;
  final bool isPro;

  String get displayName {
    final full = '$firstName $lastName'.trim();
    return full.isEmpty ? username : full;
  }

  @override
  List<Object?> get props =>
      [id, username, firstName, lastName, profilePictureUrl, isPro];
}

/// Unified shape for both videos and splits — videos use `title`, splits
/// use `caption`, but the tab UI renders the same card so we normalize.
class MediaItem extends Equatable {
  const MediaItem({
    required this.id,
    required this.uid,
    required this.kind,
    required this.title,
    this.videoUrl,
    this.thumbnailUrl,
    this.durationSeconds,
    this.durationDisplay,
    this.author,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.viewsCount = 0,
    this.savesCount = 0,
    this.isPinned = false,
    this.createdAt,
    this.hasLiked,
    this.hasSaved,
    this.isMine,
  });

  final int id;
  final String uid;
  final MediaKind kind;

  /// Video title or split caption — whichever the source had.
  final String title;

  final String? videoUrl;
  final String? thumbnailUrl;
  final int? durationSeconds;
  final String? durationDisplay;
  final MediaAuthor? author;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final int savesCount;
  final bool isPinned;
  final DateTime? createdAt;
  final bool? hasLiked;
  final bool? hasSaved;
  final bool? isMine;

  @override
  List<Object?> get props => [
        id,
        uid,
        kind,
        title,
        videoUrl,
        thumbnailUrl,
        durationSeconds,
        durationDisplay,
        author,
        likesCount,
        commentsCount,
        viewsCount,
        savesCount,
        isPinned,
        createdAt,
        hasLiked,
        hasSaved,
        isMine,
      ];
}

enum MediaKind { video, split }
