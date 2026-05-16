part of 'live_list_bloc.dart';

class LiveListState extends Equatable {
  const LiveListState({
    this.loading = false,
    this.refreshing = false,
    this.loadingMore = false,
    this.scope = LiveListScope.all,
    this.items = const [],
    this.nextCursorId,
    this.errors = const [],
  });

  final bool loading;
  final bool refreshing;
  final bool loadingMore;
  final LiveListScope scope;
  final List<LiveBroadcastListItem> items;
  final int? nextCursorId;
  final List<String> errors;

  bool get hasMore => nextCursorId != null;

  LiveListState copyWith({
    bool? loading,
    bool? refreshing,
    bool? loadingMore,
    LiveListScope? scope,
    List<LiveBroadcastListItem>? items,
    int? nextCursorId,
    bool clearCursor = false,
    List<String>? errors,
  }) {
    return LiveListState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      loadingMore: loadingMore ?? this.loadingMore,
      scope: scope ?? this.scope,
      items: items ?? this.items,
      nextCursorId: clearCursor ? null : (nextCursorId ?? this.nextCursorId),
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        refreshing,
        loadingMore,
        scope,
        items,
        nextCursorId,
        errors,
      ];
}
