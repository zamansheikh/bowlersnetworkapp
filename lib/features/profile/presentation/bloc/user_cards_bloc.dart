import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cards/domain/entities/trading_card.dart';
import '../../../cards/domain/repositories/cards_repository.dart';

part 'user_cards_event.dart';
part 'user_cards_state.dart';

/// Drives the Cards tab on a profile screen. For self profiles the
/// "Owned" slot uses `/api/cards/my` and the "Collected" slot uses
/// `/api/cards/collections`; for other-user profiles only the "Owned"
/// slot is populated via `/api/cards/user/{id}` (the collections
/// endpoint is self-only).
class UserCardsBloc extends Bloc<UserCardsEvent, UserCardsState> {
  UserCardsBloc({
    required CardsRepository repository,
    required this.isSelf,
    required this.userId,
  })  : _repository = repository,
        super(const UserCardsState()) {
    on<UserCardsSubTabChanged>(_onSubTabChanged);
    on<UserCardsLoadRequested>(_onLoad);
    on<UserCardsRefreshRequested>(_onRefresh);
    on<UserCardsNextPageRequested>(_onNextPage);
    on<UserCardsLikeToggled>(_onLike);
    on<UserCardsCollectToggled>(_onCollect);
    on<UserCardsFilterChanged>(_onFilterChanged);
  }

  void _onFilterChanged(
    UserCardsFilterChanged event,
    Emitter<UserCardsState> emit,
  ) {
    if (event.filter == state.typeFilter) return;
    emit(state.copyWith(typeFilter: event.filter));
  }

  final CardsRepository _repository;

  /// True when showing the logged-in user's own cards (enables the
  /// Collections sub-tab + uses the `/my` endpoint).
  final bool isSelf;
  final int userId;

  Future<void> _onLoad(
    UserCardsLoadRequested event,
    Emitter<UserCardsState> emit,
  ) async {
    final tab = state.activeTab;
    final slot = state.slotFor(tab);
    if (slot.items.isNotEmpty && !event.force) return;
    emit(state.copyWithSlot(
      tab,
      slot.copyWith(loading: true, errors: const []),
    ));
    final res = await _fetch(tab: tab, page: 1);
    res.fold(
      // Silent fallback to empty — same pattern web uses for media tabs.
      // A 500 on a still-stabilising endpoint shouldn't cover the
      // profile in a red error banner.
      (_) => emit(state.copyWithSlot(
        tab,
        slot.copyWith(loading: false, items: const [], hasMore: false),
      )),
      (page) => emit(state.copyWithSlot(
        tab,
        slot.copyWith(
          loading: false,
          items: page.cards,
          page: 1,
          hasMore: page.hasMore,
        ),
      )),
    );
  }

  Future<void> _onRefresh(
    UserCardsRefreshRequested event,
    Emitter<UserCardsState> emit,
  ) async {
    final tab = state.activeTab;
    final slot = state.slotFor(tab);
    emit(state.copyWithSlot(
      tab,
      slot.copyWith(refreshing: true, errors: const []),
    ));
    final res = await _fetch(tab: tab, page: 1);
    res.fold(
      (_) => emit(state.copyWithSlot(
        tab,
        slot.copyWith(refreshing: false),
      )),
      (page) => emit(state.copyWithSlot(
        tab,
        slot.copyWith(
          refreshing: false,
          items: page.cards,
          page: 1,
          hasMore: page.hasMore,
        ),
      )),
    );
  }

  Future<void> _onNextPage(
    UserCardsNextPageRequested event,
    Emitter<UserCardsState> emit,
  ) async {
    final tab = state.activeTab;
    final slot = state.slotFor(tab);
    if (slot.loadingMore || !slot.hasMore || slot.loading) return;
    emit(state.copyWithSlot(tab, slot.copyWith(loadingMore: true)));
    final next = slot.page + 1;
    final res = await _fetch(tab: tab, page: next);
    res.fold(
      // Silent — stop trying to paginate but don't disturb the user.
      (_) => emit(state.copyWithSlot(
        tab,
        slot.copyWith(loadingMore: false, hasMore: false),
      )),
      (page) {
        final cur = state.slotFor(tab);
        emit(state.copyWithSlot(
          tab,
          cur.copyWith(
            loadingMore: false,
            items: [...cur.items, ...page.cards],
            page: next,
            hasMore: page.hasMore,
          ),
        ));
      },
    );
  }

  void _onSubTabChanged(
    UserCardsSubTabChanged event,
    Emitter<UserCardsState> emit,
  ) {
    if (event.tab == state.activeTab) return;
    // Collections is self-only — silently ignore the request for others.
    if (event.tab == CardsSubTab.collections && !isSelf) return;
    emit(state.copyWith(activeTab: event.tab));
    final slot = state.slotFor(event.tab);
    if (slot.items.isEmpty && !slot.loading) {
      add(const UserCardsLoadRequested());
    }
  }

  Future<void> _onLike(
    UserCardsLikeToggled event,
    Emitter<UserCardsState> emit,
  ) async {
    final res = await _repository.toggleLike(event.cardId);
    res.fold(
      (_) {/* silent */},
      (result) => _mutate(emit, event.cardId, (c) {
        return c.withLike(
          isLiked: result.isLiked,
          likesCount: result.likesCount,
        );
      }),
    );
  }

  Future<void> _onCollect(
    UserCardsCollectToggled event,
    Emitter<UserCardsState> emit,
  ) async {
    final res = await _repository.toggleCollect(event.cardId);
    res.fold(
      (_) {},
      (result) => _mutate(emit, event.cardId, (c) {
        return c.withCollect(
          isCollected: result.isCollected,
          collectionsCount: result.collectionsCount,
        );
      }),
    );
  }

  /// Walks both slots and replaces any matching card so a like/collect
  /// toggle mutates the card wherever it appears.
  void _mutate(
    Emitter<UserCardsState> emit,
    int cardId,
    TradingCard Function(TradingCard) transform,
  ) {
    UserCardsState next = state;
    for (final tab in CardsSubTab.values) {
      final slot = next.slotFor(tab);
      final idx = slot.items.indexWhere((c) => c.id == cardId);
      if (idx == -1) continue;
      final updated = List<TradingCard>.from(slot.items);
      updated[idx] = transform(slot.items[idx]);
      next = next.copyWithSlot(tab, slot.copyWith(items: updated));
    }
    if (next != state) emit(next);
  }

  Future<dynamic> _fetch({required CardsSubTab tab, required int page}) {
    switch (tab) {
      case CardsSubTab.owned:
        if (isSelf) return _repository.getMyCards(page: page);
        return _repository.getUserCards(userId: userId, page: page);
      case CardsSubTab.collections:
        return _repository.getMyCollections(page: page);
    }
  }
}
