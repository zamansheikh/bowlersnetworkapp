part of 'chatter_list_bloc.dart';

sealed class ChatterListEvent extends Equatable {
  const ChatterListEvent();
  @override
  List<Object?> get props => const [];
}

/// Initial load — pulls topics and the first page of discussions. No-op
/// if already loaded unless [force] is true (used by pull-to-refresh
/// elsewhere).
class ChatterListLoadRequested extends ChatterListEvent {
  const ChatterListLoadRequested({this.force = false});
  final bool force;
  @override
  List<Object?> get props => [force];
}

/// Pull-to-refresh: keeps the current filter/sort and re-fetches page 1.
class ChatterListRefreshRequested extends ChatterListEvent {
  const ChatterListRefreshRequested();
}

/// User tapped a topic chip. `null` clears the filter ("All").
class ChatterListTopicChanged extends ChatterListEvent {
  const ChatterListTopicChanged(this.topicId);
  final int? topicId;
  @override
  List<Object?> get props => [topicId];
}

/// User picked a new sort tab (Recent / Most read / Most discussed /
/// Unanswered).
class ChatterListSortChanged extends ChatterListEvent {
  const ChatterListSortChanged(this.sort);
  final DiscussionSort sort;
  @override
  List<Object?> get props => [sort];
}

/// Scroll listener fired when we're near the end of the list and there's
/// another page available.
class ChatterListNextPageRequested extends ChatterListEvent {
  const ChatterListNextPageRequested();
}
