part of 'thread_bloc.dart';

sealed class ThreadEvent extends Equatable {
  const ThreadEvent();
  @override
  List<Object?> get props => const [];
}

class ThreadLoadRequested extends ThreadEvent {
  const ThreadLoadRequested();
}

class ThreadMessageSent extends ThreadEvent {
  const ThreadMessageSent({required this.text, this.media = const []});
  final String text;
  final List<MessageMedia> media;
  @override
  List<Object?> get props => [text, media];
}

/// Push an incoming WebSocket-delivered message into thread state. Ignored
/// if it already exists (dedupe on `uid`).
class ThreadMessageReceived extends ThreadEvent {
  const ThreadMessageReceived(this.message);
  final ChatMessage message;
  @override
  List<Object?> get props => [message];
}

/// User in the thread is typing right now (WS-delivered). A timer inside
/// the bloc clears it after 3s if no new typing event arrives.
class ThreadTypingReceived extends ThreadEvent {
  const ThreadTypingReceived({required this.userId, required this.username});
  final int userId;
  final String username;
  @override
  List<Object?> get props => [userId, username];
}

class ThreadTypingExpired extends ThreadEvent {
  const ThreadTypingExpired(this.userId);
  final int userId;
  @override
  List<Object?> get props => [userId];
}

/// WS told us a message was deleted — mark it as deleted in state.
class ThreadMessageDeletedReceived extends ThreadEvent {
  const ThreadMessageDeletedReceived(this.messageUid);
  final String messageUid;
  @override
  List<Object?> get props => [messageUid];
}

/// User-initiated delete of own message.
class ThreadMessageDeleteRequested extends ThreadEvent {
  const ThreadMessageDeleteRequested(this.messageUid);
  final String messageUid;
  @override
  List<Object?> get props => [messageUid];
}

/// Notify the backend the local user is typing. Fires on each keystroke;
/// the outbound socket call is cheap and the server throttles.
class ThreadTypingSent extends ThreadEvent {
  const ThreadTypingSent();
}
