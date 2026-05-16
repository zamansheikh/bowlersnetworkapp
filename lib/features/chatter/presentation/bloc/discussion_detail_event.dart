part of 'discussion_detail_bloc.dart';

sealed class DiscussionDetailEvent extends Equatable {
  const DiscussionDetailEvent();
  @override
  List<Object?> get props => const [];
}

class DiscussionDetailLoadRequested extends DiscussionDetailEvent {
  const DiscussionDetailLoadRequested();
}

class DiscussionDetailRefreshRequested extends DiscussionDetailEvent {
  const DiscussionDetailRefreshRequested();
}

/// User tapped the upvote arrow on the discussion header. Optimistic.
class DiscussionDetailUpvoteToggled extends DiscussionDetailEvent {
  const DiscussionDetailUpvoteToggled();
}

/// User switched the opinion sort tab.
class DiscussionDetailOpinionSortChanged extends DiscussionDetailEvent {
  const DiscussionDetailOpinionSortChanged(this.sort);
  final OpinionSort sort;
  @override
  List<Object?> get props => [sort];
}

class DiscussionDetailOpinionsNextPageRequested extends DiscussionDetailEvent {
  const DiscussionDetailOpinionsNextPageRequested();
}

/// User tapped the upvote arrow on one of the opinion cards.
class DiscussionDetailOpinionUpvoteToggled extends DiscussionDetailEvent {
  const DiscussionDetailOpinionUpvoteToggled(this.opinionId);
  final int opinionId;
  @override
  List<Object?> get props => [opinionId];
}

/// User submitted the opinion composer. `parentId` is null for a new
/// top-level opinion; otherwise it's a reply (which posts but isn't
/// rendered inline in this iteration).
class DiscussionDetailOpinionPosted extends DiscussionDetailEvent {
  const DiscussionDetailOpinionPosted({required this.body, this.parentId});
  final String body;
  final int? parentId;
  @override
  List<Object?> get props => [body, parentId];
}
