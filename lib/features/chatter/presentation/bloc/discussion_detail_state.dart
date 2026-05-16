part of 'discussion_detail_bloc.dart';

class DiscussionDetailState extends Equatable {
  const DiscussionDetailState({
    this.loading = false,
    this.refreshing = false,
    this.discussion,
    this.upvoteBusy = false,
    this.opinions = const [],
    this.opinionsLoading = false,
    this.opinionsLoadingMore = false,
    this.opinionSort = OpinionSort.top,
    this.opinionsPage = 1,
    this.opinionsHasMore = false,
    this.opinionUpvoteBusyIds = const {},
    this.posting = false,
    this.errors = const [],
  });

  /// True while the initial discussion fetch is in flight.
  final bool loading;

  /// True during pull-to-refresh (existing content stays on screen).
  final bool refreshing;

  final Discussion? discussion;

  /// True while a discussion-upvote toggle RPC is in flight.
  final bool upvoteBusy;

  final List<Opinion> opinions;
  final bool opinionsLoading;
  final bool opinionsLoadingMore;
  final OpinionSort opinionSort;
  final int opinionsPage;
  final bool opinionsHasMore;

  /// IDs of opinions whose upvote-toggle is currently in flight — used to
  /// disable the arrow per-row without blocking the rest of the list.
  final Set<int> opinionUpvoteBusyIds;

  /// True while the composer is submitting a new opinion.
  final bool posting;

  final List<String> errors;

  DiscussionDetailState copyWith({
    bool? loading,
    bool? refreshing,
    Discussion? discussion,
    bool? upvoteBusy,
    List<Opinion>? opinions,
    bool? opinionsLoading,
    bool? opinionsLoadingMore,
    OpinionSort? opinionSort,
    int? opinionsPage,
    bool? opinionsHasMore,
    Set<int>? opinionUpvoteBusyIds,
    bool? posting,
    List<String>? errors,
  }) {
    return DiscussionDetailState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      discussion: discussion ?? this.discussion,
      upvoteBusy: upvoteBusy ?? this.upvoteBusy,
      opinions: opinions ?? this.opinions,
      opinionsLoading: opinionsLoading ?? this.opinionsLoading,
      opinionsLoadingMore: opinionsLoadingMore ?? this.opinionsLoadingMore,
      opinionSort: opinionSort ?? this.opinionSort,
      opinionsPage: opinionsPage ?? this.opinionsPage,
      opinionsHasMore: opinionsHasMore ?? this.opinionsHasMore,
      opinionUpvoteBusyIds: opinionUpvoteBusyIds ?? this.opinionUpvoteBusyIds,
      posting: posting ?? this.posting,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        refreshing,
        discussion,
        upvoteBusy,
        opinions,
        opinionsLoading,
        opinionsLoadingMore,
        opinionSort,
        opinionsPage,
        opinionsHasMore,
        opinionUpvoteBusyIds,
        posting,
        errors,
      ];
}
