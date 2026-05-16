part of 'my_events_bloc.dart';

sealed class MyEventsEvent extends Equatable {
  const MyEventsEvent();
  @override
  List<Object?> get props => const [];
}

class MyEventsLoadRequested extends MyEventsEvent {
  const MyEventsLoadRequested({this.force = false});
  final bool force;
  @override
  List<Object?> get props => [force];
}

class MyEventsRefreshRequested extends MyEventsEvent {
  const MyEventsRefreshRequested();
}

class MyEventsNextPageRequested extends MyEventsEvent {
  const MyEventsNextPageRequested();
}
