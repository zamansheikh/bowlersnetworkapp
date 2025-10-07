import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/validate_signup_data_request.dart';
import '../../data/models/send_verification_code_request.dart';
import '../../data/models/verify_email_request.dart';
import '../../data/models/create_user_request.dart';
import '../../domain/usecases/validate_signup_data.dart';
import '../../domain/usecases/send_verification_code.dart';
import '../../domain/usecases/verify_email.dart';
import '../../domain/usecases/create_user.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/get_profile.dart';
import '../../../../core/utils/usecase.dart';
import '../../../home/data/models/user_model.dart';

part 'signup_state.dart';

@injectable
class SignupCubit extends Cubit<SignupState> {
  final ValidateSignupData validateSignupData;
  final SendVerificationCode sendVerificationCode;
  final VerifyEmail verifyEmail;
  final CreateUser createUser;
  final Login login;
  final GetProfile getProfile;

  SignupCubit(
    this.validateSignupData,
    this.sendVerificationCode,
    this.verifyEmail,
    this.createUser,
    this.login,
    this.getProfile,
  ) : super(SignupInitial());

  Future<void> validateData({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    emit(SignupLoading());

    final request = ValidateSignupDataRequest(
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      password: password,
    );

    final result = await validateSignupData(request);
    result.fold((failure) => emit(SignupError(failure.toString())), (response) {
      if (response.isValid) {
        emit(SignupDataValid());
      } else {
        emit(SignupDataInvalid(response.errors ?? []));
      }
    });
  }

  Future<void> sendEmailVerification(String email) async {
    emit(SignupLoading());

    final request = SendVerificationCodeRequest(email: email);
    final result = await sendVerificationCode(request);

    result.fold(
      (failure) => emit(SignupError(failure.toString())),
      (response) => emit(VerificationCodeSent(response.message)),
    );
  }

  Future<void> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    emit(SignupLoading());

    // Ensure minimum loading duration for better UX
    final stopwatch = Stopwatch()..start();

    final request = VerifyEmailRequest(email: email, code: code);
    final result = await verifyEmail(request);

    result.fold(
      (failure) {
        emit(SignupError(failure.toString()));
      },
      (response) async {
        // Ensure minimum loading time of 600ms for better UX
        final elapsed = stopwatch.elapsedMilliseconds;
        if (elapsed < 600) {
          await Future.delayed(Duration(milliseconds: 600 - elapsed));
        }

        if (response.success) {
          emit(EmailVerified());
        } else {
          emit(SignupError(response.message ?? 'Email verification failed'));
        }
      },
    );
  }

  Future<void> createUserAccount({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String birthDate,
    List<int> brandIDs = const [],
  }) async {
    emit(SignupLoading());

    final basicInfo = BasicInfo(
      username: username,
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      birthDate: birthDate,
    );

    final request = CreateUserRequest(basicInfo: basicInfo, brandIDs: brandIDs);

    final result = await createUser(request);
    result.fold((failure) => emit(SignupError(failure.toString())), (
      response,
    ) async {
      if (response.success) {
        // Auto-login after successful user creation
        await _autoLogin(username, password);
      } else {
        emit(SignupError(response.message ?? 'User creation failed'));
      }
    });
  }

  Future<void> _autoLogin(String username, String password) async {
    final loginResult = await login(
      LoginParams(username: username, password: password),
    );

    loginResult.fold(
      (failure) => emit(
        SignupError('Account created but login failed: ${failure.toString()}'),
      ),
      (token) async {
        final profileResult = await getProfile(NoParams());
        profileResult.fold(
          (failure) => emit(
            SignupError(
              'Login successful but failed to get profile: ${failure.toString()}',
            ),
          ),
          (user) {
            // Check if user is UserModel and has isComplete field
            if (user is UserModel && !user.isComplete) {
              emit(
                SignupLoginIncompleteProfile(
                  token: token.accessToken,
                  user: user,
                ),
              );
            } else if (user is UserModel) {
              emit(SignupLoginSuccess(token: token.accessToken, user: user));
            } else {
              emit(SignupError('Invalid user data received'));
            }
          },
        );
      },
    );
  }

  void reset() {
    emit(SignupInitial());
  }
}
