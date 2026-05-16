import 'package:equatable/equatable.dart';

/// Sealed hierarchy of search result rows. Each variant carries only the
/// fields its tile renders + the keys needed to navigate. Order in
/// [SearchResults] mirrors the visual section order on screen.
sealed class SearchResult extends Equatable {
  const SearchResult();
}

class UserSearchResult extends SearchResult {
  const UserSearchResult({
    required this.id,
    required this.username,
    required this.fullName,
    this.profilePictureUrl,
    this.isPro = false,
  });

  final int id;
  final String username;
  final String fullName;
  final String? profilePictureUrl;
  final bool isPro;

  @override
  List<Object?> get props => [id, username, fullName, profilePictureUrl, isPro];
}

class PostSearchResult extends SearchResult {
  const PostSearchResult({
    required this.uid,
    required this.caption,
    required this.authorName,
    this.authorProfilePictureUrl,
    this.likesCount = 0,
  });

  final String uid;
  final String caption;
  final String authorName;
  final String? authorProfilePictureUrl;
  final int likesCount;

  @override
  List<Object?> get props =>
      [uid, caption, authorName, authorProfilePictureUrl, likesCount];
}

class DiscussionSearchResult extends SearchResult {
  const DiscussionSearchResult({
    required this.uid,
    required this.title,
    required this.topicName,
    required this.authorName,
    this.upvoteCount = 0,
    this.opinionCount = 0,
    this.isResolved = false,
  });

  final String uid;
  final String title;
  final String topicName;
  final String authorName;
  final int upvoteCount;
  final int opinionCount;
  final bool isResolved;

  @override
  List<Object?> get props => [
        uid,
        title,
        topicName,
        authorName,
        upvoteCount,
        opinionCount,
        isResolved,
      ];
}

class CenterSearchResult extends SearchResult {
  const CenterSearchResult({
    required this.id,
    required this.name,
    required this.address,
    this.logo,
  });

  final int id;
  final String name;
  final String address;
  final String? logo;

  @override
  List<Object?> get props => [id, name, address, logo];
}

class BrandSearchResult extends SearchResult {
  const BrandSearchResult({
    required this.id,
    required this.name,
    required this.brandType,
    this.formalName = '',
    this.logoUrl,
  });

  final int id;
  final String name;
  final String brandType;
  final String formalName;
  final String? logoUrl;

  @override
  List<Object?> get props => [id, name, brandType, formalName, logoUrl];
}

class EventSearchResult extends SearchResult {
  const EventSearchResult({
    required this.uid,
    required this.title,
    required this.eventTypeName,
    this.eventDate,
    this.address = '',
    this.isOnline = false,
  });

  final String uid;
  final String title;
  final String eventTypeName;
  final DateTime? eventDate;
  final String address;
  final bool isOnline;

  @override
  List<Object?> get props =>
      [uid, title, eventTypeName, eventDate, address, isOnline];
}

class VideoSearchResult extends SearchResult {
  const VideoSearchResult({
    required this.uid,
    required this.title,
    this.thumbnailUrl,
    this.authorName,
    this.durationSeconds,
    this.viewsCount,
  });

  final String uid;
  final String title;
  final String? thumbnailUrl;
  final String? authorName;
  final int? durationSeconds;
  final int? viewsCount;

  @override
  List<Object?> get props =>
      [uid, title, thumbnailUrl, authorName, durationSeconds, viewsCount];
}

class SplitSearchResult extends SearchResult {
  const SplitSearchResult({
    required this.uid,
    required this.caption,
    this.thumbnailUrl,
    this.authorName,
  });

  final String uid;
  final String caption;
  final String? thumbnailUrl;
  final String? authorName;

  @override
  List<Object?> get props => [uid, caption, thumbnailUrl, authorName];
}

class CardSearchResult extends SearchResult {
  const CardSearchResult({
    required this.uid,
    this.displayName,
    this.cardType,
    this.displayImageUrl,
    this.ownerUsername,
    this.ownerFullName,
  });

  final String uid;
  final String? displayName;
  final String? cardType;
  final String? displayImageUrl;
  final String? ownerUsername;
  final String? ownerFullName;

  @override
  List<Object?> get props =>
      [uid, displayName, cardType, displayImageUrl, ownerUsername, ownerFullName];
}

/// Grouped CPS response — each group is rendered as a section in the
/// search screen, in the same order the web's overlay uses.
class SearchResults extends Equatable {
  const SearchResults({
    this.users = const [],
    this.posts = const [],
    this.discussions = const [],
    this.centers = const [],
    this.brands = const [],
    this.events = const [],
    this.videos = const [],
    this.splits = const [],
    this.cards = const [],
  });

  final List<UserSearchResult> users;
  final List<PostSearchResult> posts;
  final List<DiscussionSearchResult> discussions;
  final List<CenterSearchResult> centers;
  final List<BrandSearchResult> brands;
  final List<EventSearchResult> events;
  final List<VideoSearchResult> videos;
  final List<SplitSearchResult> splits;
  final List<CardSearchResult> cards;

  bool get isEmpty =>
      users.isEmpty &&
      posts.isEmpty &&
      discussions.isEmpty &&
      centers.isEmpty &&
      brands.isEmpty &&
      events.isEmpty &&
      videos.isEmpty &&
      splits.isEmpty &&
      cards.isEmpty;

  int get totalCount =>
      users.length +
      posts.length +
      discussions.length +
      centers.length +
      brands.length +
      events.length +
      videos.length +
      splits.length +
      cards.length;

  @override
  List<Object?> get props => [
        users,
        posts,
        discussions,
        centers,
        brands,
        events,
        videos,
        splits,
        cards,
      ];
}
