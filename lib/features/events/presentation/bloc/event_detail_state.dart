part of 'event_detail_bloc.dart';

class EventDetailState extends Equatable {
  const EventDetailState({
    this.loading = false,
    this.refreshing = false,
    this.event,
    this.interestBusy = false,
    this.errors = const [],
  });

  /// True while the initial fetch is in flight (no prior result).
  final bool loading;

  /// True during pull-to-refresh — existing content stays on screen.
  final bool refreshing;

  final Event? event;

  /// True while an interest-toggle RPC is in flight.
  final bool interestBusy;

  final List<String> errors;

  EventDetailState copyWith({
    bool? loading,
    bool? refreshing,
    Event? event,
    bool? interestBusy,
    List<String>? errors,
  }) {
    return EventDetailState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      event: event ?? this.event,
      interestBusy: interestBusy ?? this.interestBusy,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [loading, refreshing, event, interestBusy, errors];
}
