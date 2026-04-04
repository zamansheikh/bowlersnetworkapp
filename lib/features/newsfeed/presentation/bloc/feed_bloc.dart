import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/post_models.dart';
import '../../domain/repositories/newsfeed_repository.dart';

part 'feed_event.dart';
part 'feed_state.dart';

@injectable
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final NewsfeedRepository _repository;

  FeedBloc(this._repository) : super(const FeedState()) {
    on<FeedLoadRequested>(_onLoad);
    on<FeedLoadMoreRequested>(_onLoadMore);
    on<FeedRefreshRequested>(_onRefresh);
    on<FeedReactRequested>(_onReact);
    on<FeedSaveToggled>(_onToggleSave);
    on<FeedPostHidden>(_onHidePost);
    on<FeedPostDeleted>(_onDeletePost);
  }

  Future<void> _onLoad(FeedLoadRequested event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: FeedStatus.loading));
    final result = await _repository.getFeed(filter: event.filter);
    result.fold(
      (f) => emit(state.copyWith(status: FeedStatus.error, errorMessage: f.message)),
      (posts) => emit(state.copyWith(
        status: FeedStatus.loaded,
        posts: posts,
        hasMore: posts.length >= 20,
        filter: event.filter,
      )),
    );
  }

  Future<void> _onLoadMore(FeedLoadMoreRequested event, Emitter<FeedState> emit) async {
    if (state.isLoadingMore || !state.hasMore) return;
    emit(state.copyWith(isLoadingMore: true));
    final cursor = state.posts.isNotEmpty ? state.posts.last.id : null;
    final result = await _repository.getFeed(cursor: cursor, filter: state.filter);
    result.fold(
      (f) => emit(state.copyWith(isLoadingMore: false)),
      (posts) => emit(state.copyWith(
        isLoadingMore: false,
        posts: [...state.posts, ...posts],
        hasMore: posts.length >= 20,
      )),
    );
  }

  Future<void> _onRefresh(FeedRefreshRequested event, Emitter<FeedState> emit) async {
    final result = await _repository.getFeed(filter: state.filter);
    result.fold(
      (f) => emit(state.copyWith(errorMessage: f.message)),
      (posts) => emit(state.copyWith(
        status: FeedStatus.loaded,
        posts: posts,
        hasMore: posts.length >= 20,
      )),
    );
  }

  Future<void> _onReact(FeedReactRequested event, Emitter<FeedState> emit) async {
    final result = await _repository.react(event.postId, event.reactionType);
    result.fold((_) {}, (data) {
      final action = data['action'] as String?;
      final updatedPosts = state.posts.map((p) {
        if (p.id != event.postId) return p;
        final newLikes = action == 'added' ? p.likesCount + 1
            : action == 'removed' ? p.likesCount - 1
            : p.likesCount;
        return PostModel(
          id: p.id, uid: p.uid, postType: p.postType, caption: p.caption,
          audience: p.audience, createdAt: p.createdAt, author: p.author,
          isEdited: p.isEdited, isPinned: p.isPinned, isCommentsEnabled: p.isCommentsEnabled,
          likesCount: newLikes, commentsCount: p.commentsCount,
          sharesCount: p.sharesCount, savesCount: p.savesCount, typeData: p.typeData,
          isMine: p.isMine,
          hasReacted: action != 'removed',
          reactionType: data['reaction_type'] as String?,
          hasSaved: p.hasSaved,
        );
      }).toList();
      emit(state.copyWith(posts: updatedPosts));
    });
  }

  Future<void> _onToggleSave(FeedSaveToggled event, Emitter<FeedState> emit) async {
    final result = await _repository.toggleSave(event.postId);
    result.fold((_) {}, (saved) {
      final updatedPosts = state.posts.map((p) {
        if (p.id != event.postId) return p;
        return PostModel(
          id: p.id, uid: p.uid, postType: p.postType, caption: p.caption,
          audience: p.audience, createdAt: p.createdAt, author: p.author,
          isEdited: p.isEdited, isPinned: p.isPinned, isCommentsEnabled: p.isCommentsEnabled,
          likesCount: p.likesCount, commentsCount: p.commentsCount,
          sharesCount: p.sharesCount, savesCount: p.savesCount + (saved ? 1 : -1),
          typeData: p.typeData, isMine: p.isMine,
          hasReacted: p.hasReacted, reactionType: p.reactionType, hasSaved: saved,
        );
      }).toList();
      emit(state.copyWith(posts: updatedPosts));
    });
  }

  Future<void> _onHidePost(FeedPostHidden event, Emitter<FeedState> emit) async {
    await _repository.hidePost(event.postId);
    emit(state.copyWith(posts: state.posts.where((p) => p.id != event.postId).toList()));
  }

  Future<void> _onDeletePost(FeedPostDeleted event, Emitter<FeedState> emit) async {
    final result = await _repository.deletePost(event.postId);
    result.fold((_) {}, (_) {
      emit(state.copyWith(posts: state.posts.where((p) => p.id != event.postId).toList()));
    });
  }
}
