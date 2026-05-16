part of 'media_feed_bloc.dart';

sealed class MediaFeedEvent extends Equatable {
  const MediaFeedEvent();
  @override
  List<Object?> get props => const [];
}

class MediaFeedLoadRequested extends MediaFeedEvent {
  const MediaFeedLoadRequested({this.force = false});
  final bool force;
  @override
  List<Object?> get props => [force];
}

class MediaFeedRefreshRequested extends MediaFeedEvent {
  const MediaFeedRefreshRequested();
}

class MediaFeedNextPageRequested extends MediaFeedEvent {
  const MediaFeedNextPageRequested();
}

class MediaFeedSubTabChanged extends MediaFeedEvent {
  const MediaFeedSubTabChanged(this.kind);
  final MediaKind kind;
  @override
  List<Object?> get props => [kind];
}
