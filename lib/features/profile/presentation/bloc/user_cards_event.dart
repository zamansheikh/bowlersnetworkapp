part of 'user_cards_bloc.dart';

/// Sub-tab selector. Other-user profiles only show `owned`.
enum CardsSubTab { owned, collections }

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
