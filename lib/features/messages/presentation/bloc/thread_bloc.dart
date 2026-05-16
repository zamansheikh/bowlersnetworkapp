import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/chat_socket.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/messages_repository.dart';

part 'thread_event.dart';
part 'thread_state.dart';

/// Scoped to a single conversation — loads messages, sends, marks read, and
/// bridges the chat WebSocket for this conversation's live events (incoming
/// message / typing / deletion).
///
/// NOT a `@singleton` — created per thread-screen via `BlocProvider` so
/// each conversation has its own state and its own dispose.
class ThreadBloc extends Bloc<ThreadEvent, ThreadState> {
  ThreadBloc({
    required MessagesRepository repository,
    required ChatSocket socket,
    required String conversationUid,
    required int currentUserId,
  })  : _repository = repository,
        _socket = socket,
        _uid = conversationUid,
        _currentUserId = currentUserId,
        super(const ThreadState()) {
    on<ThreadLoadRequested>(_onLoad);
    on<ThreadMessageSent>(_onSend);
    on<ThreadMessageReceived>(_onReceived);
    on<ThreadTypingReceived>(_onTypingReceived);
    on<ThreadTypingExpired>(_onTypingExpired);
    on<ThreadMessageDeletedReceived>(_onDeletedReceived);
    on<ThreadMessageDeleteRequested>(_onDeleteRequested);
    on<ThreadTypingSent>(_onTypingSent);

    // Kick off WS (idempotent) + subscribe to events for this uid only.
    _socket.ensureConnected();
    _socketSub = _socket.events.listen(_onSocketEvent);
  }

  final MessagesRepository _repository;
  final ChatSocket _socket;
  final String _uid;
  final int _currentUserId;

  /// Web fallback: backend's `is_own` isn't 100% reliable (missing on socket
  /// payloads in some flows) — cross-check against the logged-in user id.
  ChatMessage _withIsOwn(ChatMessage m) => m.sender.id == _currentUserId
      ? (m.isOwn ? m : m.copyWith(isOwn: true))
      : m;

  StreamSubscription<ChatSocketEvent>? _socketSub;
  final Map<int, Timer> _typingTimers = {};

  static const _typingTtl = Duration(seconds: 3);

  Future<void> _onLoad(
    ThreadLoadRequested event,
    Emitter<ThreadState> emit,
  ) async {
    emit(state.copyWith(loading: true, errors: const []));
    final res = await _repository.getMessages(_uid);
    res.fold(
      (f) => emit(state.copyWith(loading: false, errors: f.messages)),
      (list) => emit(state.copyWith(
        loading: false,
        // Backend returns newest-first; flip for chat UX (oldest at top,
        // newest at bottom auto-scroll). Fallback isOwn by sender match.
        messages: list.reversed.map(_withIsOwn).toList(growable: false),
      )),
    );
    // Fire-and-forget — server drops any unread marker for this thread.
    unawaited(_repository.markRead(_uid));
  }

  Future<void> _onSend(
    ThreadMessageSent event,
    Emitter<ThreadState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty && event.media.isEmpty) return;
    emit(state.copyWith(sending: true, errors: const []));
    final res = await _repository.sendMessage(
      conversationUid: _uid,
      text: text,
      media: event.media,
    );
    res.fold(
      (f) => emit(state.copyWith(sending: false, errors: f.messages)),
      (msg) {
        // Dedupe if the socket beat the HTTP response.
        if (state.messages.any((m) => m.uid == msg.uid)) {
          emit(state.copyWith(sending: false));
          return;
        }
        emit(state.copyWith(
          sending: false,
          messages: [...state.messages, _withIsOwn(msg)],
        ));
      },
    );
  }

  void _onReceived(ThreadMessageReceived event, Emitter<ThreadState> emit) {
    if (state.messages.any((m) => m.uid == event.message.uid)) return;
    final msg = _withIsOwn(event.message);
    // The sender is no longer typing once we have their message.
    final clearedTyping = state.typingUsers
        .where((t) => t.userId != msg.sender.id)
        .toList(growable: false);
    emit(state.copyWith(
      messages: [...state.messages, msg],
      typingUsers: clearedTyping,
    ));
    _typingTimers.remove(msg.sender.id)?.cancel();
    // Update server read-state for the open thread.
    unawaited(_repository.markRead(_uid));
  }

  void _onTypingReceived(
    ThreadTypingReceived event,
    Emitter<ThreadState> emit,
  ) {
    final existing = state.typingUsers;
    final already = existing.any((t) => t.userId == event.userId);
    final next = already
        ? existing
        : [
            ...existing,
            TypingUser(userId: event.userId, username: event.username),
          ];
    if (!already) emit(state.copyWith(typingUsers: next));

    _typingTimers[event.userId]?.cancel();
    _typingTimers[event.userId] = Timer(_typingTtl, () {
      if (isClosed) return;
      add(ThreadTypingExpired(event.userId));
    });
  }

  void _onTypingExpired(
    ThreadTypingExpired event,
    Emitter<ThreadState> emit,
  ) {
    _typingTimers.remove(event.userId)?.cancel();
    final next = state.typingUsers
        .where((t) => t.userId != event.userId)
        .toList(growable: false);
    if (next.length == state.typingUsers.length) return;
    emit(state.copyWith(typingUsers: next));
  }

  void _onDeletedReceived(
    ThreadMessageDeletedReceived event,
    Emitter<ThreadState> emit,
  ) {
    final idx = state.messages.indexWhere((m) => m.uid == event.messageUid);
    if (idx < 0) return;
    final updated = List<ChatMessage>.from(state.messages);
    updated[idx] = updated[idx].copyWith(isDeleted: true, text: '');
    emit(state.copyWith(messages: updated));
  }

  Future<void> _onDeleteRequested(
    ThreadMessageDeleteRequested event,
    Emitter<ThreadState> emit,
  ) async {
    // Optimistic flip; rollback on failure.
    final idx = state.messages.indexWhere((m) => m.uid == event.messageUid);
    if (idx < 0) return;
    final original = state.messages[idx];
    final updated = List<ChatMessage>.from(state.messages);
    updated[idx] = original.copyWith(isDeleted: true, text: '');
    emit(state.copyWith(messages: updated));

    final res = await _repository.deleteMessage(event.messageUid);
    res.fold(
      (f) {
        final rollback = List<ChatMessage>.from(state.messages);
        rollback[idx] = original;
        emit(state.copyWith(messages: rollback, errors: f.messages));
      },
      (_) {},
    );
  }

  void _onTypingSent(ThreadTypingSent event, Emitter<ThreadState> emit) {
    _socket.sendTyping(_uid);
  }

  void _onSocketEvent(ChatSocketEvent e) {
    if (isClosed) return;
    switch (e) {
      case ChatMessageEvent(:final conversationUid, :final message)
          when conversationUid == _uid:
        add(ThreadMessageReceived(_repository.parseSocketMessage(message)));
      case ChatTypingEvent(
          :final conversationUid,
          :final userId,
          :final username,
        )
          when conversationUid == _uid:
        add(ThreadTypingReceived(userId: userId, username: username));
      case ChatMessageDeletedEvent(:final conversationUid, :final messageUid)
          when conversationUid == _uid:
        add(ThreadMessageDeletedReceived(messageUid));
      default:
        break;
    }
  }

  @override
  Future<void> close() async {
    await _socketSub?.cancel();
    for (final t in _typingTimers.values) {
      t.cancel();
    }
    _typingTimers.clear();
    return super.close();
  }
}
