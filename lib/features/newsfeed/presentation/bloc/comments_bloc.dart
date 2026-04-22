import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/comment.dart';
import '../../domain/repositories/newsfeed_repository.dart';

part 'comments_event.dart';
part 'comments_state.dart';

/// Per-post comments bloc. Spun up inside the comments bottom-sheet so each
/// thread has its own state and dispose. Handles: load, reply load, create
/// comment + reply, edit, delete, like toggle, pin toggle, hide toggle —
/// all with optimistic UI updates where safe, rollback on failure.
class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  CommentsBloc({
    required NewsfeedRepository repository,
    required String postUid,
  })  : _repo = repository,
        _postUid = postUid,
        super(const CommentsState()) {
    on<CommentsLoadRequested>(_onLoad);
    on<CommentCreated>(_onCreate);
    on<CommentReplyCreated>(_onCreateReply);
    on<CommentEdited>(_onEdit);
    on<CommentDeleted>(_onDelete);
    on<CommentLikeToggled>(_onLike);
    on<CommentPinToggled>(_onPin);
    on<CommentHideToggled>(_onHide);
    on<CommentRepliesToggled>(_onToggleReplies);
  }

  final NewsfeedRepository _repo;
  final String _postUid;

  // ── Load ────────────────────────────────────────────────────────────────────
  Future<void> _onLoad(
    CommentsLoadRequested event,
    Emitter<CommentsState> emit,
  ) async {
    emit(state.copyWith(loading: true, errors: const []));
    final res = await _repo.listComments(_postUid);
    res.fold(
      (f) => emit(state.copyWith(loading: false, errors: f.messages)),
      (list) => emit(state.copyWith(loading: false, comments: list)),
    );
  }

  // ── Create top-level comment ───────────────────────────────────────────────
  Future<void> _onCreate(
    CommentCreated event,
    Emitter<CommentsState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty) return;
    emit(state.copyWith(sending: true, errors: const []));
    final res = await _repo.createComment(postUid: _postUid, text: text);
    res.fold(
      (f) => emit(state.copyWith(sending: false, errors: f.messages)),
      (c) => emit(state.copyWith(
        sending: false,
        // Prepend — web shows newest first.
        comments: [c, ...state.comments],
      )),
    );
  }

  // ── Create reply ────────────────────────────────────────────────────────────
  Future<void> _onCreateReply(
    CommentReplyCreated event,
    Emitter<CommentsState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty) return;
    emit(state.copyWith(sending: true, errors: const []));
    final res = await _repo.createComment(
      postUid: _postUid,
      text: text,
      parentId: event.parentId,
    );
    res.fold(
      (f) => emit(state.copyWith(sending: false, errors: f.messages)),
      (c) {
        final idx = state.comments.indexWhere((x) => x.id == event.parentId);
        if (idx < 0) {
          emit(state.copyWith(sending: false));
          return;
        }
        final parent = state.comments[idx];
        final updated = parent.copyWith(
          replies: [...parent.replies, c],
          replyCount: parent.replyCount + 1,
          repliesExpanded: true,
        );
        emit(state.copyWith(
          sending: false,
          comments: _replaceAt(idx, updated),
        ));
      },
    );
  }

  // ── Edit ────────────────────────────────────────────────────────────────────
  Future<void> _onEdit(
    CommentEdited event,
    Emitter<CommentsState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty) return;
    final res = await _repo.editComment(commentId: event.commentId, text: text);
    res.fold(
      (f) => emit(state.copyWith(errors: f.messages)),
      (updated) {
        emit(state.copyWith(
          comments: _applyPatch(
            event.commentId,
            (c) => c.copyWith(
              text: updated.text,
              isEdited: true,
            ),
          ),
        ));
      },
    );
  }

  // ── Delete ──────────────────────────────────────────────────────────────────
  Future<void> _onDelete(
    CommentDeleted event,
    Emitter<CommentsState> emit,
  ) async {
    // Optimistic: remove immediately, rollback on failure.
    final snapshot = state.comments;
    emit(state.copyWith(comments: _removeById(event.commentId)));
    final res = await _repo.deleteComment(event.commentId);
    res.fold(
      (f) => emit(state.copyWith(comments: snapshot, errors: f.messages)),
      (_) {},
    );
  }

  // ── Like toggle ────────────────────────────────────────────────────────────
  Future<void> _onLike(
    CommentLikeToggled event,
    Emitter<CommentsState> emit,
  ) async {
    // Optimistic flip.
    emit(state.copyWith(
      comments: _applyPatch(
        event.commentId,
        (c) => c.copyWith(
          hasLiked: !c.hasLiked,
          likesCount: c.hasLiked
              ? (c.likesCount - 1).clamp(0, 1 << 30)
              : c.likesCount + 1,
        ),
      ),
    ));
    final res = await _repo.toggleCommentLike(event.commentId);
    res.fold(
      (f) => emit(state.copyWith(
        // rollback
        comments: _applyPatch(
          event.commentId,
          (c) => c.copyWith(
            hasLiked: !c.hasLiked,
            likesCount: c.hasLiked
                ? (c.likesCount - 1).clamp(0, 1 << 30)
                : c.likesCount + 1,
          ),
        ),
        errors: f.messages,
      )),
      (serverLiked) {
        // Sync to server's authoritative state.
        emit(state.copyWith(
          comments: _applyPatch(
            event.commentId,
            (c) => c.copyWith(hasLiked: serverLiked),
          ),
        ));
      },
    );
  }

  // ── Pin toggle ─────────────────────────────────────────────────────────────
  Future<void> _onPin(
    CommentPinToggled event,
    Emitter<CommentsState> emit,
  ) async {
    final res = await _repo.toggleCommentPin(event.commentId);
    res.fold(
      (f) => emit(state.copyWith(errors: f.messages)),
      (pinned) {
        // Move pinned comment to top; move unpinned back (sorted by id desc).
        final patched = _applyPatch(
          event.commentId,
          (c) => c.copyWith(isPinned: pinned),
        );
        patched.sort((a, b) {
          if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
          return b.createdAt.compareTo(a.createdAt);
        });
        emit(state.copyWith(comments: patched));
      },
    );
  }

  // ── Hide toggle ────────────────────────────────────────────────────────────
  Future<void> _onHide(
    CommentHideToggled event,
    Emitter<CommentsState> emit,
  ) async {
    final res = await _repo.toggleCommentHide(event.commentId);
    res.fold(
      (f) => emit(state.copyWith(errors: f.messages)),
      (hidden) => emit(state.copyWith(
        comments: _applyPatch(
          event.commentId,
          (c) => c.copyWith(isHidden: hidden),
        ),
      )),
    );
  }

  // ── Replies expand/collapse + lazy-load ────────────────────────────────────
  Future<void> _onToggleReplies(
    CommentRepliesToggled event,
    Emitter<CommentsState> emit,
  ) async {
    final idx = state.comments.indexWhere((c) => c.id == event.commentId);
    if (idx < 0) return;
    final parent = state.comments[idx];

    // Collapse — just flip flag.
    if (parent.repliesExpanded) {
      emit(state.copyWith(
        comments: _replaceAt(
          idx,
          parent.copyWith(repliesExpanded: false),
        ),
      ));
      return;
    }

    // Already loaded once — just flip flag, no fetch.
    if (parent.replies.isNotEmpty) {
      emit(state.copyWith(
        comments: _replaceAt(
          idx,
          parent.copyWith(repliesExpanded: true),
        ),
      ));
      return;
    }

    emit(state.copyWith(
      comments: _replaceAt(idx, parent.copyWith(loadingReplies: true)),
    ));
    final res = await _repo.listReplies(event.commentId);
    res.fold(
      (f) {
        final snapshot = state.comments[idx];
        emit(state.copyWith(
          comments: _replaceAt(idx, snapshot.copyWith(loadingReplies: false)),
          errors: f.messages,
        ));
      },
      (list) {
        final current = state.comments[idx];
        emit(state.copyWith(
          comments: _replaceAt(
            idx,
            current.copyWith(
              replies: list,
              repliesExpanded: true,
              loadingReplies: false,
            ),
          ),
        ));
      },
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  List<Comment> _replaceAt(int idx, Comment c) {
    final updated = List<Comment>.from(state.comments);
    updated[idx] = c;
    return updated;
  }

  /// Apply [patch] to any comment whose [Comment.id] matches [id], including
  /// nested replies.
  List<Comment> _applyPatch(int id, Comment Function(Comment) patch) {
    return [
      for (final c in state.comments)
        if (c.id == id)
          patch(c)
        else
          c.copyWith(
            replies: [
              for (final r in c.replies)
                if (r.id == id) patch(r) else r,
            ],
          ),
    ];
  }

  List<Comment> _removeById(int id) {
    return [
      for (final c in state.comments)
        if (c.id != id)
          c.copyWith(
            replies:
                c.replies.where((r) => r.id != id).toList(growable: false),
          ),
    ];
  }
}
