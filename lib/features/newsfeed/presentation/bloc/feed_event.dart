part of 'feed_bloc.dart';

sealed class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => const [];
}

class FeedLoadRequested extends FeedEvent {
  const FeedLoadRequested();
}

class FeedRefreshRequested extends FeedEvent {
  const FeedRefreshRequested();
}

class FeedNextPageRequested extends FeedEvent {
  const FeedNextPageRequested();
}

class FeedReactionToggled extends FeedEvent {
  const FeedReactionToggled({required this.postUid, required this.reaction});
  final String postUid;
  final ReactionType reaction;

  @override
  List<Object?> get props => [postUid, reaction];
}

class FeedSaveToggled extends FeedEvent {
  const FeedSaveToggled({required this.postUid});
  final String postUid;
  @override
  List<Object?> get props => [postUid];
}

class FeedPostHidden extends FeedEvent {
  const FeedPostHidden({required this.postUid});
  final String postUid;
  @override
  List<Object?> get props => [postUid];
}

class FeedFilterChanged extends FeedEvent {
  const FeedFilterChanged({this.filter});
  final String? filter;

  @override
  List<Object?> get props => [filter];
}

/// Prepend a freshly-created post to the top of the feed — avoids a full
/// refetch after the composer submits.
class FeedPostCreated extends FeedEvent {
  const FeedPostCreated(this.post);
  final Post post;

  @override
  List<Object?> get props => [post];
}

/// Repost (share) a post — matches web's direct repost button: no caption
/// modal. The newly-created shared post is prepended; the original's
/// `sharesCount` is bumped optimistically.
class FeedShareRequested extends FeedEvent {
  const FeedShareRequested({required this.postUid});
  final String postUid;

  @override
  List<Object?> get props => [postUid];
}

/// Toggle a post's pinned flag (owner only). Optimistic flip with rollback.
class FeedPinToggled extends FeedEvent {
  const FeedPinToggled({required this.postUid});
  final String postUid;
  @override
  List<Object?> get props => [postUid];
}

/// Enable/disable comments on one of your posts.
class FeedCommentsToggled extends FeedEvent {
  const FeedCommentsToggled({required this.postUid, required this.enabled});
  final String postUid;
  final bool enabled;
  @override
  List<Object?> get props => [postUid, enabled];
}
