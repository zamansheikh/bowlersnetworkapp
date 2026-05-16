part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => const [];
}

/// Fired once at app boot. Reads persisted token (if any) and emits
/// the matching AuthStatus.
class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.credential, required this.password});

  final String credential;
  final String password;

  @override
  List<Object?> get props => [credential, password];
}

class AuthSignupRequested extends AuthEvent {
  const AuthSignupRequested({
    required this.data,
    required this.verificationCode,
    this.favoriteBrandIds = const [],
    this.referrerUsername,
  });

  final SignupData data;
  final String verificationCode;
  final List<int> favoriteBrandIds;
  final String? referrerUsername;

  @override
  List<Object?> get props =>
      [data, verificationCode, favoriteBrandIds, referrerUsername];
}

/// Fired after ProfileBloc confirms `is_complete: true`. Lifts the router
/// guard so the user can enter the main app.
class AuthProfileCompletionConfirmed extends AuthEvent {
  const AuthProfileCompletionConfirmed();
}

/// Fired after ProfileBloc sees `is_complete: false`. Keeps the user on
/// /profile until they finish.
class AuthProfileIncomplete extends AuthEvent {
  const AuthProfileIncomplete();
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Forcefully clears session (e.g. after receiving 401 on another endpoint).
class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}
