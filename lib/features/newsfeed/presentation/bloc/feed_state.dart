part of 'feed_bloc.dart';

enum FeedStatus { initial, loading, loaded, error }

class FeedState extends Equatable {
  final FeedStatus status;
  final List<PostModel> posts;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;
  final String? filter;

  const FeedState({
    this.status = FeedStatus.initial,
    this.posts = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.errorMessage,
    this.filter,
  });

  FeedState copyWith({
    FeedStatus? status,
    List<PostModel>? posts,
    bool? hasMore,
    bool? isLoadingMore,
    String? errorMessage,
    String? filter,
  }) {
    return FeedState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [status, posts, hasMore, isLoadingMore, errorMessage, filter];
}
