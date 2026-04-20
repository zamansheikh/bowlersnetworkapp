part of 'thread_bloc.dart';

class ThreadState extends Equatable {
  const ThreadState({
    this.messages = const [],
    this.loading = false,
    this.sending = false,
    this.errors = const [],
  });

  final List<ChatMessage> messages;
  final bool loading;
  final bool sending;
  final List<String> errors;

  ThreadState copyWith({
    List<ChatMessage>? messages,
    bool? loading,
    bool? sending,
    List<String>? errors,
  }) {
    return ThreadState(
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
      sending: sending ?? this.sending,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [messages, loading, sending, errors];
}
