part of 'feed_bloc.dart';

sealed class FeedEvent extends Equatable {
  const FeedEvent();
  @override
  List<Object?> get props => [];
}

class FeedLoadRequested extends FeedEvent {
  final String? filter;
  const FeedLoadRequested({this.filter});
  @override
  List<Object?> get props => [filter];
}

class FeedLoadMoreRequested extends FeedEvent {
  const FeedLoadMoreRequested();
}

class FeedRefreshRequested extends FeedEvent {
  const FeedRefreshRequested();
}

class FeedReactRequested extends FeedEvent {
  final int postId;
  final String reactionType;
  const FeedReactRequested({required this.postId, required this.reactionType});
  @override
  List<Object?> get props => [postId, reactionType];
}

class FeedSaveToggled extends FeedEvent {
  final int postId;
  const FeedSaveToggled({required this.postId});
  @override
  List<Object?> get props => [postId];
}

class FeedPostHidden extends FeedEvent {
  final int postId;
  const FeedPostHidden({required this.postId});
  @override
  List<Object?> get props => [postId];
}

class FeedPostDeleted extends FeedEvent {
  final int postId;
  const FeedPostDeleted({required this.postId});
  @override
  List<Object?> get props => [postId];
}
