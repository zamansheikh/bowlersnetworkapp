part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckStatusRequested extends AuthEvent {
  const AuthCheckStatusRequested();
}

class AuthVerifyEmailRequested extends AuthEvent {
  final String email;
  const AuthVerifyEmailRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthLoginRequested extends AuthEvent {
  final String credential;
  final String password;

  const AuthLoginRequested({required this.credential, required this.password});

  @override
  List<Object?> get props => [credential, password];
}

class AuthSignupRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String password;
  final String verificationCode;
  final String dateOfBirth;
  final String? parentEmail;
  final bool? isCoach;

  const AuthSignupRequested({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.password,
    required this.verificationCode,
    required this.dateOfBirth,
    this.parentEmail,
    this.isCoach,
  });

  @override
  List<Object?> get props => [firstName, lastName, username, email, password,
    verificationCode, dateOfBirth, parentEmail, isCoach];
}

class AuthInitiateOtpRecovery extends AuthEvent {
  final String email;
  const AuthInitiateOtpRecovery({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthValidateOtp extends AuthEvent {
  final String email;
  final String otp;
  const AuthValidateOtp({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class AuthInitiateMagicLink extends AuthEvent {
  final String email;
  const AuthInitiateMagicLink({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthResetPassword extends AuthEvent {
  final String newPassword;
  final String token;
  const AuthResetPassword({required this.newPassword, required this.token});

  @override
  List<Object?> get props => [newPassword, token];
}

class AuthResendConsent extends AuthEvent {
  const AuthResendConsent();
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthClearError extends AuthEvent {
  const AuthClearError();
}
