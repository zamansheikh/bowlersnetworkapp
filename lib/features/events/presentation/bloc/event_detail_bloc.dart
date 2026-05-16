import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/event.dart';
import '../../domain/repositories/events_repository.dart';

part 'event_detail_event.dart';
part 'event_detail_state.dart';

/// One per detail screen — NOT a singleton; uid is locked at construction.
/// Owns the loaded [Event] + the in-flight interest toggle.
class EventDetailBloc extends Bloc<EventDetailEvent, EventDetailState> {
  EventDetailBloc({
    required EventsRepository repository,
    required String uid,
  })  : _repository = repository,
        _uid = uid,
        super(const EventDetailState()) {
    on<EventDetailLoadRequested>(_onLoad);
    on<EventDetailRefreshRequested>(_onRefresh);
    on<EventDetailInterestToggled>(_onInterest);
  }

  final EventsRepository _repository;
  final String _uid;

  Future<void> _onLoad(
    EventDetailLoadRequested event,
    Emitter<EventDetailState> emit,
  ) async {
    emit(state.copyWith(loading: true, errors: const []));
    final res = await _repository.getEvent(_uid);
    res.fold(
      (f) => emit(state.copyWith(loading: false, errors: f.messages)),
      (event) => emit(state.copyWith(loading: false, event: event)),
    );
  }

  Future<void> _onRefresh(
    EventDetailRefreshRequested event,
    Emitter<EventDetailState> emit,
  ) async {
    emit(state.copyWith(refreshing: true, errors: const []));
    final res = await _repository.getEvent(_uid);
    res.fold(
      (f) => emit(state.copyWith(refreshing: false, errors: f.messages)),
      (event) => emit(state.copyWith(refreshing: false, event: event)),
    );
  }

  Future<void> _onInterest(
    EventDetailInterestToggled event,
    Emitter<EventDetailState> emit,
  ) async {
    final current = state.event;
    if (current == null || state.interestBusy) return;
    if (current.isCreator == true) return; // backend rejects own-event interest

    final wasInterested = current.isInterested == true;
    final optimistic = current.withInterest(
      isInterested: !wasInterested,
      count: (current.interestedCount + (wasInterested ? -1 : 1))
          .clamp(0, 1 << 31),
    );
    emit(state.copyWith(event: optimistic, interestBusy: true));

    final res = await _repository.toggleInterest(_uid);
    res.fold(
      (f) => emit(state.copyWith(
        event: current, // rollback
        interestBusy: false,
        errors: f.messages,
      )),
      (result) => emit(state.copyWith(
        event: current.withInterest(
          isInterested: result.isInterested,
          count: result.interestedCount,
        ),
        interestBusy: false,
      )),
    );
  }
}
