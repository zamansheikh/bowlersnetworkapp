part of 'signup_cubit.dart';

abstract class SignupState {
  const SignupState();
}

class SignupInitial extends SignupState {}

class SignupLoading extends SignupState {}

class SignupError extends SignupState {
  final String message;
  const SignupError(this.message);
}

class SignupDataValid extends SignupState {}

class SignupDataInvalid extends SignupState {
  final List<String> errors;
  const SignupDataInvalid(this.errors);
}

class VerificationCodeSent extends SignupState {
  final String message;
  const VerificationCodeSent(this.message);
}

class EmailVerified extends SignupState {}

class UserCreated extends SignupState {
  final int? userId;
  const UserCreated(this.userId);
}

class SignupLoginSuccess extends SignupState {
  final String token;
  final UserModel user;
  const SignupLoginSuccess({required this.token, required this.user});
}

class SignupLoginIncompleteProfile extends SignupState {
  final String token;
  final UserModel user;
  const SignupLoginIncompleteProfile({required this.token, required this.user});
}
