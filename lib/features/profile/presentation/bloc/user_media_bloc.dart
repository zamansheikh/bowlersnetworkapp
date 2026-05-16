import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../media/domain/entities/media_item.dart';
import '../../../media/domain/repositories/media_repository.dart';

part 'user_media_event.dart';
part 'user_media_state.dart';

/// Drives the Media tab on a profile screen. One bloc instance per
/// profile keyed by [username]; tracks Videos and Splits independently
/// so switching between sub-tabs doesn't lose pagination state.
class UserMediaBloc extends Bloc<UserMediaEvent, UserMediaState> {
  UserMediaBloc({
    required MediaRepository repository,
    required this.username,
  })  : _repository = repository,
        super(const UserMediaState()) {
    on<UserMediaSubTabChanged>(_onSubTabChanged);
    on<UserMediaLoadRequested>(_onLoad);
    on<UserMediaRefreshRequested>(_onRefresh);
    on<UserMediaNextPageRequested>(_onNextPage);
  }

  final MediaRepository _repository;
  final String username;

  Future<void> _onLoad(
    UserMediaLoadRequested event,
    Emitter<UserMediaState> emit,
  ) async {
    final kind = state.activeKind;
    final slot = state.slotFor(kind);
    if (slot.items.isNotEmpty && !event.force) return;
    emit(state.copyWithSlot(
      kind,
      slot.copyWith(loading: true, errors: const []),
    ));
    final res = await _fetch(kind: kind, page: 1);
    res.fold(
      // Silently fall back to empty — matches web MediaTab.tsx, which
      // `.catch(() => setItems([]))` so a flaky media backend never
      // shows a red toast on top of an empty profile.
      (_) => emit(state.copyWithSlot(
        kind,
        slot.copyWith(loading: false, items: const [], hasMore: false),
      )),
      (page) => emit(state.copyWithSlot(
        kind,
        slot.copyWith(
          loading: false,
          items: page.items,
          page: 1,
          hasMore: page.hasMore,
        ),
      )),
    );
  }

  Future<void> _onRefresh(
    UserMediaRefreshRequested event,
    Emitter<UserMediaState> emit,
  ) async {
    final kind = state.activeKind;
    final slot = state.slotFor(kind);
    emit(state.copyWithSlot(
      kind,
      slot.copyWith(refreshing: true, errors: const []),
    ));
    final res = await _fetch(kind: kind, page: 1);
    res.fold(
      (_) => emit(state.copyWithSlot(
        kind,
        slot.copyWith(refreshing: false),
      )),
      (page) => emit(state.copyWithSlot(
        kind,
        slot.copyWith(
          refreshing: false,
          items: page.items,
          page: 1,
          hasMore: page.hasMore,
        ),
      )),
    );
  }

  Future<void> _onNextPage(
    UserMediaNextPageRequested event,
    Emitter<UserMediaState> emit,
  ) async {
    final kind = state.activeKind;
    final slot = state.slotFor(kind);
    if (slot.loadingMore || !slot.hasMore || slot.loading) return;
    emit(state.copyWithSlot(kind, slot.copyWith(loadingMore: true)));
    final next = slot.page + 1;
    final res = await _fetch(kind: kind, page: next);
    res.fold(
      // Silent — stop trying to paginate but don't disturb the user.
      (_) => emit(state.copyWithSlot(
        kind,
        slot.copyWith(loadingMore: false, hasMore: false),
      )),
      (page) {
        // Re-read slot since pagination is per-kind and may have shifted.
        final cur = state.slotFor(kind);
        emit(state.copyWithSlot(
          kind,
          cur.copyWith(
            loadingMore: false,
            items: [...cur.items, ...page.items],
            page: next,
            hasMore: page.hasMore,
          ),
        ));
      },
    );
  }

  void _onSubTabChanged(
    UserMediaSubTabChanged event,
    Emitter<UserMediaState> emit,
  ) {
    if (event.kind == state.activeKind) return;
    emit(state.copyWith(activeKind: event.kind));
    // Lazy-load the sub-tab's first page if it's empty.
    final slot = state.slotFor(event.kind);
    if (slot.items.isEmpty && !slot.loading) {
      add(const UserMediaLoadRequested());
    }
  }

  Future<dynamic> _fetch({required MediaKind kind, required int page}) {
    if (kind == MediaKind.video) {
      return _repository.getUserVideos(username: username, page: page);
    }
    return _repository.getUserSplits(username: username, page: page);
  }
}
