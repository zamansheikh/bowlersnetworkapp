import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/live_socket.dart';
import '../../domain/entities/live_viewer.dart';
import '../../domain/repositories/live_repository.dart';

part 'live_detail_event.dart';
part 'live_detail_state.dart';

/// Drives /live/:uid. Owns the broadcast detail + comments list + the
/// active WebSocket subscription. Lifecycle:
///   * `LiveDetailOpened(uid)` — REST detail fetch, comments fetch, then
///     open the socket (we need the numeric livescore id from the REST
///     response before we can subscribe).
///   * Socket events mutate the loaded state in-place.
///   * `close()` disconnects the socket cleanly.
@injectable
class LiveDetailBloc extends Bloc<LiveDetailEvent, LiveDetailState> {
  LiveDetailBloc(this._repository, this._socket)
      : super(const LiveDetailState()) {
    on<LiveDetailOpened>(_onOpened);
    on<LiveDetailRefreshRequested>(_onRefresh);
    on<LiveCommentsLoadMore>(_onCommentsLoadMore);
    on<LiveCommentPosted>(_onCommentPosted);
    on<LiveCommentDeleted>(_onCommentDeleted);
    on<LiveReactionPicked>(_onReactionPicked);
    on<LiveReactionCleared>(_onReactionCleared);
    on<_SocketEventReceived>(_onSocket);
  }

