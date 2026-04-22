part of 'comments_bloc.dart';

class CommentsState extends Equatable {
  const CommentsState({
    this.comments = const [],
    this.loading = false,
    this.sending = false,
    this.errors = const [],
  });

  final List<Comment> comments;
  final bool loading;

  /// True while a create/reply call is in flight.
  final bool sending;

  final List<String> errors;

  CommentsState copyWith({
    List<Comment>? comments,
    bool? loading,
    bool? sending,
    List<String>? errors,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      loading: loading ?? this.loading,
      sending: sending ?? this.sending,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [comments, loading, sending, errors];
}
