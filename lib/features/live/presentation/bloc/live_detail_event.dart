part of 'live_detail_bloc.dart';

sealed class LiveDetailEvent extends Equatable {
  const LiveDetailEvent();
  @override
  List<Object?> get props => const [];
}

class LiveDetailOpened extends LiveDetailEvent {
  const LiveDetailOpened(this.uid);
  final String uid;
  @override
  List<Object?> get props => [uid];
}

class LiveDetailRefreshRequested extends LiveDetailEvent {
  const LiveDetailRefreshRequested();
}

class LiveCommentsLoadMore extends LiveDetailEvent {
  const LiveCommentsLoadMore();
}

class LiveCommentPosted extends LiveDetailEvent {
  const LiveCommentPosted(this.body);
  final String body;
  @override
  List<Object?> get props => [body];
}

class LiveCommentDeleted extends LiveDetailEvent {
  const LiveCommentDeleted(this.commentId);
  final int commentId;
  @override
  List<Object?> get props => [commentId];
}

class LiveReactionPicked extends LiveDetailEvent {
  const LiveReactionPicked(this.type);
  final LiveReactionType type;
  @override
  List<Object?> get props => [type];
}

class LiveReactionCleared extends LiveDetailEvent {
  const LiveReactionCleared();
}
