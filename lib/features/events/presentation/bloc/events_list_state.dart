part of 'events_list_bloc.dart';

/// Per-category pagination + loading flags. Each tab owns a slot so
/// switching tabs doesn't lose pagination position.
class EventsSlot extends Equatable {
  const EventsSlot({
    this.events = const [],
    this.loading = false,
    this.refreshing = false,
    this.loadingMore = false,
    this.page = 1,
    this.hasMore = false,
    this.errors = const [],
  });

  final List<Event> events;
  final bool loading;
  final bool refreshing;
  final bool loadingMore;
  final int page;
  final bool hasMore;
  final List<String> errors;

  EventsSlot copyWith({
    List<Event>? events,
    bool? loading,
    bool? refreshing,
    bool? loadingMore,
    int? page,
    bool? hasMore,
    List<String>? errors,
  }) {
    return EventsSlot(
      events: events ?? this.events,
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
      [events, loading, refreshing, loadingMore, page, hasMore, errors];
}

class EventsListState extends Equatable {
  const EventsListState({
    this.activeCategory = EventCategory.upcoming,
    this.trending = const EventsSlot(),
    this.upcoming = const EventsSlot(),
    this.joined = const EventsSlot(),
    this.created = const EventsSlot(),
  });

  final EventCategory activeCategory;
  final EventsSlot trending;
  final EventsSlot upcoming;
  final EventsSlot joined;
  final EventsSlot created;

  EventsSlot slotFor(EventCategory cat) {
    switch (cat) {
      case EventCategory.trending:
        return trending;
      case EventCategory.upcoming:
        return upcoming;
      case EventCategory.joined:
        return joined;
      case EventCategory.created:
        return created;
    }
  }

  EventsSlot get activeSlot => slotFor(activeCategory);

  EventsListState copyWith({
    EventCategory? activeCategory,
    EventsSlot? trending,
    EventsSlot? upcoming,
    EventsSlot? joined,
    EventsSlot? created,
  }) {
    return EventsListState(
      activeCategory: activeCategory ?? this.activeCategory,
      trending: trending ?? this.trending,
      upcoming: upcoming ?? this.upcoming,
      joined: joined ?? this.joined,
      created: created ?? this.created,
    );
  }

  EventsListState copyWithSlot(EventCategory cat, EventsSlot slot) {
    switch (cat) {
      case EventCategory.trending:
        return copyWith(trending: slot);
      case EventCategory.upcoming:
        return copyWith(upcoming: slot);
      case EventCategory.joined:
        return copyWith(joined: slot);
      case EventCategory.created:
        return copyWith(created: slot);
    }
  }

  @override
  List<Object?> get props =>
      [activeCategory, trending, upcoming, joined, created];
}
