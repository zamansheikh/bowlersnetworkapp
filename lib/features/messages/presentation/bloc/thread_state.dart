part of 'thread_bloc.dart';

class TypingUser extends Equatable {
  const TypingUser({required this.userId, required this.username});
  final int userId;
  final String username;
  @override
  List<Object?> get props => [userId, username];
}

class ThreadState extends Equatable {
  const ThreadState({
    this.messages = const [],
    this.loading = false,
    this.sending = false,
    this.errors = const [],
    this.typingUsers = const [],
  });

  final List<ChatMessage> messages;
  final bool loading;
  final bool sending;
  final List<String> errors;
  final List<TypingUser> typingUsers;

  ThreadState copyWith({
    List<ChatMessage>? messages,
    bool? loading,
    bool? sending,
    List<String>? errors,
    List<TypingUser>? typingUsers,
  }) {
    return ThreadState(
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
      sending: sending ?? this.sending,
      errors: errors ?? this.errors,
      typingUsers: typingUsers ?? this.typingUsers,
    );
  }

  @override
  List<Object?> get props =>
      [messages, loading, sending, errors, typingUsers];
}
