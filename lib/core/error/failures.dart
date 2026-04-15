import 'package:equatable/equatable.dart';

/// Every backend error returns `{"errors": ["msg1", "msg2"]}`. Failures carry
/// the full list — UIs must iterate `messages`, never collapse to a single
/// string.
sealed class Failure extends Equatable {
  const Failure({this.messages = const ['Something went wrong.'], this.statusCode});

  final List<String> messages;
  final int? statusCode;

  /// Convenience for logging / single-line displays.
  String get message => messages.join(' ');

  @override
  List<Object?> get props => [messages, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({super.messages, super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure()
      : super(messages: const ['No internet connection.']);
}

class CacheFailure extends Failure {
  const CacheFailure() : super(messages: const ['Cache error.']);
}

class AuthFailure extends Failure {
  const AuthFailure({super.messages, super.statusCode});
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    super.messages,
    this.fieldErrors,
    super.statusCode,
  });

  final Map<String, List<String>>? fieldErrors;

  @override
  List<Object?> get props => [messages, statusCode, fieldErrors];
}

class ProfileIncompleteFailure extends Failure {
  const ProfileIncompleteFailure()
      : super(messages: const ['Profile is incomplete.']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.messages = const [
    'Session expired. Please log in again.',
  ]});
}
