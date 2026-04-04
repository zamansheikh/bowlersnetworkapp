import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.statusCode});
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure(
    super.message, {
    this.fieldErrors,
    super.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode, fieldErrors];
}

class ProfileIncompleteFailure extends Failure {
  const ProfileIncompleteFailure([super.message = 'Profile is incomplete']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Session expired. Please log in again.']);
}
