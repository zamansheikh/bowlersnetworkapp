part of 'live_detail_bloc.dart';

class LiveDetailState extends Equatable {
  const LiveDetailState({
    this.loading = false,
    this.refreshing = false,
    this.detail,
    this.comments = const [],
    this.commentsCursor,
    this.loadingMoreComments = false,
    this.postingComment = false,
    this.errors = const [],
  });

  final bool loading;
  final bool refreshing;
  final LiveBroadcastDetail? detail;

  /// Newest-first. The screen reverses for chat order.
  final List<LiveBroadcastComment> comments;
  final int? commentsCursor;
  final bool loadingMoreComments;
  final bool postingComment;
  final List<String> errors;

  bool get hasMoreComments => commentsCursor != null;

  LiveDetailState copyWith({
    bool? loading,
    bool? refreshing,
    LiveBroadcastDetail? detail,
    List<LiveBroadcastComment>? comments,
    int? commentsCursor,
    bool clearCommentsCursor = false,
    bool? loadingMoreComments,
    bool? postingComment,
    List<String>? errors,
  }) {
    return LiveDetailState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      detail: detail ?? this.detail,
      comments: comments ?? this.comments,
      commentsCursor: clearCommentsCursor
          ? null
          : (commentsCursor ?? this.commentsCursor),
      loadingMoreComments: loadingMoreComments ?? this.loadingMoreComments,
      postingComment: postingComment ?? this.postingComment,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        refreshing,
        detail,
        comments,
        commentsCursor,
        loadingMoreComments,
        postingComment,
        errors,
      ];
}
