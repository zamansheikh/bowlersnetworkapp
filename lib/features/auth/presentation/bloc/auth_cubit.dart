import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/usecase.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/get_profile.dart';
import '../../../home/domain/entities/user.dart';
import '../../domain/entities/auth_token.dart';

part 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final Login login;
  final GetProfile getProfile;

  AuthCubit(this.login, this.getProfile) : super(AuthInitial());

  Future<void> signIn(String username, String password) async {
    emit(AuthLoading());
    final result = await login(
      LoginParams(username: username, password: password),
    );
    result.fold((failure) => emit(AuthError(failure.toString())), (
      token,
    ) async {
      final profileResult = await getProfile(NoParams());
      profileResult.fold(
        (failure) => emit(AuthError(failure.toString())),
        (user) => emit(Authenticated(token: token, user: user)),
      );
    });
  }

  void logout() {
    emit(Unauthenticated());
  }
}
