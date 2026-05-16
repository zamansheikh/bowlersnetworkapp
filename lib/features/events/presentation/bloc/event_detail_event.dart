part of 'event_detail_bloc.dart';

sealed class EventDetailEvent extends Equatable {
  const EventDetailEvent();
  @override
  List<Object?> get props => const [];
}

class EventDetailLoadRequested extends EventDetailEvent {
  const EventDetailLoadRequested();
}

class EventDetailRefreshRequested extends EventDetailEvent {
  const EventDetailRefreshRequested();
}

/// Tap on the "I'm interested" button. Optimistic flip + backend
/// reconciliation handled by the bloc.
class EventDetailInterestToggled extends EventDetailEvent {
  const EventDetailInterestToggled();
}
