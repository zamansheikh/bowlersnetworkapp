part of 'my_events_bloc.dart';

class MyEventsState extends Equatable {
  const MyEventsState({
    this.loading = false,
    this.refreshing = false,
    this.loadingMore = false,
    this.events = const [],
    this.page = 1,
    this.hasMore = false,
    this.errors = const [],
  });

  final bool loading;
  final bool refreshing;
  final bool loadingMore;
  final List<Event> events;
  final int page;
  final bool hasMore;
  final List<String> errors;

  MyEventsState copyWith({
    bool? loading,
    bool? refreshing,
    bool? loadingMore,
    List<Event>? events,
    int? page,
    bool? hasMore,
    List<String>? errors,
  }) {
    return MyEventsState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      loadingMore: loadingMore ?? this.loadingMore,
      events: events ?? this.events,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        refreshing,
        loadingMore,
        events,
        page,
        hasMore,
        errors,
      ];
}
