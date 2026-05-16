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

/// A socket-delivered message in one of our threads — bump the preview +
/// move to top + flag unread (unless the user is already in that thread).
class ConversationMessageArrived extends ConversationsEvent {
  const ConversationMessageArrived({
    required this.conversationUid,
    required this.senderName,
    required this.text,
    required this.createdAt,
    required this.fromSelf,
  });

  final String conversationUid;
  final String senderName;
  final String text;
  final DateTime? createdAt;
  final bool fromSelf;

  @override
  List<Object?> get props =>
      [conversationUid, senderName, text, createdAt, fromSelf];
}

/// Freshly-created DM / group — prepend it to the list.
class ConversationInserted extends ConversationsEvent {
  const ConversationInserted(this.conversation);
  final ConversationListItem conversation;
  @override
  List<Object?> get props => [conversation];
}

/// User toggled mute inside the thread screen — reflect in the list.
class ConversationMuteChanged extends ConversationsEvent {
  const ConversationMuteChanged({
    required this.conversationUid,
    required this.isMuted,
  });
  final String conversationUid;
  final bool isMuted;
  @override
  List<Object?> get props => [conversationUid, isMuted];
}

/// User left or deleted the group — drop it from the local list.
class ConversationRemovedLocally extends ConversationsEvent {
  const ConversationRemovedLocally({required this.conversationUid});
  final String conversationUid;
  @override
  List<Object?> get props => [conversationUid];
}
