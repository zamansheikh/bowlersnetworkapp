import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/repositories/messages_repository.dart';

part 'conversations_event.dart';
part 'conversations_state.dart';

/// Drives the conversations list (the main Messages tab).
@injectable
class ConversationsBloc extends Bloc<ConversationsEvent, ConversationsState> {
  ConversationsBloc(this._repository) : super(const ConversationsState()) {
    on<ConversationsLoadRequested>(_onLoad);
    on<ConversationsRefreshRequested>(_onRefresh);
    on<ConversationMarkedRead>(_onMarkRead);
  }

  final MessagesRepository _repository;

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
}
