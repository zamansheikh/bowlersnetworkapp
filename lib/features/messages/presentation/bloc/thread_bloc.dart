import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/repositories/messages_repository.dart';

part 'thread_event.dart';
part 'thread_state.dart';

/// Scoped to a single conversation — loads messages, sends, marks read.
///
/// NOT a `@singleton` — created per thread-screen via `BlocProvider` so
/// each conversation has its own state and its own dispose.
class ThreadBloc extends Bloc<ThreadEvent, ThreadState> {
  ThreadBloc({
    required MessagesRepository repository,
    required String conversationUid,
  })  : _repository = repository,
        _uid = conversationUid,
        super(const ThreadState()) {
    on<ThreadLoadRequested>(_onLoad);
    on<ThreadMessageSent>(_onSend);
    on<ThreadMessageReceived>(_onReceived);
  }

  final MessagesRepository _repository;
  final String _uid;

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
        // newest at bottom auto-scroll).
        messages: list.reversed.toList(growable: false),
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
      (msg) => emit(state.copyWith(
        sending: false,
        messages: [...state.messages, msg],
      )),
    );
  }

  /// Hook for future WebSocket-delivered messages.
  void _onReceived(ThreadMessageReceived event, Emitter<ThreadState> emit) {
    if (state.messages.any((m) => m.uid == event.message.uid)) return;
    emit(state.copyWith(messages: [...state.messages, event.message]));
  }
}

void unawaited(Future<dynamic> _) {}
