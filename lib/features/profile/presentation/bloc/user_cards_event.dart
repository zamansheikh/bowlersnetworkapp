part of 'user_cards_bloc.dart';

/// Sub-tab selector. Other-user profiles only show `owned`.
enum CardsSubTab { owned, collections }

/// Mirrors the web's All / Modern / Legacy filter rail. Applied
/// client-side over the loaded list — the server doesn't filter on
/// `card_type` for the user-cards endpoints.
enum CardTypeFilter {
  all('All'),
  modern('Modern'),
  legacy('Legacy');

  const CardTypeFilter(this.label);
  final String label;
}

sealed class UserCardsEvent extends Equatable {
  const UserCardsEvent();
  @override
  List<Object?> get props => const [];
}

class UserCardsLoadRequested extends UserCardsEvent {
  const UserCardsLoadRequested({this.force = false});
  final bool force;
  @override
  List<Object?> get props => [force];
}

class UserCardsRefreshRequested extends UserCardsEvent {
  const UserCardsRefreshRequested();
}

class UserCardsNextPageRequested extends UserCardsEvent {
  const UserCardsNextPageRequested();
}

class UserCardsSubTabChanged extends UserCardsEvent {
  const UserCardsSubTabChanged(this.tab);
  final CardsSubTab tab;
  @override
  List<Object?> get props => [tab];
}

class UserCardsLikeToggled extends UserCardsEvent {
  const UserCardsLikeToggled(this.cardId);
  final int cardId;
  @override
  List<Object?> get props => [cardId];
}

class UserCardsCollectToggled extends UserCardsEvent {
  const UserCardsCollectToggled(this.cardId);
  final int cardId;
  @override
  List<Object?> get props => [cardId];
}

/// Switches the client-side `card_type` filter. No re-fetch — items
/// already loaded are filtered in place.
class UserCardsFilterChanged extends UserCardsEvent {
  const UserCardsFilterChanged(this.filter);
  final CardTypeFilter filter;
  @override
  List<Object?> get props => [filter];
}
