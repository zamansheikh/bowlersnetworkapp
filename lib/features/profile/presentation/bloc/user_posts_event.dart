part of 'user_posts_bloc.dart';

sealed class UserPostsEvent extends Equatable {
  const UserPostsEvent();
  @override
  List<Object?> get props => const [];
}

class UserPostsLoadRequested extends UserPostsEvent {
  const UserPostsLoadRequested({this.force = false});
  final bool force;
  @override
  List<Object?> get props => [force];
}

class UserPostsRefreshRequested extends UserPostsEvent {
  const UserPostsRefreshRequested();
}

class UserPostsNextPageRequested extends UserPostsEvent {
  const UserPostsNextPageRequested();
}

/// Tap on the reaction bar — same enum the FeedBloc uses.
class UserPostsReactionToggled extends UserPostsEvent {
  const UserPostsReactionToggled({
    required this.postUid,
    required this.reaction,
  });
  final String postUid;
  final ReactionType reaction;
  @override
  List<Object?> get props => [postUid, reaction];
}

class UserPostsSaveToggled extends UserPostsEvent {
  const UserPostsSaveToggled({required this.postUid});
  final String postUid;
  @override
  List<Object?> get props => [postUid];
}
