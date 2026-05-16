import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/media_item.dart';
import '../../domain/repositories/media_repository.dart';

part 'media_feed_event.dart';
part 'media_feed_state.dart';

/// Drives /media — global videos + splits feeds. Two slots, one per
/// kind, so switching between sub-tabs doesn't lose pagination state.
/// Errors silently fall back to empty (matches the web's MediaTab
/// pattern — a flaky media backend shouldn't redden the whole tab).
@injectable
class MediaFeedBloc extends Bloc<MediaFeedEvent, MediaFeedState> {
  MediaFeedBloc(this._repository) : super(const MediaFeedState()) {
    on<MediaFeedSubTabChanged>(_onSubTabChanged);
    on<MediaFeedLoadRequested>(_onLoad);
    on<MediaFeedRefreshRequested>(_onRefresh);
    on<MediaFeedNextPageRequested>(_onNextPage);
  }

  final MediaRepository _repository;

  Future<void> _onLoad(
    MediaFeedLoadRequested event,
    Emitter<MediaFeedState> emit,
  ) async {
    final kind = state.activeKind;
    final slot = state.slotFor(kind);
    if (slot.items.isNotEmpty && !event.force) return;
    emit(state.copyWithSlot(kind, slot.copyWith(loading: true)));
    final res = await _fetch(kind: kind, page: 1);
    res.fold(
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
    MediaFeedRefreshRequested event,
    Emitter<MediaFeedState> emit,
  ) async {
    final kind = state.activeKind;
    final slot = state.slotFor(kind);
    emit(state.copyWithSlot(kind, slot.copyWith(refreshing: true)));
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
    MediaFeedNextPageRequested event,
    Emitter<MediaFeedState> emit,
  ) async {
    final kind = state.activeKind;
    final slot = state.slotFor(kind);
    if (slot.loadingMore || !slot.hasMore || slot.loading) return;
    emit(state.copyWithSlot(kind, slot.copyWith(loadingMore: true)));
    final next = slot.page + 1;
    final res = await _fetch(kind: kind, page: next);
    res.fold(
      (_) => emit(state.copyWithSlot(
        kind,
        slot.copyWith(loadingMore: false, hasMore: false),
      )),
      (page) {
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
    MediaFeedSubTabChanged event,
    Emitter<MediaFeedState> emit,
  ) {
    if (event.kind == state.activeKind) return;
    emit(state.copyWith(activeKind: event.kind));
    final slot = state.slotFor(event.kind);
    if (slot.items.isEmpty && !slot.loading) {
      add(const MediaFeedLoadRequested());
    }
  }

  Future<dynamic> _fetch({required MediaKind kind, required int page}) {
    if (kind == MediaKind.video) {
      return _repository.getGlobalVideos(page: page);
    }
    return _repository.getGlobalSplits(page: page);
  }
}
