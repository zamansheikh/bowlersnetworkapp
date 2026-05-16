import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/trading_card.dart';
import '../../domain/repositories/cards_repository.dart';

part 'cards_feed_event.dart';
part 'cards_feed_state.dart';

/// Drives /cards — global cards feed across every user. Like + collect
/// toggles mutate the matching card in place; the All / Modern /
/// Legacy filter is applied client-side over the loaded list so
/// switching is free.
@injectable
class CardsFeedBloc extends Bloc<CardsFeedEvent, CardsFeedState> {
  CardsFeedBloc(this._repository) : super(const CardsFeedState()) {
    on<CardsFeedLoadRequested>(_onLoad);
    on<CardsFeedRefreshRequested>(_onRefresh);
    on<CardsFeedNextPageRequested>(_onNextPage);
    on<CardsFeedFilterChanged>(_onFilterChanged);
    on<CardsFeedLikeToggled>(_onLike);
    on<CardsFeedCollectToggled>(_onCollect);
  }

  final CardsRepository _repository;

  Future<void> _onLoad(
    CardsFeedLoadRequested event,
    Emitter<CardsFeedState> emit,
  ) async {
    if (state.cards.isNotEmpty && !event.force) return;
    emit(state.copyWith(loading: true, errors: const []));
    final res = await _repository.getCardsFeed(page: 1);
    res.fold(
      (f) => emit(state.copyWith(loading: false, errors: f.messages)),
      (page) => emit(state.copyWith(
        loading: false,
        cards: page.cards,
        page: 1,
        hasMore: page.hasMore,
      )),
    );
  }

  Future<void> _onRefresh(
    CardsFeedRefreshRequested event,
    Emitter<CardsFeedState> emit,
  ) async {
    emit(state.copyWith(refreshing: true, errors: const []));
    final res = await _repository.getCardsFeed(page: 1);
    res.fold(
      (f) => emit(state.copyWith(refreshing: false, errors: f.messages)),
      (page) => emit(state.copyWith(
        refreshing: false,
        cards: page.cards,
        page: 1,
        hasMore: page.hasMore,
      )),
    );
  }

  Future<void> _onNextPage(
    CardsFeedNextPageRequested event,
    Emitter<CardsFeedState> emit,
  ) async {
    if (state.loadingMore || !state.hasMore || state.loading) return;
    emit(state.copyWith(loadingMore: true));
    final next = state.page + 1;
    final res = await _repository.getCardsFeed(page: next);
    res.fold(
      (f) => emit(state.copyWith(loadingMore: false, errors: f.messages)),
      (page) => emit(state.copyWith(
        loadingMore: false,
        cards: [...state.cards, ...page.cards],
        page: next,
        hasMore: page.hasMore,
      )),
    );
  }

  void _onFilterChanged(
    CardsFeedFilterChanged event,
    Emitter<CardsFeedState> emit,
  ) {
    if (event.filter == state.typeFilter) return;
    emit(state.copyWith(typeFilter: event.filter));
  }

  Future<void> _onLike(
    CardsFeedLikeToggled event,
    Emitter<CardsFeedState> emit,
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
    CardsFeedCollectToggled event,
    Emitter<CardsFeedState> emit,
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

  void _mutate(
    Emitter<CardsFeedState> emit,
    int cardId,
    TradingCard Function(TradingCard) transform,
  ) {
    final idx = state.cards.indexWhere((c) => c.id == cardId);
    if (idx == -1) return;
    final next = List<TradingCard>.from(state.cards);
    next[idx] = transform(state.cards[idx]);
    emit(state.copyWith(cards: next));
  }
}
