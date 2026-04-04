part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  consentRequired,
  emailSent,       // verification code sent
  otpSent,         // recovery OTP sent
  magicLinkSent,   // magic link sent
  otpValidated,    // OTP validated, got recovery token
  passwordReset,   // password was reset successfully
  consentResent,   // consent email resent
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  final String? token;
  final String? recoveryToken;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.token,
    this.recoveryToken,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? token,
    String? recoveryToken,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      token: token ?? this.token,
      recoveryToken: recoveryToken ?? this.recoveryToken,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, token, recoveryToken];
}
