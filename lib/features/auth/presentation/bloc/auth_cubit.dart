import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/usecase.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../home/domain/entities/user.dart';
import '../../../home/data/models/user_model.dart';
import '../../domain/entities/auth_token.dart';

part 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final Login login;
  final GetProfile getProfile;
  final AuthRepository authRepository;

  AuthCubit(this.login, this.getProfile, this.authRepository)
    : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    debugPrint('🔍 Auth: Starting checkAuthStatus');
    emit(AuthLoading());

    // Check if there's a persisted token
    final persistedToken = await authRepository.getPersistedToken();
    debugPrint(
      '🔑 Auth: Persisted token: ${persistedToken != null ? 'EXISTS' : 'NONE'}',
    );

    if (persistedToken == null) {
      debugPrint('❌ Auth: No token found, emitting Unauthenticated');
      emit(Unauthenticated());
      return;
    }

    debugPrint('🔄 Auth: Getting profile with token');
    // Try to get profile with the persisted token
    final result = await getProfile(NoParams());
    result.fold(
      (failure) {
        debugPrint('❌ Auth: Get profile failed: $failure');
        emit(Unauthenticated());
      },
      (user) {
        debugPrint('✅ Auth: Profile retrieved successfully');
        // Check if user is UserModel and has isComplete field
        if (user is UserModel && !user.isComplete) {
          debugPrint(
            '📝 Auth: User profile incomplete, redirecting to completion',
          );
          emit(
            AuthenticatedIncompleteProfile(token: persistedToken, user: user),
          );
        } else {
          debugPrint('🏠 Auth: User authenticated, redirecting to home');
          emit(Authenticated(token: persistedToken, user: user));
        }
      },
    );
  }

  Future<void> signIn(String username, String password) async {
    debugPrint('🔐 Auth: Starting signIn');
    emit(AuthLoading());

    // Ensure minimum loading duration for better UX
    final stopwatch = Stopwatch()..start();

    debugPrint('🔐 Auth: Calling login API');
    final result = await login(
      LoginParams(username: username, password: password),
    );

    result.fold(
      (failure) {
        debugPrint('❌ Auth: Login failed: $failure');
        emit(AuthError(failure.toString()));
      },
      (token) async {
        debugPrint('✅ Auth: Login successful, fetching profile');
        final profileResult = await getProfile(NoParams());
        profileResult.fold(
          (failure) {
            debugPrint('❌ Auth: Get profile failed: $failure');
            emit(AuthError(failure.toString()));
          },
          (user) async {
            debugPrint('✅ Auth: Profile fetched successfully');

            // Ensure minimum loading time of 800ms for better UX
            final elapsed = stopwatch.elapsedMilliseconds;
            if (elapsed < 800) {
              final remaining = 800 - elapsed;
              debugPrint('⏳ Auth: Waiting ${remaining}ms for better UX');
              await Future.delayed(Duration(milliseconds: remaining));
            }

            // Check if user is UserModel and has isComplete field
            if (user is UserModel && !user.isComplete) {
              debugPrint(
                '📝 Auth: Profile incomplete, redirecting to completion',
              );
              emit(AuthenticatedIncompleteProfile(token: token, user: user));
            } else {
              debugPrint(
                '🏠 Auth: Authentication complete, redirecting to home',
              );
              emit(Authenticated(token: token, user: user));
            }
          },
        );
      },
    );
  }

  Future<void> logout() async {
    await authRepository.logout();
    emit(Unauthenticated());
  }

  void completeProfile() {
    if (state is AuthenticatedIncompleteProfile) {
      final currentState = state as AuthenticatedIncompleteProfile;
      emit(Authenticated(token: currentState.token, user: currentState.user));
    }
  }

  Future<void> deleteAccount(String username) async {
    emit(AuthLoading());
    try {
      final result = await authRepository.deleteAccount(username);
      result.fold((failure) => emit(AuthError(failure.toString())), (_) {
        // Account successfully deleted, tokens are already cleared in repository
        // Emit AccountDeleted state which will trigger navigation to signin
        emit(AccountDeleted());
      });
    } catch (e) {
      emit(AuthError('Failed to delete account: $e'));
    }
  }
}
