part of 'auth_cubit.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

class Authenticated extends AuthState {
  final AuthToken token;
  final User user;
  const Authenticated({required this.token, required this.user});
}

class AuthenticatedIncompleteProfile extends AuthState {
  final AuthToken token;
  final User user;
  const AuthenticatedIncompleteProfile({
    required this.token,
    required this.user,
  });
}

class Unauthenticated extends AuthState {}
