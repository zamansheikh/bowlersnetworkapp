import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/live_viewer.dart';
import '../../domain/repositories/live_repository.dart';

part 'live_list_event.dart';
part 'live_list_state.dart';

/// Drives /live. Owns the current scope filter (all / following) and a
/// cursor-paginated list of active broadcasts. Switching scope clears
/// the current results so the user sees the skeleton — stale
/// "following" cards while the "all" set loads in is confusing.
@injectable
class LiveListBloc extends Bloc<LiveListEvent, LiveListState> {
  LiveListBloc(this._repository) : super(const LiveListState()) {
    on<LiveListLoadRequested>(_onLoad);
    on<LiveListRefreshRequested>(_onRefresh);
    on<LiveListScopeChanged>(_onScope);
    on<LiveListNextPageRequested>(_onNextPage);
  }

  final LiveRepository _repository;

  Future<void> _onLoad(
    LiveListLoadRequested event,
    Emitter<LiveListState> emit,
  ) async {
    if (state.items.isNotEmpty && !event.force) return;
    emit(state.copyWith(loading: true, errors: const []));
    await _fetch(emit, replace: true);
  }

  Future<void> _onRefresh(
    LiveListRefreshRequested event,
    Emitter<LiveListState> emit,
  ) async {
    emit(state.copyWith(refreshing: true, errors: const []));
    await _fetch(emit, replace: true);
  }

  Future<void> _onScope(
    LiveListScopeChanged event,
    Emitter<LiveListState> emit,
  ) async {
    if (event.scope == state.scope) return;
    emit(state.copyWith(
      scope: event.scope,
      items: const [],
      nextCursorId: null,
      loading: true,
      errors: const [],
    ));
    await _fetch(emit, replace: true);
  }

  Future<void> _onNextPage(
    LiveListNextPageRequested event,
    Emitter<LiveListState> emit,
  ) async {
    if (state.loadingMore || state.loading) return;
    if (state.nextCursorId == null) return;
    emit(state.copyWith(loadingMore: true));
    await _fetch(emit, replace: false);
  }

  Future<void> _fetch(
    Emitter<LiveListState> emit, {
    required bool replace,
  }) async {
    final cursor = replace ? null : state.nextCursorId;
    final res = await _repository.getLives(
      scope: state.scope,
      cursorId: cursor,
    );
    res.fold(
      (f) => emit(state.copyWith(
        loading: false,
        refreshing: false,
        loadingMore: false,
        errors: f.messages.isEmpty
            ? const ['Failed to load broadcasts.']
            : f.messages,
      )),
      (page) => emit(state.copyWith(
        loading: false,
        refreshing: false,
        loadingMore: false,
        items: replace
            ? page.items
            : [...state.items, ...page.items],
        nextCursorId: page.nextCursorId,
        errors: const [],
      )),
    );
  }
}
