import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/chat_socket.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/messages_repository.dart';

part 'conversations_event.dart';
part 'conversations_state.dart';

/// Drives the conversations list (the main Messages tab). Owns a long-lived
/// WebSocket subscription so the list stays ordered by latest activity even
/// when the user is on another tab.
@injectable
class ConversationsBloc extends Bloc<ConversationsEvent, ConversationsState> {
  ConversationsBloc(this._repository, this._socket)
      : super(const ConversationsState()) {
    on<ConversationsLoadRequested>(_onLoad);
    on<ConversationsRefreshRequested>(_onRefresh);
    on<ConversationMarkedRead>(_onMarkRead);
    on<ConversationMessageArrived>(_onMessageArrived);
    on<ConversationInserted>(_onInserted);
    on<ConversationMuteChanged>(_onMuteChanged);
    on<ConversationRemovedLocally>(_onRemoved);

    _socket.ensureConnected();
    _socketSub = _socket.events.listen(_onSocketEvent);
  }

  final MessagesRepository _repository;
  final ChatSocket _socket;
  StreamSubscription<ChatSocketEvent>? _socketSub;

  Future<void> _onLoad(
    ConversationsLoadRequested event,
    Emitter<ConversationsState> emit,
  ) async {
    if (state.items.isNotEmpty) return;
    emit(state.copyWith(loading: true, errors: const []));
    final res = await _repository.getConversations();
    res.fold(
      (f) => emit(state.copyWith(loading: false, errors: f.messages)),
      (list) =>
          emit(state.copyWith(loading: false, items: list, errors: const [])),
    );
  }

  Future<void> _onRefresh(
    ConversationsRefreshRequested event,
    Emitter<ConversationsState> emit,
  ) async {
    emit(state.copyWith(refreshing: true, errors: const []));
    final res = await _repository.getConversations();
    res.fold(
      (f) => emit(state.copyWith(refreshing: false, errors: f.messages)),
      (list) => emit(state.copyWith(
        refreshing: false,
        items: list,
        errors: const [],
      )),
    );
  }

  /// Clears the unread dot locally after the user opens the thread.
  void _onMarkRead(
    ConversationMarkedRead event,
    Emitter<ConversationsState> emit,
  ) {
    final idx = state.items.indexWhere((c) => c.uid == event.conversationUid);
    if (idx < 0) return;
    final updated = List<ConversationListItem>.from(state.items);
    updated[idx] = updated[idx].copyWith(hasUnread: false);
    emit(state.copyWith(items: updated));
  }

  void _onMessageArrived(
    ConversationMessageArrived event,
    Emitter<ConversationsState> emit,
  ) {
    final idx = state.items.indexWhere((c) => c.uid == event.conversationUid);
    if (idx < 0) return;
    final existing = state.items[idx];
    final bumped = existing.copyWith(
      hasUnread: !event.fromSelf,
      lastMessage: LastMessagePreview(
        senderName: event.senderName,
        text: event.text,
        createdAt: event.createdAt,
      ),
    );
    final reordered = <ConversationListItem>[
      bumped,
      for (var i = 0; i < state.items.length; i++)
        if (i != idx) state.items[i],
    ];
    emit(state.copyWith(items: reordered));
  }

  void _onInserted(
    ConversationInserted event,
    Emitter<ConversationsState> emit,
  ) {
    // Dedupe — creating a DM that already exists returns the existing one.
    final existingIdx =
        state.items.indexWhere((c) => c.uid == event.conversation.uid);
    if (existingIdx >= 0) return;
    emit(state.copyWith(items: [event.conversation, ...state.items]));
  }

  void _onMuteChanged(
    ConversationMuteChanged event,
    Emitter<ConversationsState> emit,
  ) {
    final idx = state.items.indexWhere((c) => c.uid == event.conversationUid);
    if (idx < 0) return;
    final updated = List<ConversationListItem>.from(state.items);
    updated[idx] = updated[idx].copyWith(isMuted: event.isMuted);
    emit(state.copyWith(items: updated));
  }

  void _onRemoved(
    ConversationRemovedLocally event,
    Emitter<ConversationsState> emit,
  ) {
    final filtered = state.items
        .where((c) => c.uid != event.conversationUid)
        .toList(growable: false);
    emit(state.copyWith(items: filtered));
  }

  void _onSocketEvent(ChatSocketEvent e) {
    if (isClosed) return;
    if (e is! ChatMessageEvent) return;
    final msg = e.message;
    final senderRaw = msg['sender'];
    if (senderRaw is! Map<String, dynamic>) return;
    final text = (msg['text'] as String?) ?? '';
    final createdAt = DateTime.tryParse((msg['created_at'] as String?) ?? '');
    final fromSelf = (msg['is_own'] as bool?) ?? false;
    final first = (senderRaw['first_name'] as String?) ?? '';
    final last = (senderRaw['last_name'] as String?) ?? '';
    final uname = (senderRaw['username'] as String?) ?? '';
    final display =
        '$first $last'.trim().isEmpty ? uname : '$first $last'.trim();
    add(ConversationMessageArrived(
      conversationUid: e.conversationUid,
      senderName: display,
      text: text,
      createdAt: createdAt,
      fromSelf: fromSelf,
    ));
  }

  @override
  Future<void> close() async {
    await _socketSub?.cancel();
    return super.close();
  }
}
