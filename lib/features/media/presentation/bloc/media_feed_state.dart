part of 'media_feed_bloc.dart';

/// Per-kind pagination + loading flags. Each sub-tab owns a slot so
/// switching kinds doesn't lose pagination state.
class MediaFeedSlot extends Equatable {
  const MediaFeedSlot({
    this.items = const [],
    this.loading = false,
    this.refreshing = false,
    this.loadingMore = false,
    this.page = 1,
    this.hasMore = false,
  });

  final List<MediaItem> items;
  final bool loading;
  final bool refreshing;
  final bool loadingMore;
  final int page;
  final bool hasMore;

  MediaFeedSlot copyWith({
    List<MediaItem>? items,
    bool? loading,
    bool? refreshing,
    bool? loadingMore,
    int? page,
    bool? hasMore,
  }) {
    return MediaFeedSlot(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      loadingMore: loadingMore ?? this.loadingMore,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props =>
      [items, loading, refreshing, loadingMore, page, hasMore];
}

class MediaFeedState extends Equatable {
  const MediaFeedState({
    this.activeKind = MediaKind.video,
    this.videos = const MediaFeedSlot(),
    this.splits = const MediaFeedSlot(),
  });

  final MediaKind activeKind;
  final MediaFeedSlot videos;
  final MediaFeedSlot splits;

  MediaFeedSlot slotFor(MediaKind kind) =>
      kind == MediaKind.video ? videos : splits;

  MediaFeedSlot get activeSlot => slotFor(activeKind);

  MediaFeedState copyWith({
    MediaKind? activeKind,
    MediaFeedSlot? videos,
    MediaFeedSlot? splits,
  }) {
    return MediaFeedState(
      activeKind: activeKind ?? this.activeKind,
      videos: videos ?? this.videos,
      splits: splits ?? this.splits,
    );
  }

  MediaFeedState copyWithSlot(MediaKind kind, MediaFeedSlot slot) =>
      kind == MediaKind.video ? copyWith(videos: slot) : copyWith(splits: slot);

  @override
  List<Object?> get props => [activeKind, videos, splits];
}
