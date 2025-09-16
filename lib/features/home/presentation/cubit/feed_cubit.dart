import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'dart:io';
import '../../data/models/feed_post.dart';
import '../../data/repositories/feed_repository.dart';

// Events
abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class FeedLoadRequested extends FeedEvent {}

class FeedRefreshRequested extends FeedEvent {}

class PostCreated extends FeedEvent {
  final String caption;
  final List<File>? mediaFiles;
  final List<String>? tags;

  const PostCreated({required this.caption, this.mediaFiles, this.tags});

  @override
  List<Object?> get props => [caption, mediaFiles, tags];
}

class PollPostCreated extends FeedEvent {
  final String caption;
  final String pollTitle;
  final String pollType;
  final List<String> pollOptions;
  final List<String>? tags;

  const PollPostCreated({
    required this.caption,
    required this.pollTitle,
    required this.pollType,
    required this.pollOptions,
    this.tags,
  });

  @override
  List<Object?> get props => [caption, pollTitle, pollType, pollOptions, tags];
}

class PostLikeToggled extends FeedEvent {
  final int postId;
  final int postIndex;

  const PostLikeToggled({required this.postId, required this.postIndex});

  @override
  List<Object?> get props => [postId, postIndex];
}

class PollVoted extends FeedEvent {
  final int optionId;
  final int postIndex;

  const PollVoted({required this.optionId, required this.postIndex});

  @override
  List<Object?> get props => [optionId, postIndex];
}

class UserFollowed extends FeedEvent {
  final int userId;
  final int postIndex;

  const UserFollowed({required this.userId, required this.postIndex});

  @override
  List<Object?> get props => [userId, postIndex];
}

class CommentAdded extends FeedEvent {
  final int postId;
  final int postIndex;
  final String text;

  const CommentAdded({
    required this.postId,
    required this.postIndex,
    required this.text,
  });

  @override
  List<Object?> get props => [postId, postIndex, text];
}

// States
abstract class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object?> get props => [];
}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<FeedPost> posts;

  const FeedLoaded({required this.posts});

  @override
  List<Object?> get props => [posts];
}

class FeedError extends FeedState {
  final String message;

  const FeedError({required this.message});

  @override
  List<Object?> get props => [message];
}

class FeedRefreshing extends FeedState {
  final List<FeedPost> posts;

  const FeedRefreshing({required this.posts});

  @override
  List<Object?> get props => [posts];
}

class PostCreating extends FeedState {
  final List<FeedPost> posts;

  const PostCreating({required this.posts});

  @override
  List<Object?> get props => [posts];
}

class PostCreateSuccess extends FeedState {
  final List<FeedPost> posts;

  const PostCreateSuccess({required this.posts});

  @override
  List<Object?> get props => [posts];
}

class PostCreateError extends FeedState {
  final List<FeedPost> posts;
  final String message;

  const PostCreateError({required this.posts, required this.message});

  @override
  List<Object?> get props => [posts, message];
}

class PostDetailLoaded extends FeedState {
  final FeedPost post;

  const PostDetailLoaded({required this.post});

  @override
  List<Object?> get props => [post];
}

class CommentAddSuccess extends FeedState {
  final FeedPost post;

  const CommentAddSuccess({required this.post});

  @override
  List<Object?> get props => [post];
}

class CommentAddError extends FeedState {
  final String message;

  const CommentAddError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ReplyAddSuccess extends FeedState {
  final FeedPost post;

  const ReplyAddSuccess({required this.post});

  @override
  List<Object?> get props => [post];
}

class ReplyAddError extends FeedState {
  final String message;

  const ReplyAddError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Cubit
@injectable
class FeedCubit extends Cubit<FeedState> {
  final FeedRepository _repository;

  FeedCubit({required FeedRepository repository})
    : _repository = repository,
      super(FeedInitial());

  Future<void> loadFeed() async {
    emit(FeedLoading());
    try {
      final posts = await _repository.getFeed();
      emit(FeedLoaded(posts: posts));
    } catch (e) {
      emit(FeedError(message: e.toString()));
    }
  }

