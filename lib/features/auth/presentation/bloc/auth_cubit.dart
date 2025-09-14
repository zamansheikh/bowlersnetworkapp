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
    emit(AuthLoading());

    // Check if there's a persisted token
    final persistedToken = await authRepository.getPersistedToken();
    if (persistedToken == null) {
      emit(Unauthenticated());
      return;
    }

    // Try to get profile with the persisted token
    final result = await getProfile(NoParams());
    result.fold((failure) => emit(Unauthenticated()), (user) {
      // Check if user is UserModel and has isComplete field
      if (user is UserModel && !user.isComplete) {
        emit(AuthenticatedIncompleteProfile(token: persistedToken, user: user));
      } else {
        emit(Authenticated(token: persistedToken, user: user));
      }
    });
  }

  Future<void> signIn(String username, String password) async {
    emit(AuthLoading());
    final result = await login(
      LoginParams(username: username, password: password),
    );
    result.fold((failure) => emit(AuthError(failure.toString())), (
      token,
    ) async {
      final profileResult = await getProfile(NoParams());
      profileResult.fold((failure) => emit(AuthError(failure.toString())), (
        user,
      ) {
        // Check if user is UserModel and has isComplete field
        if (user is UserModel && !user.isComplete) {
          emit(AuthenticatedIncompleteProfile(token: token, user: user));
        } else {
          emit(Authenticated(token: token, user: user));
        }
      });
    });
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
}
