part of 'chatter_list_bloc.dart';

class ChatterListState extends Equatable {
  const ChatterListState({
    this.loading = false,
    this.refreshing = false,
    this.loadingMore = false,
    this.topics = const [],
    this.discussions = const [],
    this.topicId,
    this.sort = DiscussionSort.recent,
    this.page = 1,
    this.hasMore = false,
    this.errors = const [],
  });

  /// True while the initial fetch is in flight (no prior results).
  final bool loading;

  /// True during a pull-to-refresh — UI keeps showing the existing list.
  final bool refreshing;

  /// True while the next page is being appended.
  final bool loadingMore;

  final List<Topic> topics;
  final List<Discussion> discussions;

  /// Active topic filter — `null` means "All topics".
  final int? topicId;

  final DiscussionSort sort;
  final int page;
  final bool hasMore;
  final List<String> errors;

  ChatterListState copyWith({
    bool? loading,
    bool? refreshing,
    bool? loadingMore,
    List<Topic>? topics,
    List<Discussion>? discussions,
    int? topicId,
    bool clearTopic = false,
    DiscussionSort? sort,
    int? page,
    bool? hasMore,
    List<String>? errors,
  }) {
    return ChatterListState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      loadingMore: loadingMore ?? this.loadingMore,
      topics: topics ?? this.topics,
      discussions: discussions ?? this.discussions,
      topicId: clearTopic ? null : (topicId ?? this.topicId),
      sort: sort ?? this.sort,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        refreshing,
        loadingMore,
        topics,
        discussions,
        topicId,
        sort,
        page,
        hasMore,
        errors,
      ];
}
