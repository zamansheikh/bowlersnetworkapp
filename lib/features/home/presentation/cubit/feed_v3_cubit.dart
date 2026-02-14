import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/feed_v3_post.dart';
import '../../data/repositories/feed_v3_repository.dart';

// ─── States ──────────────────────────────────────────────────────────────────

abstract class FeedV3State extends Equatable {
  const FeedV3State();
  @override
  List<Object?> get props => [];
}

class FeedV3Initial extends FeedV3State {}

class FeedV3Loading extends FeedV3State {}

class FeedV3Loaded extends FeedV3State {
  final List<FeedV3Post> posts;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;

  const FeedV3Loaded({
    required this.posts,
    this.hasMore = true,
    this.currentPage = 1,
    this.isLoadingMore = false,
  });

  FeedV3Loaded copyWith({
    List<FeedV3Post>? posts,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return FeedV3Loaded(
      posts: posts ?? this.posts,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [posts, hasMore, currentPage, isLoadingMore];
}

class FeedV3Error extends FeedV3State {
  final String message;
  const FeedV3Error(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

@injectable
class FeedV3Cubit extends Cubit<FeedV3State> {
  final FeedV3Repository _repository;

  FeedV3Cubit(this._repository) : super(FeedV3Initial());

  /// Initial load
  Future<void> loadFeed() async {
    emit(FeedV3Loading());
    try {
      final response = await _repository.getFeed(page: 1, pageSize: 20);
      emit(
        FeedV3Loaded(
          posts: response.results,
          hasMore: response.hasMore,
          currentPage: 1,
        ),
      );
    } catch (e) {
      emit(FeedV3Error(e.toString()));
    }
  }

  /// Load more (pagination)
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! FeedV3Loaded ||
        !currentState.hasMore ||
        currentState.isLoadingMore)
      return;

    emit(currentState.copyWith(isLoadingMore: true));
    try {
      final nextPage = currentState.currentPage + 1;
      final response = await _repository.getFeed(page: nextPage, pageSize: 20);
      emit(
        FeedV3Loaded(
          posts: [...currentState.posts, ...response.results],
          hasMore: response.hasMore,
          currentPage: nextPage,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  /// Pull to refresh
  Future<void> refresh() async {
    try {
      final response = await _repository.getFeed(page: 1, pageSize: 20);
      emit(
        FeedV3Loaded(
          posts: response.results,
          hasMore: response.hasMore,
          currentPage: 1,
        ),
      );
    } catch (e) {
      // Keep existing state on refresh failure
    }
  }

  /// Toggle like on a post
  Future<void> toggleLike(int postId) async {
    final currentState = state;
    if (currentState is! FeedV3Loaded) return;

    // Optimistic update
    final updatedPosts = currentState.posts.map((post) {
      if (post.id == postId) {
        final newHasLiked = !post.hasLiked;
        return post.copyWith(
          hasLiked: newHasLiked,
          likesCount: post.likesCount + (newHasLiked ? 1 : -1),
        );
      }
      return post;
    }).toList();

    emit(currentState.copyWith(posts: updatedPosts));

    try {
      await _repository.toggleLike(postId);
    } catch (e) {
      // Revert on failure
      emit(currentState);
    }
  }

  /// Vote on a poll
  Future<void> voteOnPoll(int postId, List<int> optionIds) async {
    final currentState = state;
    if (currentState is! FeedV3Loaded) return;

    try {
      final responseData = await _repository.vote(postId, optionIds);
      // Re-fetch post to get updated poll data
      final updatedPost = await _repository.getPost(postId);

      final updatedPosts = currentState.posts.map((post) {
        if (post.id == postId) return updatedPost;
        return post;
      }).toList();

      emit(currentState.copyWith(posts: updatedPosts));
    } catch (e) {
      // ignore vote errors
    }
  }

  /// Unvote on a poll
  Future<void> unvote(int postId) async {
    final currentState = state;
    if (currentState is! FeedV3Loaded) return;

    try {
      await _repository.unvote(postId);
      // Re-fetch post to get updated poll data
      final updatedPost = await _repository.getPost(postId);

      final updatedPosts = currentState.posts.map((post) {
        if (post.id == postId) return updatedPost;
        return post;
      }).toList();

      emit(currentState.copyWith(posts: updatedPosts));
    } catch (e) {
      // ignore unvote errors
    }
  }

  /// Refresh a single post in the list (e.g., after commenting)
  Future<void> refreshPost(int postId) async {
    final currentState = state;
    if (currentState is! FeedV3Loaded) return;

    try {
      final updatedPost = await _repository.getPost(postId);
      final updatedPosts = currentState.posts.map((post) {
        if (post.id == postId) return updatedPost;
        return post;
      }).toList();
      emit(currentState.copyWith(posts: updatedPosts));
    } catch (e) {
      // ignore refresh errors
    }
  }
}
