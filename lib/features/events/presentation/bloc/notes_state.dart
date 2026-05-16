part of 'notes_bloc.dart';

class NotesState extends Equatable {
  const NotesState({
    this.loading = false,
    this.refreshing = false,
    this.loadingMore = false,
    this.notes = const [],
    this.page = 1,
    this.hasMore = false,
    this.posting = false,
    this.replyBusyIds = const {},
    this.deleteBusyIds = const {},
    this.errors = const [],
  });

  final bool loading;
  final bool refreshing;
  final bool loadingMore;
  final List<EventNote> notes;
  final int page;
  final bool hasMore;

  /// True while the top-level note composer is submitting.
  final bool posting;

  /// IDs whose reply RPC is currently in flight — disables that
  /// specific reply input without blocking the rest.
  final Set<int> replyBusyIds;

  /// IDs whose delete RPC is currently in flight.
  final Set<int> deleteBusyIds;

  final List<String> errors;

  NotesState copyWith({
    bool? loading,
    bool? refreshing,
    bool? loadingMore,
    List<EventNote>? notes,
    int? page,
    bool? hasMore,
    bool? posting,
    Set<int>? replyBusyIds,
    Set<int>? deleteBusyIds,
    List<String>? errors,
  }) {
    return NotesState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      loadingMore: loadingMore ?? this.loadingMore,
      notes: notes ?? this.notes,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      posting: posting ?? this.posting,
      replyBusyIds: replyBusyIds ?? this.replyBusyIds,
      deleteBusyIds: deleteBusyIds ?? this.deleteBusyIds,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        refreshing,
        loadingMore,
        notes,
        page,
        hasMore,
        posting,
        replyBusyIds,
        deleteBusyIds,
        errors,
      ];
}