  final LiveRepository _repository;
  final LiveSocket _socket;
  StreamSubscription<LiveSocketEvent>? _sub;

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await _socket.disconnect();
    return super.close();
  }

  Future<void> _onOpened(
    LiveDetailOpened event,
    Emitter<LiveDetailState> emit,
  ) async {
    emit(state.copyWith(loading: true, errors: const []));

    // 1. Fetch the broadcast detail (resolves the uid → numeric id we
    //    need for the socket + comments + react endpoints).
    final detailRes = await _repository.getLiveByUid(event.uid);
    final detail = detailRes.fold<LiveBroadcastDetail?>(
      (f) {
        emit(state.copyWith(
          loading: false,
          errors: f.messages.isEmpty
              ? const ['Failed to load broadcast.']
              : f.messages,
        ));
        return null;
      },
      (data) => data,
    );
    if (detail == null) return;

    // 2. First page of comments (server returns newest-first; we keep
    //    newest-first in state, but the screen reverses for chat order).
    final commentsRes = await _repository.getComments(liveId: detail.id);
    final commentsPage = commentsRes.fold<LiveCommentsPage>(
      (_) => const LiveCommentsPage(),
      (p) => p,
    );

    emit(state.copyWith(
      loading: false,
      detail: detail,
      comments: commentsPage.comments,
      commentsCursor: commentsPage.nextCursorId,
    ));

    // 3. Open the socket only if the broadcast is still active —
    //    ended broadcasts get no further updates.
    if (detail.isActive) {
      await _subscribeSocket(detail.id);
    }
  }

  Future<void> _subscribeSocket(int livescoreId) async {
    await _sub?.cancel();
    _sub = _socket.events.listen((event) {
      add(_SocketEventReceived(event));
    });
    await _socket.connect(livescoreId);
  }

  Future<void> _onRefresh(
    LiveDetailRefreshRequested event,
    Emitter<LiveDetailState> emit,
  ) async {
    final current = state.detail;
    if (current == null) return;
    emit(state.copyWith(refreshing: true, errors: const []));
    final res = await _repository.getLiveByUid(current.uid);
    res.fold(
      (f) => emit(state.copyWith(
        refreshing: false,
        errors: f.messages.isEmpty
            ? const ['Failed to refresh.']
            : f.messages,
      )),
      (data) => emit(state.copyWith(refreshing: false, detail: data)),
    );
  }

  Future<void> _onCommentsLoadMore(
    LiveCommentsLoadMore event,
    Emitter<LiveDetailState> emit,
  ) async {
    final detail = state.detail;
    if (detail == null ||
        state.commentsCursor == null ||
        state.loadingMoreComments) {
      return;
    }
    emit(state.copyWith(loadingMoreComments: true));
    final res = await _repository.getComments(
      liveId: detail.id,
      cursorId: state.commentsCursor,
    );
    res.fold(
      (_) => emit(state.copyWith(loadingMoreComments: false)),
      (page) => emit(state.copyWith(
        loadingMoreComments: false,
        comments: [...state.comments, ...page.comments],
        commentsCursor: page.nextCursorId,
      )),
    );
  }

  Future<void> _onCommentPosted(
    LiveCommentPosted event,
    Emitter<LiveDetailState> emit,
  ) async {
    final detail = state.detail;
    final body = event.body.trim();
    if (detail == null || body.isEmpty || state.postingComment) return;
    emit(state.copyWith(postingComment: true));
    final res = await _repository.postComment(
      liveId: detail.id,
      body: body,
    );
    res.fold(
      (f) => emit(state.copyWith(
        postingComment: false,
        errors: f.messages.isEmpty
            ? const ['Failed to post comment.']
            : f.messages,
      )),
      (comment) {
        // The socket will also push this back via `comment_added`. We
        // dedupe in `_appendComment` so the local insertion is safe.
        emit(_appendComment(state, comment).copyWith(
          postingComment: false,
        ));
      },
    );
  }

  Future<void> _onCommentDeleted(
    LiveCommentDeleted event,
    Emitter<LiveDetailState> emit,
  ) async {
    final detail = state.detail;
    if (detail == null) return;
    // Optimistic — drop the row immediately; restore on failure.
    final removed = state.comments
        .firstWhere((c) => c.id == event.commentId, orElse: () => _missing);
    if (removed.id == 0) return;
    emit(state.copyWith(
      comments: state.comments
          .where((c) => c.id != event.commentId)
          .toList(growable: false),
    ));
    final res = await _repository.deleteComment(
      liveId: detail.id,
      commentId: event.commentId,
    );
    res.fold(
      (f) {
        emit(state.copyWith(
          comments: [...state.comments, removed]..sort(
              (a, b) => b.createdAt.compareTo(a.createdAt),
            ),
          errors: f.messages.isEmpty
              ? const ['Failed to delete comment.']
              : f.messages,
        ));
      },
      (_) {/* nothing — socket will echo `comment_deleted` */},
    );
  }

  Future<void> _onReactionPicked(
    LiveReactionPicked event,
    Emitter<LiveDetailState> emit,
  ) async {
    final detail = state.detail;
    if (detail == null) return;
    // Optimistic — swap to the new emoji + adjust the local summary so
    // the UI updates instantly. Rollback on error.
    final previous = detail.myReaction;
    if (previous == event.type) return;
    final optimistic = _withMyReaction(detail, event.type);
    emit(state.copyWith(detail: optimistic));
    final res = await _repository.react(
      liveId: detail.id,
      type: event.type,
    );
    res.fold(
      (f) => emit(state.copyWith(
        detail: detail, // rollback
        errors: f.messages.isEmpty
            ? const ['Failed to send reaction.']
            : f.messages,
      )),
      (authoritative) {
        // Backend may have collapsed to a different state (e.g.
        // user double-tapped before we got the response).
        if (authoritative != event.type && authoritative != null) {
          emit(state.copyWith(
            detail: _withMyReaction(detail, authoritative),
          ));
        }
      },
    );
  }

  Future<void> _onReactionCleared(
    LiveReactionCleared event,
    Emitter<LiveDetailState> emit,
  ) async {
    final detail = state.detail;
    if (detail == null || detail.myReaction == null) return;
    final previous = detail.myReaction!;
    final optimistic = _withMyReaction(detail, null);
    emit(state.copyWith(detail: optimistic));
    final res = await _repository.removeReaction(detail.id);
    res.fold(
      (f) => emit(state.copyWith(
        detail: _withMyReaction(detail, previous), // rollback
        errors: f.messages.isEmpty
            ? const ['Failed to clear reaction.']
            : f.messages,
      )),
      (_) {/* socket will echo */},
    );
  }

  void _onSocket(
    _SocketEventReceived wrapped,
    Emitter<LiveDetailState> emit,
  ) {
    final detail = state.detail;
    if (detail == null) return;
    final ev = wrapped.event;
    if (ev.livescoreId != detail.id) return;

    switch (ev) {
      case LiveInitEvent(:final viewerCount):
        emit(state.copyWith(
          detail: detail.copyWith(viewerCount: viewerCount),
        ));
      case LiveViewerCountEvent(:final viewerCount):
        emit(state.copyWith(
          detail: detail.copyWith(viewerCount: viewerCount),
        ));
      case LiveBroadcastEndedEvent():
        emit(state.copyWith(
          detail: detail.copyWith(
            status: LiveStatus.ended,
            endReason: LiveEndReason.fromWire(ev.endReason),
            endedAt: ev.endedAt ?? DateTime.now(),
          ),
        ));
      case LiveFrameUpdateEvent(:final game):
        final next = _replaceGame(detail, _repository.parseLiveGame(game));
        emit(state.copyWith(detail: next));
      case LiveGameStartedEvent(:final game):
        final next = _replaceGame(detail, _repository.parseLiveGame(game));
        emit(state.copyWith(detail: next));
      case LiveReactionChangedEvent():
        // Echo of someone else's reaction — refresh the summary total.
        // We don't try to mutate `reaction_summary` locally because
        // we don't have the previous → new diff for every case.
        // Trigger a detail refresh in the background so counts stay
        // accurate over time.
        add(const LiveDetailRefreshRequested());
      case LiveCommentAddedEvent(:final comment):
        final entity = _repository.parseLiveComment(comment);
        emit(_appendComment(state, entity));
      case LiveCommentDeletedEvent(:final commentId):
        emit(state.copyWith(
          comments: state.comments
              .where((c) => c.id != commentId)
              .toList(growable: false),
        ));
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Sentinel returned by `firstWhere` when a comment can't be found —
  /// `id == 0` is the "not present" marker.
  static final LiveBroadcastComment _missing = LiveBroadcastComment(
    id: 0,
    body: '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  /// Insert a comment without duplicating if the socket also echoes it.
  LiveDetailState _appendComment(
    LiveDetailState s,
    LiveBroadcastComment c,
  ) {
    if (s.comments.any((existing) => existing.id == c.id)) return s;
    return s.copyWith(comments: [c, ...s.comments]);
  }

  LiveBroadcastDetail _replaceGame(
    LiveBroadcastDetail detail,
    LiveGame next,
  ) {
    final session = detail.session;
    final idx =
        session.games.indexWhere((g) => g.gameNumber == next.gameNumber);
    final games = List<LiveGame>.from(session.games);
    if (idx == -1) {
      games.add(next);
      games.sort((a, b) => a.gameNumber.compareTo(b.gameNumber));
    } else {
      games[idx] = next;
    }
    return detail.copyWith(
      session: LiveSession(uid: session.uid, games: games),
    );
  }

  /// Build a new detail with [next] as the viewer's reaction. Updates
  /// `reaction_summary` so the bar stays accurate without a refresh.
  LiveBroadcastDetail _withMyReaction(
    LiveBroadcastDetail detail,
    LiveReactionType? next,
  ) {
    final summary = Map<String, int>.from(detail.reactionSummary);
    final previous = detail.myReaction;
    if (previous != null) {
      final prevCount = summary[previous.wire] ?? 0;
      if (prevCount <= 1) {
        summary.remove(previous.wire);
      } else {
        summary[previous.wire] = prevCount - 1;
      }
    }
    if (next != null) {
      summary[next.wire] = (summary[next.wire] ?? 0) + 1;
    }
    var reactionsCount = detail.reactionsCount;
    if (previous == null && next != null) reactionsCount += 1;
    if (previous != null && next == null) {
      reactionsCount = (reactionsCount - 1).clamp(0, 1 << 31);
    }
    return detail.copyWith(
      myReaction: next,
      clearMyReaction: next == null,
      reactionSummary: summary,
      reactionsCount: reactionsCount,
    );
  }
}

/// Internal — wraps a socket event for the bloc dispatcher.
class _SocketEventReceived extends LiveDetailEvent {
  const _SocketEventReceived(this.event);
  final LiveSocketEvent event;
  @override
  List<Object?> get props => [event];
}
