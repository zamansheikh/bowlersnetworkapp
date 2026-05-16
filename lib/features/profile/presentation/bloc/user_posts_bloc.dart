import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../newsfeed/domain/entities/post.dart';
import '../../../newsfeed/domain/repositories/newsfeed_repository.dart';

part 'user_posts_event.dart';
part 'user_posts_state.dart';

/// Drives the Posts tab on a profile screen. Per-screen instance — the
/// userId (or `isSelf`) is locked at construction so callers pick the
/// right endpoint (`/api/newsfeed/my-posts` vs `/users/{id}/posts`).
///
/// Reactions and saves mutate the post in place to avoid full-list
/// rebuilds (matches the main FeedBloc's behaviour).
class UserPostsBloc extends Bloc<UserPostsEvent, UserPostsState> {
  UserPostsBloc({
    required NewsfeedRepository repository,
    required this.isSelf,
    required this.userId,
  })  : _repository = repository,
        super(const UserPostsState()) {
    on<UserPostsLoadRequested>(_onLoad);
    on<UserPostsRefreshRequested>(_onRefresh);
    on<UserPostsNextPageRequested>(_onNextPage);
    on<UserPostsReactionToggled>(_onReact);
    on<UserPostsSaveToggled>(_onSave);
  }

  final NewsfeedRepository _repository;

  /// `true` when showing the logged-in user's own posts (hits
  /// `/api/newsfeed/my-posts`). `false` falls back to the user-scoped
  /// endpoint with [userId].
  final bool isSelf;

  /// Always required; ignored when [isSelf] is true.
  final int userId;

  Future<void> _onLoad(
    UserPostsLoadRequested event,
    Emitter<UserPostsState> emit,
  ) async {
    if (state.posts.isNotEmpty && !event.force) return;
    emit(state.copyWith(loading: true, errors: const []));
    final res = await _fetch(page: 1);
    res.fold(
      (f) => emit(state.copyWith(loading: false, errors: f.messages)),
      (page) => emit(state.copyWith(
        loading: false,
        posts: page.posts,
        page: 1,
        hasMore: page.hasMore,
      )),
    );
  }

  Future<void> _onRefresh(
    UserPostsRefreshRequested event,
    Emitter<UserPostsState> emit,
  ) async {
    emit(state.copyWith(refreshing: true, errors: const []));
    final res = await _fetch(page: 1);
    res.fold(
      (f) => emit(state.copyWith(refreshing: false, errors: f.messages)),
      (page) => emit(state.copyWith(
        refreshing: false,
        posts: page.posts,
        page: 1,
        hasMore: page.hasMore,
      )),
    );
  }

  Future<void> _onNextPage(
    UserPostsNextPageRequested event,
    Emitter<UserPostsState> emit,
  ) async {
    if (state.loadingMore || !state.hasMore || state.loading) return;
    emit(state.copyWith(loadingMore: true));
    final next = state.page + 1;
    final res = await _fetch(page: next);
    res.fold(
      (f) => emit(state.copyWith(loadingMore: false, errors: f.messages)),
      (page) => emit(state.copyWith(
        loadingMore: false,
        posts: [...state.posts, ...page.posts],
        page: next,
        hasMore: page.hasMore,
      )),
    );
  }

  Future<void> _onReact(
    UserPostsReactionToggled event,
    Emitter<UserPostsState> emit,
  ) async {
    final res = await _repository.react(event.postUid, event.reaction);
    res.fold(
      (_) {/* silent — toast is the screen's job if needed */},
      (newReaction) => _mutate(emit, event.postUid, (p) {
        return p.copyWith(
          hasReacted: newReaction != null,
          reaction: newReaction,
          clearReaction: newReaction == null,
        );
      }),
    );
  }

  Future<void> _onSave(
    UserPostsSaveToggled event,
    Emitter<UserPostsState> emit,
  ) async {
    final res = await _repository.toggleSave(event.postUid);
    res.fold(
      (_) {},
      (saved) => _mutate(emit, event.postUid, (p) {
        final delta = saved == (p.hasSaved) ? 0 : (saved ? 1 : -1);
        return p.copyWith(
          hasSaved: saved,
          savesCount: (p.savesCount + delta).clamp(0, 1 << 31),
        );
      }),
    );
  }

  void _mutate(
    Emitter<UserPostsState> emit,
    String uid,
    Post Function(Post) transform,
  ) {
    final idx = state.posts.indexWhere((p) => p.uid == uid);
    if (idx == -1) return;
    final next = List<Post>.from(state.posts);
    next[idx] = transform(state.posts[idx]);
    emit(state.copyWith(posts: next));
  }

  Future<dynamic> _fetch({required int page}) {
    if (isSelf) {
      return _repository.getMyPosts(page: page);
    }
    return _repository.getUserPosts(userId: userId, page: page);
  }
}
