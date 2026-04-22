part of 'comments_bloc.dart';

sealed class CommentsEvent extends Equatable {
  const CommentsEvent();
  @override
  List<Object?> get props => const [];
}

class CommentsLoadRequested extends CommentsEvent {
  const CommentsLoadRequested();
}

class CommentCreated extends CommentsEvent {
  const CommentCreated(this.text);
  final String text;
  @override
  List<Object?> get props => [text];
}

class CommentReplyCreated extends CommentsEvent {
  const CommentReplyCreated({required this.parentId, required this.text});
  final int parentId;
  final String text;
  @override
  List<Object?> get props => [parentId, text];
}

class CommentEdited extends CommentsEvent {
  const CommentEdited({required this.commentId, required this.text});
  final int commentId;
  final String text;
  @override
  List<Object?> get props => [commentId, text];
}

class CommentDeleted extends CommentsEvent {
  const CommentDeleted(this.commentId);
  final int commentId;
  @override
  List<Object?> get props => [commentId];
}

class CommentLikeToggled extends CommentsEvent {
  const CommentLikeToggled(this.commentId);
  final int commentId;
  @override
  List<Object?> get props => [commentId];
}

class CommentPinToggled extends CommentsEvent {
  const CommentPinToggled(this.commentId);
  final int commentId;
  @override
  List<Object?> get props => [commentId];
}

class CommentHideToggled extends CommentsEvent {
  const CommentHideToggled(this.commentId);
  final int commentId;
  @override
  List<Object?> get props => [commentId];
}

class CommentRepliesToggled extends CommentsEvent {
  const CommentRepliesToggled(this.commentId);
  final int commentId;
  @override
  List<Object?> get props => [commentId];
}
