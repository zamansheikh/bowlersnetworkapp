import 'package:equatable/equatable.dart';

/// Slim author shape shared by every home-preview entity. Avoids pulling
/// in the full Newsfeed/Profile entities for what is, on the home screen,
/// just a small avatar + name.
class PreviewAuthor extends Equatable {
  const PreviewAuthor({
    required this.id,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
    this.badgeIconUrl,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? profilePictureUrl;
  final String? badgeIconUrl;

  String get displayName {
    final full = '$firstName $lastName'.trim();
    return full.isEmpty ? username : full;
  }

  @override
  List<Object?> get props =>
      [id, username, firstName, lastName, profilePictureUrl, badgeIconUrl];
}

class DiscussionPreview extends Equatable {
  const DiscussionPreview({
    required this.uid,
    required this.title,
    this.author,
    this.topic = '',
    this.upvoteCount = 0,
    this.opinionCount = 0,
    this.isResolved = false,
  });

  final String uid;
  final String title;
  final PreviewAuthor? author;
  final String topic;
  final int upvoteCount;
  final int opinionCount;
  final bool isResolved;

  @override
  List<Object?> get props =>
      [uid, title, author, topic, upvoteCount, opinionCount, isResolved];
}

/// One entry in the Trending Media grid. [kind] tells the UI whether to
/// route to `/media/videos/:uid` or `/media/splits/:uid`.
enum MediaKind { video, split }

class MediaPreview extends Equatable {
  const MediaPreview({
    required this.uid,
    required this.kind,
    this.title = '',
    this.thumbnailUrl,
    this.viewsCount = 0,
    this.author,
  });

  final String uid;
  final MediaKind kind;
  final String title;
  final String? thumbnailUrl;
  final int viewsCount;
  final PreviewAuthor? author;

  @override
  List<Object?> get props =>
      [uid, kind, title, thumbnailUrl, viewsCount, author];
}

class EventPreview extends Equatable {
  const EventPreview({
    required this.uid,
    required this.title,
    this.eventDate,
    this.eventTypeName = '',
    this.locationLabel = '',
    this.isOnline = false,
  });

  final String uid;
  final String title;
  final DateTime? eventDate;
  final String eventTypeName;
  final String locationLabel;
  final bool isOnline;

  @override
  List<Object?> get props =>
      [uid, title, eventDate, eventTypeName, locationLabel, isOnline];
}

class LiveBroadcastPreview extends Equatable {
  const LiveBroadcastPreview({
    required this.id,
    required this.uid,
    this.title = '',
    this.viewerCount = 0,
    this.interactionsCount = 0,
    this.user,
  });

  final int id;
  final String uid;
  final String title;
  final int viewerCount;
  final int interactionsCount;
  final PreviewAuthor? user;

  @override
  List<Object?> get props =>
      [id, uid, title, viewerCount, interactionsCount, user];
}
