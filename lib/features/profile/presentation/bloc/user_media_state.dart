part of 'user_media_bloc.dart';

/// Per-kind pagination + loading flags. Each sub-tab owns its own slot
/// so switching between Videos / Splits doesn't lose state.
class MediaSlot extends Equatable {
  const MediaSlot({
    this.items = const [],
    this.loading = false,
    this.refreshing = false,
    this.loadingMore = false,
    this.page = 1,
    this.hasMore = false,
    this.errors = const [],
  });

  final List<MediaItem> items;
  final bool loading;
  final bool refreshing;
  final bool loadingMore;
  final int page;
  final bool hasMore;
  final List<String> errors;

  MediaSlot copyWith({
    List<MediaItem>? items,
    bool? loading,
    bool? refreshing,
    bool? loadingMore,
    int? page,
    bool? hasMore,
    List<String>? errors,
  }) {
    return MediaSlot(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      loadingMore: loadingMore ?? this.loadingMore,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props =>
      [items, loading, refreshing, loadingMore, page, hasMore, errors];
}

class UserMediaState extends Equatable {
  const UserMediaState({
    this.activeKind = MediaKind.video,
    this.videos = const MediaSlot(),
    this.splits = const MediaSlot(),
  });

  final MediaKind activeKind;
  final MediaSlot videos;
  final MediaSlot splits;

  MediaSlot slotFor(MediaKind kind) =>
      kind == MediaKind.video ? videos : splits;

  /// Convenience for screens that just want the slot the user is
  /// currently viewing.
  MediaSlot get activeSlot => slotFor(activeKind);

  UserMediaState copyWith({
    MediaKind? activeKind,
    MediaSlot? videos,
    MediaSlot? splits,
  }) {
    return UserMediaState(
      activeKind: activeKind ?? this.activeKind,
      videos: videos ?? this.videos,
      splits: splits ?? this.splits,
    );
  }

  UserMediaState copyWithSlot(MediaKind kind, MediaSlot slot) =>
      kind == MediaKind.video ? copyWith(videos: slot) : copyWith(splits: slot);

  @override
  List<Object?> get props => [activeKind, videos, splits];
}
