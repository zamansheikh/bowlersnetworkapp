import 'package:equatable/equatable.dart';

/// Slim author shape used inside every chatter payload. Adds `isElite`
/// on top of the standard user fields (from the credibility system).
class ChatterAuthor extends Equatable {
  const ChatterAuthor({
    required this.id,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
    this.isPro = false,
    this.isElite = false,
    this.rankDisplay,
    this.badgeIconUrl,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? profilePictureUrl;
  final bool isPro;
  final bool isElite;
  final String? rankDisplay;
  final String? badgeIconUrl;

  String get displayName {
    final full = '$firstName $lastName'.trim();
    return full.isEmpty ? username : full;
  }

  @override
  List<Object?> get props => [
        id,
        username,
        firstName,
        lastName,
        profilePictureUrl,
        isPro,
        isElite,
        rankDisplay,
        badgeIconUrl,
      ];
}

class Topic extends Equatable {
  const Topic({
    required this.id,
    required this.name,
    this.description = '',
    this.bannerUrl,
    this.threadCount = 0,
  });

  final int id;
  final String name;
  final String description;
  final String? bannerUrl;
  final int threadCount;

  @override
  List<Object?> get props => [id, name, description, bannerUrl, threadCount];
}

/// Full discussion shape — list cards and the detail screen share this.
/// Viewer flags (`hasUpvoted`, `hasSaved`, `isMine`) are null when not in
/// an authenticated context.
class Discussion extends Equatable {
  const Discussion({
    required this.id,
    required this.uid,
    required this.title,
    this.body = '',
    this.author,
    this.topic,
    this.tags = const [],
    this.upvoteCount = 0,
    this.downvoteCount = 0,
    this.opinionCount = 0,
    this.viewCount = 0,
    this.saveCount = 0,
    this.isResolved = false,
    this.isLocked = false,
    this.isPinned = false,
    this.isEdited = false,
    this.isMostRead = false,
    this.createdAt,
    this.isMine,
    this.hasUpvoted,
    this.hasDownvoted,
    this.hasSaved,
  });

  final int id;
  final String uid;
  final String title;
  final String body;
  final ChatterAuthor? author;
  final Topic? topic;
  final List<String> tags;
  final int upvoteCount;
  final int downvoteCount;
  final int opinionCount;
  final int viewCount;
  final int saveCount;
  final bool isResolved;
  final bool isLocked;
  final bool isPinned;
  final bool isEdited;
  final bool isMostRead;
  final DateTime? createdAt;

  final bool? isMine;
  final bool? hasUpvoted;
  final bool? hasDownvoted;
  final bool? hasSaved;

  /// Returns a copy with only the upvote-related fields swapped — used by
  /// the detail bloc to apply optimistic flips.
  Discussion withUpvote({required bool hasUpvoted, required int upvoteCount}) =>
      Discussion(
        id: id,
        uid: uid,
        title: title,
        body: body,
        author: author,
        topic: topic,
        tags: tags,
        upvoteCount: upvoteCount,
        downvoteCount: downvoteCount,
        opinionCount: opinionCount,
        viewCount: viewCount,
        saveCount: saveCount,
        isResolved: isResolved,
        isLocked: isLocked,
        isPinned: isPinned,
        isEdited: isEdited,
        isMostRead: isMostRead,
        createdAt: createdAt,
        isMine: isMine,
        hasUpvoted: hasUpvoted,
        hasDownvoted: hasDownvoted,
        hasSaved: hasSaved,
      );

  /// Used when the user posts a new top-level opinion — bumps the count.
  Discussion withOpinionCount(int newCount) => Discussion(
        id: id,
        uid: uid,
        title: title,
        body: body,
        author: author,
        topic: topic,
        tags: tags,
        upvoteCount: upvoteCount,
        downvoteCount: downvoteCount,
        opinionCount: newCount,
        viewCount: viewCount,
        saveCount: saveCount,
        isResolved: isResolved,
        isLocked: isLocked,
        isPinned: isPinned,
        isEdited: isEdited,
        isMostRead: isMostRead,
        createdAt: createdAt,
        isMine: isMine,
        hasUpvoted: hasUpvoted,
        hasDownvoted: hasDownvoted,
        hasSaved: hasSaved,
      );

  @override
  List<Object?> get props => [
        id,
        uid,
        title,
        body,
        author,
        topic,
        tags,
        upvoteCount,
        downvoteCount,
        opinionCount,
        viewCount,
        saveCount,
        isResolved,
        isLocked,
        isPinned,
        isEdited,
        isMostRead,
        createdAt,
        isMine,
        hasUpvoted,
        hasDownvoted,
        hasSaved,
      ];
}

class Opinion extends Equatable {
  const Opinion({
    required this.id,
    required this.body,
    this.author,
    this.upvoteCount = 0,
    this.downvoteCount = 0,
    this.netScore = 0,
    this.replyCount = 0,
    this.isAcknowledged = false,
    this.isPinned = false,
    this.isEdited = false,
    this.isHidden = false,
    this.createdAt,
    this.parentId,
    this.isMine,
    this.hasUpvoted,
    this.hasDownvoted,
  });

  final int id;
  final String body;
  final ChatterAuthor? author;
  final int upvoteCount;
  final int downvoteCount;
  final int netScore;
  final int replyCount;
  final bool isAcknowledged;
  final bool isPinned;
  final bool isEdited;
  final bool isHidden;
  final DateTime? createdAt;
  final int? parentId;
  final bool? isMine;
  final bool? hasUpvoted;
  final bool? hasDownvoted;

  Opinion withUpvote({required bool hasUpvoted, required int upvoteCount}) =>
      Opinion(
        id: id,
        body: body,
        author: author,
        upvoteCount: upvoteCount,
        downvoteCount: downvoteCount,
        netScore: upvoteCount - downvoteCount,
        replyCount: replyCount,
        isAcknowledged: isAcknowledged,
        isPinned: isPinned,
        isEdited: isEdited,
        isHidden: isHidden,
        createdAt: createdAt,
        parentId: parentId,
        isMine: isMine,
        hasUpvoted: hasUpvoted,
        hasDownvoted: hasDownvoted,
      );

  @override
  List<Object?> get props => [
        id,
        body,
        author,
        upvoteCount,
        downvoteCount,
        netScore,
        replyCount,
        isAcknowledged,
        isPinned,
        isEdited,
        isHidden,
        createdAt,
        parentId,
        isMine,
        hasUpvoted,
        hasDownvoted,
      ];
}

/// Discussion list options used by the bloc + list page.
enum DiscussionSort {
  recent('recent', 'Recent'),
  mostRead('most_read', 'Most read'),
  mostDiscussed('most_discussed', 'Most discussed'),
  unanswered('unanswered', 'Unanswered');

  const DiscussionSort(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

enum OpinionSort {
  top('top', 'Top'),
  newest('newest', 'New'),
  oldest('oldest', 'Old');

  const OpinionSort(this.apiValue, this.label);
  final String apiValue;
  final String label;
}
