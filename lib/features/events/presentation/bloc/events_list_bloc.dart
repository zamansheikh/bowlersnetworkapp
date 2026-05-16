import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/event.dart';
import '../../domain/repositories/events_repository.dart';

part 'events_list_event.dart';
part 'events_list_state.dart';

/// Drives the /events list screen. Category tabs (Trending / Upcoming /
/// Joined / Created) each get their own pagination slot so switching
/// between them doesn't lose state and there's no flicker on tab swap.
///
/// Interest toggles mutate the matching card in-place so the UI doesn't
/// rebuild the whole list.
@injectable
class EventsListBloc extends Bloc<EventsListEvent, EventsListState> {
  EventsListBloc(this._repository) : super(const EventsListState()) {
    on<EventsListLoadRequested>(_onLoad);
    on<EventsListRefreshRequested>(_onRefresh);
    on<EventsListNextPageRequested>(_onNextPage);
    on<EventsListCategoryChanged>(_onCategoryChanged);
    on<EventsListInterestToggled>(_onInterest);
  }

  final EventsRepository _repository;

  Future<void> _onLoad(
    EventsListLoadRequested event,
    Emitter<EventsListState> emit,
  ) async {
    final cat = state.activeCategory;
    final slot = state.slotFor(cat);
    if (slot.events.isNotEmpty && !event.force) return;
    emit(state.copyWithSlot(
      cat,
      slot.copyWith(loading: true, errors: const []),
    ));
    final res = await _repository.getEventsFeed(category: cat, page: 1);
    res.fold(
      (f) => emit(state.copyWithSlot(
        cat,
        slot.copyWith(loading: false, errors: f.messages),
      )),
      (page) => emit(state.copyWithSlot(
        cat,
        slot.copyWith(
          loading: false,
          events: page.events,
          page: 1,
          hasMore: page.hasMore,
        ),
      )),
    );
  }

  Future<void> _onRefresh(
    EventsListRefreshRequested event,
    Emitter<EventsListState> emit,
  ) async {
    final cat = state.activeCategory;
    final slot = state.slotFor(cat);
    emit(state.copyWithSlot(
      cat,
      slot.copyWith(refreshing: true, errors: const []),
    ));
    final res = await _repository.getEventsFeed(category: cat, page: 1);
    res.fold(
      (f) => emit(state.copyWithSlot(
        cat,
        slot.copyWith(refreshing: false, errors: f.messages),
      )),
      (page) => emit(state.copyWithSlot(
        cat,
        slot.copyWith(
          refreshing: false,
          events: page.events,
          page: 1,
          hasMore: page.hasMore,
        ),
      )),
    );
  }

  Future<void> _onNextPage(
    EventsListNextPageRequested event,
    Emitter<EventsListState> emit,
  ) async {
    final cat = state.activeCategory;
    final slot = state.slotFor(cat);
    if (slot.loadingMore || !slot.hasMore || slot.loading) return;
    emit(state.copyWithSlot(cat, slot.copyWith(loadingMore: true)));
    final next = slot.page + 1;
    final res = await _repository.getEventsFeed(category: cat, page: next);
    res.fold(
      (f) => emit(state.copyWithSlot(
        cat,
        slot.copyWith(loadingMore: false, errors: f.messages),
      )),
      (page) {
        final cur = state.slotFor(cat);
        emit(state.copyWithSlot(
          cat,
          cur.copyWith(
            loadingMore: false,
            events: [...cur.events, ...page.events],
            page: next,
            hasMore: page.hasMore,
          ),
        ));
      },
    );
  }

  void _onCategoryChanged(
    EventsListCategoryChanged event,
    Emitter<EventsListState> emit,
  ) {
    if (event.category == state.activeCategory) return;
    emit(state.copyWith(activeCategory: event.category));
    final slot = state.slotFor(event.category);
    if (slot.events.isEmpty && !slot.loading) {
      add(const EventsListLoadRequested());
    }
  }

  Future<void> _onInterest(
    EventsListInterestToggled event,
    Emitter<EventsListState> emit,
  ) async {
    final res = await _repository.toggleInterest(event.uid);
    res.fold(
      (_) {/* silent — toast belongs to the screen if it cares */},
      (result) => _patchAcrossSlots(emit, event.uid, (e) {
        return e.withInterest(
          isInterested: result.isInterested,
          count: result.interestedCount,
        );
      }),
    );
  }

  /// Apply [transform] to a matching event in every slot it appears in
  /// — a single backend toggle should update the card wherever the user
  /// sees it (e.g. visible in both Trending and Joined).
  void _patchAcrossSlots(
    Emitter<EventsListState> emit,
    String uid,
    Event Function(Event) transform,
  ) {
    EventsListState next = state;
    for (final cat in EventCategory.values) {
      final slot = next.slotFor(cat);
      final idx = slot.events.indexWhere((e) => e.uid == uid);
      if (idx == -1) continue;
      final updated = List<Event>.from(slot.events);
      updated[idx] = transform(slot.events[idx]);
      next = next.copyWithSlot(cat, slot.copyWith(events: updated));
    }
    if (next != state) emit(next);
  }
}
