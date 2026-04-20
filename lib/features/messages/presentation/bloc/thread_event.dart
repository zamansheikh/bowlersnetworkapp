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

/// Wired in for when WebSocket delivery lands — pushes an incoming message
/// from the realtime channel into the thread's state.
class ThreadMessageReceived extends ThreadEvent {
  const ThreadMessageReceived(this.message);
  final ChatMessage message;
  @override
  List<Object?> get props => [message];
}
