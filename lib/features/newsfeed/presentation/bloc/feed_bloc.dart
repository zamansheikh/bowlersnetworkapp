import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../follow/domain/repositories/follow_repository.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/newsfeed_repository.dart';
import '../../domain/usecases/feed_usecases.dart';

part 'feed_event.dart';
part 'feed_state.dart';

/// Drives the main newsfeed screen. Holds the accumulated list of posts,
/// cursor, and inline action state (reacting, saving). Reaction & save
/// updates mutate the post in place so the UI doesn't flash.
@injectable
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc(
    this._getFeed,
    this._react,
    this._toggleSave,
    this._hide,
    this._share,
    this._repository,
    this._follow,
  ) : super(const FeedState()) {
    on<FeedLoadRequested>(_onLoad);
    on<FeedRefreshRequested>(_onRefresh);
    on<FeedNextPageRequested>(_onNextPage);
    on<FeedReactionToggled>(_onReact);
    on<FeedSaveToggled>(_onSave);
    on<FeedPostHidden>(_onHide);
    on<FeedFilterChanged>(_onFilterChanged);
    on<FeedPostCreated>(_onPostCreated);
    on<FeedShareRequested>(_onShare);
    on<FeedPinToggled>(_onPinToggled);
    on<FeedCommentsToggled>(_onCommentsToggled);
    on<FeedFollowToggled>(_onFollowToggled);
  }

  final GetFeedUseCase _getFeed;
  final ReactToPostUseCase _react;
  final ToggleSavePostUseCase _toggleSave;
  final HidePostUseCase _hide;
  final SharePostUseCase _share;
  final NewsfeedRepository _repository;
  final FollowRepository _follow;

  Future<void> _onLoad(
    FeedLoadRequested event,
    Emitter<FeedState> emit,
  ) async {
    if (state.posts.isNotEmpty) return; // lazy: only first load
    emit(state.copyWith(loading: true, errors: const []));
    final res = await _getFeed(GetFeedParams(filter: state.filter));
    _emitPage(res, emit, replace: true, loading: false);
  }

  Future<void> _onRefresh(
    FeedRefreshRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(refreshing: true, errors: const []));
    final res = await _getFeed(GetFeedParams(filter: state.filter));
    _emitPage(res, emit, replace: true, refreshing: false);
  }

  Future<void> _onNextPage(
    FeedNextPageRequested event,
    Emitter<FeedState> emit,
  ) async {
    if (state.loadingMore || state.nextCursor == null) return;
    emit(state.copyWith(loadingMore: true));
    final res = await _getFeed(GetFeedParams(
      filter: state.filter,
      cursor: state.nextCursor,
    ));
    _emitPage(res, emit, replace: false, loadingMore: false);
  }

  void _emitPage(
    Either<Failure, FeedPage> result,
    Emitter<FeedState> emit, {
    required bool replace,
    bool? loading,
    bool? refreshing,
    bool? loadingMore,
  }) {
    result.fold(
      (f) => emit(state.copyWith(
        loading: loading ?? state.loading,
        refreshing: refreshing ?? state.refreshing,
        loadingMore: loadingMore ?? state.loadingMore,
        errors: f.messages,
      )),
      (page) => emit(state.copyWith(
        loading: loading ?? state.loading,
        refreshing: refreshing ?? state.refreshing,
        loadingMore: loadingMore ?? state.loadingMore,
        posts: replace ? page.posts : [...state.posts, ...page.posts],
        nextCursor: page.nextCursor,
        errors: const [],
      )),
    );
  }

  Future<void> _onReact(
    FeedReactionToggled event,
    Emitter<FeedState> emit,
  ) async {
    final idx = state.posts.indexWhere((p) => p.uid == event.postUid);
    if (idx < 0) return;

    final original = state.posts[idx];

    // Optimistic: flip counts / reaction immediately.
    final currentReaction = original.reaction;
    final isSame = currentReaction == event.reaction;
    final optimistic = original.copyWith(
      reaction: isSame ? null : event.reaction,
      clearReaction: isSame,
      hasReacted: !isSame,
      likesCount: isSame
          ? (original.likesCount - 1).clamp(0, 1 << 30)
          : (original.hasReacted
              ? original.likesCount
              : original.likesCount + 1),
    );
    emit(state.copyWith(posts: _replace(idx, optimistic)));

    final res = await _react(
      ReactParams(postUid: event.postUid, reaction: event.reaction),
    );
    res.fold(
      (_) => emit(state.copyWith(posts: _replace(idx, original))), // rollback
      (newReaction) {
        // Server is authoritative for the reaction type; counts already reflect
        // the optimistic change, which matches server behaviour.
        final authoritative = optimistic.copyWith(
          reaction: newReaction,
          clearReaction: newReaction == null,
          hasReacted: newReaction != null,
        );
        emit(state.copyWith(posts: _replace(idx, authoritative)));
      },
    );
  }

  Future<void> _onSave(
    FeedSaveToggled event,
    Emitter<FeedState> emit,
  ) async {
    final idx = state.posts.indexWhere((p) => p.uid == event.postUid);
    if (idx < 0) return;
    final original = state.posts[idx];
    final optimistic = original.copyWith(
      hasSaved: !original.hasSaved,
      savesCount: original.hasSaved
          ? (original.savesCount - 1).clamp(0, 1 << 30)
          : original.savesCount + 1,
    );
    emit(state.copyWith(posts: _replace(idx, optimistic)));

    final res = await _toggleSave(event.postUid);
    res.fold(
      (_) => emit(state.copyWith(posts: _replace(idx, original))),
      (saved) => emit(state.copyWith(
        posts: _replace(
          idx,
          optimistic.copyWith(hasSaved: saved),
        ),
      )),
    );
  }

  Future<void> _onHide(
    FeedPostHidden event,
    Emitter<FeedState> emit,
  ) async {
    final filtered =
        state.posts.where((p) => p.uid != event.postUid).toList(growable: false);
    emit(state.copyWith(posts: filtered));
    await _hide(event.postUid);
  }

  void _onPostCreated(FeedPostCreated event, Emitter<FeedState> emit) {
    emit(state.copyWith(posts: [event.post, ...state.posts]));
  }

  Future<void> _onShare(
    FeedShareRequested event,
    Emitter<FeedState> emit,
  ) async {
    final idx = state.posts.indexWhere((p) => p.uid == event.postUid);
    final original = idx >= 0 ? state.posts[idx] : null;

    final res = await _share(event.postUid);
    res.fold(
      (f) => emit(state.copyWith(errors: f.messages)),
      (shared) {
        var posts = [shared, ...state.posts];
        if (original != null) {
          final bumpedIdx =
              posts.indexWhere((p) => p.uid == original.uid && p != shared);
          if (bumpedIdx >= 0) {
            posts = List<Post>.from(posts);
            posts[bumpedIdx] = original.copyWith(
              sharesCount: original.sharesCount + 1,
            );
          }
        }
        emit(state.copyWith(posts: posts));
      },
    );
  }

  void _onFilterChanged(
    FeedFilterChanged event,
    Emitter<FeedState> emit,
  ) {
    emit(state.copyWith(
      filter: event.filter,
      posts: const [],
      nextCursor: null,
      clearFilter: event.filter == null,
    ));
    add(const FeedLoadRequested());
  }

  Future<void> _onPinToggled(
    FeedPinToggled event,
    Emitter<FeedState> emit,
  ) async {
    final idx = state.posts.indexWhere((p) => p.uid == event.postUid);
    if (idx < 0) return;
    final original = state.posts[idx];
    // Optimistic flip.
    emit(state.copyWith(
      posts: _replace(idx, original.copyWith(isPinned: !original.isPinned)),
    ));
    final res = await _repository.togglePin(event.postUid);
    res.fold(
      (f) => emit(state.copyWith(
        posts: _replace(idx, original),
        errors: f.messages,
      )),
      (pinned) => emit(state.copyWith(
        posts: _replace(idx, original.copyWith(isPinned: pinned)),
      )),
    );
  }

  Future<void> _onCommentsToggled(
    FeedCommentsToggled event,
    Emitter<FeedState> emit,
  ) async {
    final idx = state.posts.indexWhere((p) => p.uid == event.postUid);
    if (idx < 0) return;
    final original = state.posts[idx];
    emit(state.copyWith(
      posts: _replace(
        idx,
        original.copyWith(isCommentsEnabled: event.enabled),
      ),
    ));
    final res = await _repository.togglePostComments(
      event.postUid,
      enabled: event.enabled,
    );
    res.fold(
      (f) => emit(state.copyWith(
        posts: _replace(idx, original),
        errors: f.messages,
      )),
      (enabled) => emit(state.copyWith(
            posts: _replace(
              idx,
              original.copyWith(isCommentsEnabled: enabled),
            ),
          )),
    );
  }

  Future<void> _onFollowToggled(
    FeedFollowToggled event,
    Emitter<FeedState> emit,
  ) async {
    final affected = state.posts
        .where((p) => p.author.id == event.authorId)
        .toList(growable: false);
    if (affected.isEmpty) return;
    final wasFollowing = affected.first.author.isFollowing;
    // Optimistic: flip every post by this author.
    emit(state.copyWith(posts: _flipFollow(event.authorId, !wasFollowing)));

    final res = await _follow.toggleFollow(event.authorId);
    res.fold(
      (f) => emit(state.copyWith(
        posts: _flipFollow(event.authorId, wasFollowing),
        errors: f.messages,
      )),
      (result) => emit(state.copyWith(
        posts: _flipFollow(event.authorId, result.isFollowing),
      )),
    );
  }

  List<Post> _flipFollow(int authorId, bool isFollowing) {
    return [
      for (final p in state.posts)
        if (p.author.id == authorId)
          p.copyWith(author: p.author.copyWith(isFollowing: isFollowing))
        else
          p,
    ];
  }

  List<Post> _replace(int index, Post post) {
    final updated = List<Post>.from(state.posts);
    updated[index] = post;
    return updated;
  }
}
