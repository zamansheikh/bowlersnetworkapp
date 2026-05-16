part of 'events_list_bloc.dart';

sealed class EventsListEvent extends Equatable {
  const EventsListEvent();
  @override
  List<Object?> get props => const [];
}

class EventsListLoadRequested extends EventsListEvent {
  const EventsListLoadRequested({this.force = false});
  final bool force;
  @override
  List<Object?> get props => [force];
}

class EventsListRefreshRequested extends EventsListEvent {
  const EventsListRefreshRequested();
}

class EventsListNextPageRequested extends EventsListEvent {
  const EventsListNextPageRequested();
}

class EventsListCategoryChanged extends EventsListEvent {
  const EventsListCategoryChanged(this.category);
  final EventCategory category;
  @override
  List<Object?> get props => [category];
}

/// Tap on a card's heart icon. Backend handles the toggle direction.
class EventsListInterestToggled extends EventsListEvent {
  const EventsListInterestToggled(this.uid);
  final String uid;
  @override
  List<Object?> get props => [uid];
}
