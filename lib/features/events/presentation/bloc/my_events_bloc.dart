import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/event.dart';
import '../../domain/repositories/events_repository.dart';

part 'my_events_event.dart';
part 'my_events_state.dart';

/// Drives /events/my — paginated list of events the viewer has
/// created. Cards reuse the same widget the main feed uses; this bloc
/// just owns the pagination state.
@injectable
class MyEventsBloc extends Bloc<MyEventsEvent, MyEventsState> {
  MyEventsBloc(this._repository) : super(const MyEventsState()) {
    on<MyEventsLoadRequested>(_onLoad);
    on<MyEventsRefreshRequested>(_onRefresh);
    on<MyEventsNextPageRequested>(_onNextPage);
  }

  final EventsRepository _repository;

  Future<void> _onLoad(
    MyEventsLoadRequested event,
    Emitter<MyEventsState> emit,
  ) async {
    if (state.events.isNotEmpty && !event.force) return;
    emit(state.copyWith(loading: true, errors: const []));
    final res = await _repository.getMyEvents(page: 1);
    res.fold(
      (f) => emit(state.copyWith(loading: false, errors: f.messages)),
      (page) => emit(state.copyWith(
        loading: false,
        events: page.events,
        page: 1,
        hasMore: page.hasMore,
      )),
    );
  }

  Future<void> _onRefresh(
    MyEventsRefreshRequested event,
    Emitter<MyEventsState> emit,
  ) async {
    emit(state.copyWith(refreshing: true, errors: const []));
    final res = await _repository.getMyEvents(page: 1);
    res.fold(
      (f) => emit(state.copyWith(refreshing: false, errors: f.messages)),
      (page) => emit(state.copyWith(
        refreshing: false,
        events: page.events,
        page: 1,
        hasMore: page.hasMore,
      )),
    );
  }

  Future<void> _onNextPage(
    MyEventsNextPageRequested event,
    Emitter<MyEventsState> emit,
  ) async {
    if (state.loadingMore || !state.hasMore || state.loading) return;
    emit(state.copyWith(loadingMore: true));
    final next = state.page + 1;
    final res = await _repository.getMyEvents(page: next);
    res.fold(
      (f) => emit(state.copyWith(loadingMore: false, errors: f.messages)),
      (page) => emit(state.copyWith(
        loadingMore: false,
        events: [...state.events, ...page.events],
        page: next,
        hasMore: page.hasMore,
      )),
    );
  }
}
