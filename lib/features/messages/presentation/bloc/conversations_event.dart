part of 'conversations_bloc.dart';

sealed class ConversationsEvent extends Equatable {
  const ConversationsEvent();
  @override
  List<Object?> get props => const [];
}

class ConversationsLoadRequested extends ConversationsEvent {
  const ConversationsLoadRequested();
}

class ConversationsRefreshRequested extends ConversationsEvent {
  const ConversationsRefreshRequested();
}

class ConversationMarkedRead extends ConversationsEvent {
  const ConversationMarkedRead({required this.conversationUid});
  final String conversationUid;
  @override
  List<Object?> get props => [conversationUid];
}
