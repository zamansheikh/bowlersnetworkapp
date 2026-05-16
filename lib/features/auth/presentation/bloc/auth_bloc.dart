import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/device_token_service.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/auth_dtos.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Drives the top-level authentication status of the app. The router listens
/// to this and redirects based on [AuthStatus].
@singleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._repository,
    this._login,
    this._completeSignup,
    this._logout,
    this._deviceTokens,
  ) : super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLogin);
    on<AuthSignupRequested>(_onSignup);
    on<AuthProfileCompletionConfirmed>(_onProfileConfirmed);
    on<AuthProfileIncomplete>(_onProfileIncomplete);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthSessionExpired>(_onSessionExpired);
  }

  final AuthRepository _repository;
  final LoginUseCase _login;
  final CompleteSignupUseCase _completeSignup;
  final LogoutUseCase _logout;
  final DeviceTokenService _deviceTokens;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final session = await _repository.restoreSession();
    if (session == null) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
      return;
    }
    emit(state.copyWith(
      // Default to fully [authenticated] — we only lock the user out of the
      // main app once [ProfileBloc] confirms `is_complete: false`. Gating
      // upfront caused users with complete profiles to get stranded on the
      // profile screen while the completion check was in flight.
      status: session.requiresConsent
          ? AuthStatus.requiresConsent
          : AuthStatus.authenticated,
      session: session,
    ));
    // Restored sessions still need a fresh FCM token registration — the old
    // one may have been rotated by the OS while we were logged out.
    unawaited(_deviceTokens.registerCurrentDevice());
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(processing: true, errors: const []));
    final result = await _login(
      LoginParams(credential: event.credential, password: event.password),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(processing: false, errors: failure.messages),
      ),
      (session) {
        emit(state.copyWith(
          processing: false,
          session: session,
          status: session.requiresConsent
              ? AuthStatus.requiresConsent
              : AuthStatus.authenticated,
        ));
        unawaited(_deviceTokens.registerCurrentDevice());
      },
    );
  }

  Future<void> _onSignup(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(processing: true, errors: const []));
    final result = await _completeSignup(SignupParams(
      data: event.data,
      verificationCode: event.verificationCode,
      favoriteBrandIds: event.favoriteBrandIds,
      referrerUsername: event.referrerUsername,
    ));
    result.fold(
      (failure) => emit(
        state.copyWith(processing: false, errors: failure.messages),
      ),
      (session) {
        emit(state.copyWith(
          processing: false,
          session: session,
          status: session.requiresConsent
              ? AuthStatus.requiresConsent
              : AuthStatus.authenticated,
        ));
        unawaited(_deviceTokens.registerCurrentDevice());
      },
    );
  }

  void _onProfileConfirmed(
    AuthProfileCompletionConfirmed event,
    Emitter<AuthState> emit,
  ) {
    if (state.session == null) return;
    emit(state.copyWith(status: AuthStatus.authenticated));
  }

  void _onProfileIncomplete(
    AuthProfileIncomplete event,
    Emitter<AuthState> emit,
  ) {
    if (state.session == null) return;
    emit(state.copyWith(status: AuthStatus.authenticatedUnverified));
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // MUST unregister before _logout clears the token — the request would
    // otherwise hit the backend with no auth and 401.
    await _deviceTokens.unregisterCurrentDevice();
    await _logout(const NoParams());
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    // Token is already invalid here — don't bother unregistering, just drop
    // the cached FCM token locally so the next login re-registers.
    await _deviceTokens.unregisterCurrentDevice();
    await _logout(const NoParams());
    emit(const AuthState(
      status: AuthStatus.unauthenticated,
      errors: ['Your session expired. Please log in again.'],
    ));
  }
}
