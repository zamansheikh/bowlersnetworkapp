part of 'cards_feed_bloc.dart';

/// Mirrors the web's All / Modern / Legacy filter rail on /cards.
/// Applied client-side over the loaded list — the global feed
/// endpoint doesn't filter by `card_type`.
enum CardFeedTypeFilter {
  all('All'),
  modern('Modern'),
  legacy('Legacy');

  const CardFeedTypeFilter(this.label);
  final String label;
}

sealed class CardsFeedEvent extends Equatable {
  const CardsFeedEvent();
  @override
  List<Object?> get props => const [];
}

class CardsFeedLoadRequested extends CardsFeedEvent {
  const CardsFeedLoadRequested({this.force = false});
  final bool force;
  @override
  List<Object?> get props => [force];
}

class CardsFeedRefreshRequested extends CardsFeedEvent {
  const CardsFeedRefreshRequested();
}

class CardsFeedNextPageRequested extends CardsFeedEvent {
  const CardsFeedNextPageRequested();
}

class CardsFeedFilterChanged extends CardsFeedEvent {
  const CardsFeedFilterChanged(this.filter);
  final CardFeedTypeFilter filter;
  @override
  List<Object?> get props => [filter];
}

class CardsFeedLikeToggled extends CardsFeedEvent {
  const CardsFeedLikeToggled(this.cardId);
  final int cardId;
  @override
  List<Object?> get props => [cardId];
}

class CardsFeedCollectToggled extends CardsFeedEvent {
  const CardsFeedCollectToggled(this.cardId);
  final int cardId;
  @override
  List<Object?> get props => [cardId];
}
