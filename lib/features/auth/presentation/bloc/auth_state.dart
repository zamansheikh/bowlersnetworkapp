part of 'auth_bloc.dart';

/// High-level authentication status, used by the router guard to decide
/// which top-level branch the user can reach.
enum AuthStatus {
  /// Boot-time — haven't checked storage yet.
  unknown,

  /// No token, or token cleared.
  unauthenticated,

  /// Minor account waiting on parental-consent email.
  requiresConsent,

  /// Token valid; profile-completion check hasn't happened yet or failed.
  authenticatedUnverified,

  /// Token valid AND profile-completion check passed.
  authenticated,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.session,
    this.processing = false,
    this.errors = const [],
  });

  final AuthStatus status;
  final AuthSession? session;

  /// True while a login/signup/reset call is in flight. UIs toggle button
  /// loading states on this.
  final bool processing;

  /// Latest backend error messages. Empty means no error to display.
  final List<String> errors;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated ||
      status == AuthStatus.authenticatedUnverified;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    bool? processing,
    List<String>? errors,
    bool clearSession = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: clearSession ? null : (session ?? this.session),
      processing: processing ?? this.processing,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [status, session, processing, errors];
}
