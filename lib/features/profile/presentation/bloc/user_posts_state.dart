part of 'user_posts_bloc.dart';

class UserPostsState extends Equatable {
  const UserPostsState({
    this.loading = false,
    this.refreshing = false,
    this.loadingMore = false,
    this.posts = const [],
    this.page = 1,
    this.hasMore = false,
    this.errors = const [],
  });

  final bool loading;
  final bool refreshing;
  final bool loadingMore;
  final List<Post> posts;
  final int page;
  final bool hasMore;
  final List<String> errors;

  UserPostsState copyWith({
    bool? loading,
    bool? refreshing,
    bool? loadingMore,
    List<Post>? posts,
    int? page,
    bool? hasMore,
    List<String>? errors,
  }) {
    return UserPostsState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      loadingMore: loadingMore ?? this.loadingMore,
      posts: posts ?? this.posts,
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
        posts,
        page,
        hasMore,
        errors,
      ];
}