  Future<void> refreshFeed() async {
    if (state is FeedLoaded) {
      final currentPosts = (state as FeedLoaded).posts;
      emit(FeedRefreshing(posts: currentPosts));
    }

    try {
      final posts = await _repository.getFeed();
      emit(FeedLoaded(posts: posts));
    } catch (e) {
      if (state is FeedRefreshing) {
        final currentPosts = (state as FeedRefreshing).posts;
        emit(FeedLoaded(posts: currentPosts));
      }
      // Show error but don't change state to error for refresh
    }
  }

  Future<void> createPost({
    required String caption,
    List<File>? mediaFiles,
    List<String>? tags,
  }) async {
    final currentState = state;
    List<FeedPost> currentPosts = [];

    if (currentState is FeedLoaded) {
      currentPosts = currentState.posts;
      emit(PostCreating(posts: currentPosts));
    }

    try {
      await _repository.createPost(
        caption: caption,
        mediaFiles: mediaFiles,
        tags: tags,
      );

      // Refresh feed to get the new post
      await refreshFeed();
      emit(PostCreateSuccess(posts: (state as FeedLoaded).posts));
    } catch (e) {
      emit(PostCreateError(posts: currentPosts, message: e.toString()));
    }
  }

  Future<void> createPollPost({
    required String caption,
    required String pollTitle,
    required String pollType,
    required List<String> pollOptions,
    List<String>? tags,
  }) async {
    final currentState = state;
    List<FeedPost> currentPosts = [];

    if (currentState is FeedLoaded) {
      currentPosts = currentState.posts;
      emit(PostCreating(posts: currentPosts));
    }

    try {
      await _repository.createPollPost(
        caption: caption,
        pollTitle: pollTitle,
        pollType: pollType,
        pollOptions: pollOptions,
        tags: tags,
      );

      // Refresh feed to get the new post
      await refreshFeed();
      emit(PostCreateSuccess(posts: (state as FeedLoaded).posts));
    } catch (e) {
      emit(PostCreateError(posts: currentPosts, message: e.toString()));
    }
  }

  Future<void> toggleLike(int postId, int postIndex) async {
    final currentState = state;
    if (currentState is! FeedLoaded) return;

    final posts = List<FeedPost>.from(currentState.posts);
    if (postIndex >= posts.length) return;

    final post = posts[postIndex];

    // Optimistic update
    final newLikedState = !post.isLikedByMe;
    final newLikesCount = newLikedState
        ? post.metadata.totalLikes + 1
        : post.metadata.totalLikes - 1;

    final updatedPost = post.copyWith(
      isLikedByMe: newLikedState,
      metadata: post.metadata.copyWith(totalLikes: newLikesCount),
    );

    posts[postIndex] = updatedPost;
    emit(FeedLoaded(posts: posts));

    try {
      await _repository.toggleLike(postId);
    } catch (e) {
      // Revert optimistic update
      posts[postIndex] = post;
      emit(FeedLoaded(posts: posts));
    }
  }

  Future<void> voteOnPoll(int optionId, int postIndex) async {
    final currentState = state;
    if (currentState is! FeedLoaded) return;

    final posts = List<FeedPost>.from(currentState.posts);
    if (postIndex >= posts.length || posts[postIndex].poll == null) return;

    final post = posts[postIndex];
    final poll = post.poll!;

    // Optimistic update - add vote to the selected option
    final currentTotalVotes = poll.options.fold(
      0,
      (sum, option) => sum + option.vote,
    );
    final newTotalVotes = currentTotalVotes + 1;

    final updatedOptions = poll.options.map((option) {
      if (option.optionId == optionId) {
        return option.copyWith(
          vote: option.vote + 1,
          perc: ((option.vote + 1) / newTotalVotes * 100).round(),
        );
      }
      return option.copyWith(perc: (option.vote / newTotalVotes * 100).round());
    }).toList();

    final updatedPoll = poll.copyWith(options: updatedOptions);
    final updatedPost = post.copyWith(poll: updatedPoll);

    posts[postIndex] = updatedPost;
    emit(FeedLoaded(posts: posts));

    try {
      await _repository.voteOnPoll(optionId);
    } catch (e) {
      // Revert optimistic update
      posts[postIndex] = post;
      emit(FeedLoaded(posts: posts));
    }
  }

