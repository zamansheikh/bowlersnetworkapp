import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthState()) {
    on<AuthCheckStatusRequested>(_onCheckStatus);
    on<AuthVerifyEmailRequested>(_onVerifyEmail);
    on<AuthLoginRequested>(_onLogin);
    on<AuthSignupRequested>(_onSignup);
    on<AuthInitiateOtpRecovery>(_onInitiateOtpRecovery);
    on<AuthValidateOtp>(_onValidateOtp);
    on<AuthInitiateMagicLink>(_onInitiateMagicLink);
    on<AuthResetPassword>(_onResetPassword);
    on<AuthResendConsent>(_onResendConsent);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthClearError>(_onClearError);
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    final isAuth = await _authRepository.isAuthenticated();
    emit(state.copyWith(
      status: isAuth ? AuthStatus.authenticated : AuthStatus.unauthenticated,
    ));
  }

  Future<void> _onVerifyEmail(
    AuthVerifyEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _authRepository.verifyEmail(event.email);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: AuthStatus.emailSent)),
    );
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _authRepository.login(
      credential: event.credential,
      password: event.password,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      )),
      (authToken) {
        if (authToken.requiresConsent) {
          emit(state.copyWith(
            status: AuthStatus.consentRequired,
            token: authToken.token,
          ));
        } else {
          emit(state.copyWith(
            status: AuthStatus.authenticated,
            token: authToken.token,
          ));
        }
      },
    );
  }

  Future<void> _onSignup(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _authRepository.signup(
      firstName: event.firstName,
      lastName: event.lastName,
      username: event.username,
      email: event.email,
      password: event.password,
      verificationCode: event.verificationCode,
      dateOfBirth: event.dateOfBirth,
      parentEmail: event.parentEmail,
      isCoach: event.isCoach,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      )),
      (authToken) {
        if (authToken.requiresConsent) {
          emit(state.copyWith(
            status: AuthStatus.consentRequired,
            token: authToken.token,
          ));
        } else {
          emit(state.copyWith(
            status: AuthStatus.authenticated,
            token: authToken.token,
          ));
        }
      },
    );
  }

  Future<void> _onInitiateOtpRecovery(
    AuthInitiateOtpRecovery event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _authRepository.initiateOtpRecovery(event.email);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: AuthStatus.otpSent)),
    );
  }

  Future<void> _onValidateOtp(
    AuthValidateOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _authRepository.validateOtp(
      email: event.email,
      otp: event.otp,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      )),
      (authToken) => emit(state.copyWith(
        status: AuthStatus.otpValidated,
        recoveryToken: authToken.token,
      )),
    );
  }

  Future<void> _onInitiateMagicLink(
    AuthInitiateMagicLink event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _authRepository.initiateMagicLink(event.email);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: AuthStatus.magicLinkSent)),
    );
  }

  Future<void> _onResetPassword(
    AuthResetPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _authRepository.resetPassword(
      newPassword: event.newPassword,
      token: event.token,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: AuthStatus.passwordReset)),
    );
  }

  Future<void> _onResendConsent(
    AuthResendConsent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _authRepository.resendConsent();
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: AuthStatus.consentResent)),
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void _onClearError(
    AuthClearError event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(status: AuthStatus.initial, errorMessage: null));
  }
}
