part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => const [];
}

/// User typed (after widget-level debounce). Empty / <2-char strings are
/// treated as "clear" by the bloc.
class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

/// Reset state — fires when the user taps the X in the search field or
/// leaves the screen.
class SearchCleared extends SearchEvent {
  const SearchCleared();
}