  Future<void> followUser(int userId, int postIndex) async {
    final currentState = state;
    if (currentState is! FeedLoaded) return;

    final posts = List<FeedPost>.from(currentState.posts);
    if (postIndex >= posts.length) return;

    final post = posts[postIndex];

    // Optimistic update
    final updatedAuthor = post.author.copyWith(isFollowing: true);
    final updatedPost = post.copyWith(author: updatedAuthor);

    posts[postIndex] = updatedPost;
    emit(FeedLoaded(posts: posts));

    try {
      await _repository.followUser(userId);
    } catch (e) {
      // Revert optimistic update
      posts[postIndex] = post;
      emit(FeedLoaded(posts: posts));
    }
  }

  Future<void> addComment(int postId, int postIndex, String text) async {
    final currentState = state;
    if (currentState is! FeedLoaded) return;

    final posts = List<FeedPost>.from(currentState.posts);
    if (postIndex >= posts.length) return;

    try {
      final newComment = await _repository.addComment(postId, text);

      final post = posts[postIndex];

      // Optimistic update - add the new comment
      final updatedComments = PostComments(
        total: post.comments.total + 1,
        commentList: [newComment, ...post.comments.commentList],
      );

      final updatedMetadata = post.metadata.copyWith(
        totalComments: post.metadata.totalComments + 1,
      );

      final updatedPost = post.copyWith(
        comments: updatedComments,
        metadata: updatedMetadata,
      );

      posts[postIndex] = updatedPost;
      emit(FeedLoaded(posts: posts));
    } catch (e) {
      // Handle error but don't revert since we don't have optimistic state here
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<void> loadPostDetails(String postId) async {
    emit(FeedLoading());
    try {
      final post = await _repository.getPostDetails(int.parse(postId));
      emit(PostDetailLoaded(post: post));
    } catch (e) {
      emit(FeedError(message: e.toString()));
    }
  }

  Future<void> addCommentToPost(String postId, String text) async {
    try {
      await _repository.addComment(int.parse(postId), text);

      // Reload post details to get updated comment count and comments
      final updatedPost = await _repository.getPostDetails(int.parse(postId));
      emit(PostDetailLoaded(post: updatedPost));
    } catch (e) {
      emit(CommentAddError(message: 'Failed to add comment: $e'));
    }
  }

  Future<void> addReply(String commentId, String text) async {
    try {
      await _repository.addReply(int.parse(commentId), text);

      // For now, we'll need to reload the current post
      if (state is PostDetailLoaded) {
        final currentPost = (state as PostDetailLoaded).post;
        final updatedPost = await _repository.getPostDetails(
          currentPost.metadata.id,
        );
        emit(PostDetailLoaded(post: updatedPost));
      }
    } catch (e) {
      emit(ReplyAddError(message: 'Failed to add reply: $e'));
    }
  }

  Future<void> refreshPostInFeed(int postId) async {
    final currentState = state;
    if (currentState is! FeedLoaded) return;

    try {
      final updatedPost = await _repository.getPostDetails(postId);
      final posts = List<FeedPost>.from(currentState.posts);

      // Find and update the post
      final postIndex = posts.indexWhere((post) => post.metadata.id == postId);
      if (postIndex != -1) {
        posts[postIndex] = updatedPost;
        emit(FeedLoaded(posts: posts));
      }
    } catch (e) {
      // Silently fail - don't affect the current feed state
    }
  }

  /// Return to feed from post detail - ensures proper feed state
  Future<void> returnToFeed() async {
    final currentState = state;
    
    // If we're in PostDetailLoaded, we need to get back to feed
    if (currentState is PostDetailLoaded) {
      await loadFeed();
    }
    // If we're in any other non-feed state, also load feed
    else if (currentState is! FeedLoaded && 
             currentState is! FeedRefreshing &&
             currentState is! PostCreating &&
             currentState is! PostCreateSuccess &&
             currentState is! PostCreateError) {
      await loadFeed();
    }
  }
}
