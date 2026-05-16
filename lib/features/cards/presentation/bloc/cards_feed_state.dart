part of 'cards_feed_bloc.dart';

class CardsFeedState extends Equatable {
  const CardsFeedState({
    this.loading = false,
    this.refreshing = false,
    this.loadingMore = false,
    this.cards = const [],
    this.page = 1,
    this.hasMore = false,
    this.typeFilter = CardFeedTypeFilter.all,
    this.errors = const [],
  });

  final bool loading;
  final bool refreshing;
  final bool loadingMore;
  final List<TradingCard> cards;
  final int page;
  final bool hasMore;
  final CardFeedTypeFilter typeFilter;
  final List<String> errors;

  /// Cards in the active filter slice. Backend doesn't paginate by
  /// type so we filter client-side — switching is free.
  List<TradingCard> get filteredCards {
    if (typeFilter == CardFeedTypeFilter.all) return cards;
    final target =
        typeFilter == CardFeedTypeFilter.modern ? 'modern' : 'legacy';
    return cards
        .where((c) => c.cardType.toLowerCase() == target)
        .toList(growable: false);
  }

  CardsFeedState copyWith({
    bool? loading,
    bool? refreshing,
    bool? loadingMore,
    List<TradingCard>? cards,
    int? page,
    bool? hasMore,
    CardFeedTypeFilter? typeFilter,
    List<String>? errors,
  }) {
    return CardsFeedState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      loadingMore: loadingMore ?? this.loadingMore,
      cards: cards ?? this.cards,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      typeFilter: typeFilter ?? this.typeFilter,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        refreshing,
        loadingMore,
        cards,
        page,
        hasMore,
        typeFilter,
        errors,
      ];
}
