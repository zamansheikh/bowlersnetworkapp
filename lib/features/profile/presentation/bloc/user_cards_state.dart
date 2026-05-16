part of 'user_cards_bloc.dart';

class CardsSlot extends Equatable {
  const CardsSlot({
    this.items = const [],
    this.loading = false,
    this.refreshing = false,
    this.loadingMore = false,
    this.page = 1,
    this.hasMore = false,
    this.errors = const [],
  });

  final List<TradingCard> items;
  final bool loading;
  final bool refreshing;
  final bool loadingMore;
  final int page;
  final bool hasMore;
  final List<String> errors;

  CardsSlot copyWith({
    List<TradingCard>? items,
    bool? loading,
    bool? refreshing,
    bool? loadingMore,
    int? page,
    bool? hasMore,
    List<String>? errors,
  }) {
    return CardsSlot(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      loadingMore: loadingMore ?? this.loadingMore,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props =>
      [items, loading, refreshing, loadingMore, page, hasMore, errors];
}

class UserCardsState extends Equatable {
  const UserCardsState({
    this.activeTab = CardsSubTab.owned,
    this.owned = const CardsSlot(),
    this.collections = const CardsSlot(),
  });

  final CardsSubTab activeTab;
  final CardsSlot owned;
  final CardsSlot collections;

  CardsSlot slotFor(CardsSubTab tab) =>
      tab == CardsSubTab.owned ? owned : collections;

  CardsSlot get activeSlot => slotFor(activeTab);

  UserCardsState copyWith({
    CardsSubTab? activeTab,
    CardsSlot? owned,
    CardsSlot? collections,
  }) {
    return UserCardsState(
      activeTab: activeTab ?? this.activeTab,
      owned: owned ?? this.owned,
      collections: collections ?? this.collections,
    );
  }

  UserCardsState copyWithSlot(CardsSubTab tab, CardsSlot slot) =>
      tab == CardsSubTab.owned
          ? copyWith(owned: slot)
          : copyWith(collections: slot);

  @override
  List<Object?> get props => [activeTab, owned, collections];
}
