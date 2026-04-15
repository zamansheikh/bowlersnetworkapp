part of 'feed_bloc.dart';

class FeedState extends Equatable {
  const FeedState({
    this.posts = const [],
    this.nextCursor,
    this.loading = false,
    this.refreshing = false,
    this.loadingMore = false,
    this.errors = const [],
    this.filter,
  });

  final List<Post> posts;
  final int? nextCursor;
  final bool loading;
  final bool refreshing;
  final bool loadingMore;
  final List<String> errors;

  /// `null | following | scores | polls`.
  final String? filter;

  bool get hasMore => nextCursor != null;

  FeedState copyWith({
    List<Post>? posts,
    int? nextCursor,
    bool? loading,
    bool? refreshing,
    bool? loadingMore,
    List<String>? errors,
    String? filter,
    bool clearFilter = false,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      nextCursor: nextCursor,
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      loadingMore: loadingMore ?? this.loadingMore,
      errors: errors ?? this.errors,
      filter: clearFilter ? null : (filter ?? this.filter),
    );
  }

  @override
  List<Object?> get props => [
        posts,
        nextCursor,
        loading,
        refreshing,
        loadingMore,
        errors,
        filter,
      ];
}
