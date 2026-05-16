// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/datasources/auth_remote_datasource.dart'
    as _i161;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i48;
import '../../features/auth/domain/usecases/password_recovery_usecases.dart'
    as _i38;
import '../../features/auth/domain/usecases/send_email_verification_usecase.dart'
    as _i707;
import '../../features/auth/domain/usecases/signup_usecase.dart' as _i57;
import '../../features/auth/domain/usecases/validate_registration_usecase.dart'
    as _i416;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/follow/data/datasources/follow_remote_datasource.dart'
    as _i973;
import '../../features/follow/data/repositories/follow_repository_impl.dart'
    as _i299;
import '../../features/follow/domain/repositories/follow_repository.dart'
    as _i760;
import '../../features/games/data/datasources/games_remote_datasource.dart'
    as _i771;
import '../../features/games/data/repositories/games_repository_impl.dart'
    as _i438;
import '../../features/games/domain/repositories/games_repository.dart'
    as _i604;
import '../../features/games/presentation/bloc/equipment_bloc.dart' as _i789;
import '../../features/games/presentation/bloc/games_bloc.dart' as _i974;
import '../../features/games/presentation/bloc/stats_bloc.dart' as _i377;
import '../../features/leaderboard/data/datasources/leaderboard_remote_datasource.dart'
    as _i757;
import '../../features/leaderboard/data/repositories/leaderboard_repository_impl.dart'
    as _i1008;
import '../../features/leaderboard/domain/repositories/leaderboard_repository.dart'
    as _i655;
import '../../features/leaderboard/presentation/bloc/leaderboard_bloc.dart'
    as _i957;
import '../../features/messages/data/datasources/messages_remote_datasource.dart'
    as _i182;
import '../../features/messages/data/repositories/messages_repository_impl.dart'
    as _i20;
import '../../features/messages/domain/repositories/messages_repository.dart'
    as _i794;
import '../../features/messages/presentation/bloc/conversations_bloc.dart'
    as _i454;
import '../../features/newsfeed/data/datasources/newsfeed_remote_datasource.dart'
    as _i452;
import '../../features/newsfeed/data/repositories/newsfeed_repository_impl.dart'
    as _i306;
import '../../features/newsfeed/domain/repositories/newsfeed_repository.dart'
    as _i819;
import '../../features/newsfeed/domain/usecases/feed_usecases.dart' as _i22;
import '../../features/newsfeed/presentation/bloc/feed_bloc.dart' as _i920;
import '../../features/notifications/data/datasources/notifications_remote_datasource.dart'
    as _i937;
import '../../features/onboarding/data/onboarding_storage.dart' as _i861;
import '../../features/profile/data/datasources/profile_remote_datasource.dart'
    as _i327;
import '../../features/profile/data/repositories/profile_repository_impl.dart'
    as _i334;
import '../../features/profile/domain/repositories/profile_repository.dart'
    as _i894;
import '../../features/profile/domain/usecases/get_my_profile_usecase.dart'
    as _i981;
import '../../features/profile/presentation/bloc/profile_bloc.dart' as _i469;
import '../localization/locale_cubit.dart' as _i960;
import '../network/api_client.dart' as _i557;
import '../network/chat_socket.dart' as _i943;
import '../services/cloud_upload_service.dart' as _i984;
import '../services/device_token_service.dart' as _i914;
import '../services/image_picker_service.dart' as _i644;
import '../storage/local_storage_service.dart' as _i744;
import '../storage/secure_storage_service.dart' as _i666;
import '../theme/theme_cubit.dart' as _i611;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i644.ImagePickerService>(
      () => _i644.ImagePickerService(),
    );
    gh.lazySingleton<_i744.LocalStorageService>(
      () => _i744.LocalStorageService(),
    );
    gh.lazySingleton<_i666.SecureStorageService>(
      () => _i666.SecureStorageService(),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.dio(gh<_i666.SecureStorageService>()),
    );
    gh.lazySingleton<_i960.LocaleCubit>(
      () => _i960.LocaleCubit(gh<_i744.LocalStorageService>()),
    );
    gh.lazySingleton<_i611.ThemeCubit>(
      () => _i611.ThemeCubit(gh<_i744.LocalStorageService>()),
    );
    gh.lazySingleton<_i861.OnboardingStorage>(
      () => _i861.OnboardingStorage(gh<_i744.LocalStorageService>()),
    );
    gh.factory<_i161.AuthRemoteDatasource>(
      () => _i161.AuthRemoteDatasource(gh<_i361.Dio>()),
    );
    gh.factory<_i973.FollowRemoteDatasource>(
      () => _i973.FollowRemoteDatasource(gh<_i361.Dio>()),
    );
    gh.factory<_i771.GamesRemoteDatasource>(
      () => _i771.GamesRemoteDatasource(gh<_i361.Dio>()),
    );
    gh.factory<_i757.LeaderboardRemoteDatasource>(
      () => _i757.LeaderboardRemoteDatasource(gh<_i361.Dio>()),
    );
    gh.factory<_i182.MessagesRemoteDatasource>(
      () => _i182.MessagesRemoteDatasource(gh<_i361.Dio>()),
    );
    gh.factory<_i452.NewsfeedRemoteDatasource>(
      () => _i452.NewsfeedRemoteDatasource(gh<_i361.Dio>()),
    );
    gh.factory<_i937.NotificationsRemoteDatasource>(
      () => _i937.NotificationsRemoteDatasource(gh<_i361.Dio>()),
    );
    gh.factory<_i327.ProfileRemoteDatasource>(
      () => _i327.ProfileRemoteDatasource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.uploadDio(),
      instanceName: 'uploadDio',
    );
    gh.lazySingleton<_i794.MessagesRepository>(
      () => _i20.MessagesRepositoryImpl(gh<_i182.MessagesRemoteDatasource>()),
    );
    gh.lazySingleton<_i984.CloudUploadService>(
      () => _i984.CloudUploadService(
        gh<_i361.Dio>(),
        gh<_i361.Dio>(instanceName: 'uploadDio'),
      ),
    );
    gh.lazySingleton<_i604.GamesRepository>(
      () => _i438.GamesRepositoryImpl(gh<_i771.GamesRemoteDatasource>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i161.AuthRemoteDatasource>(),
        gh<_i666.SecureStorageService>(),
        gh<_i744.LocalStorageService>(),
      ),
    );
    gh.factory<_i789.EquipmentBloc>(
      () => _i789.EquipmentBloc(gh<_i604.GamesRepository>()),
    );
    gh.factory<_i974.GamesBloc>(
      () => _i974.GamesBloc(gh<_i604.GamesRepository>()),
    );
    gh.factory<_i377.StatsBloc>(
      () => _i377.StatsBloc(gh<_i604.GamesRepository>()),
    );
    gh.lazySingleton<_i819.NewsfeedRepository>(
      () => _i306.NewsfeedRepositoryImpl(gh<_i452.NewsfeedRemoteDatasource>()),
    );
    gh.lazySingleton<_i914.DeviceTokenService>(
      () => _i914.DeviceTokenService(gh<_i937.NotificationsRemoteDatasource>()),
    );
    gh.lazySingleton<_i943.ChatSocket>(
      () => _i943.ChatSocket(gh<_i666.SecureStorageService>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i655.LeaderboardRepository>(
      () => _i1008.LeaderboardRepositoryImpl(
        gh<_i757.LeaderboardRemoteDatasource>(),
      ),
    );
    gh.lazySingleton<_i760.FollowRepository>(
      () => _i299.FollowRepositoryImpl(gh<_i973.FollowRemoteDatasource>()),
    );
    gh.lazySingleton<_i894.ProfileRepository>(
      () => _i334.ProfileRepositoryImpl(gh<_i327.ProfileRemoteDatasource>()),
    );
    gh.lazySingleton<_i188.LoginUseCase>(
      () => _i188.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i48.LogoutUseCase>(
      () => _i48.LogoutUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i38.InitiateRecoveryOtpUseCase>(
      () => _i38.InitiateRecoveryOtpUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i38.ValidateRecoveryOtpUseCase>(
      () => _i38.ValidateRecoveryOtpUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i38.ResetPasswordUseCase>(
      () => _i38.ResetPasswordUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i707.SubmitSignupUseCase>(
      () => _i707.SubmitSignupUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i57.CompleteSignupUseCase>(
      () => _i57.CompleteSignupUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i416.ValidateRegistrationUseCase>(
      () => _i416.ValidateRegistrationUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i957.LeaderboardBloc>(
      () => _i957.LeaderboardBloc(gh<_i655.LeaderboardRepository>()),
    );
    gh.factory<_i454.ConversationsBloc>(
      () => _i454.ConversationsBloc(
        gh<_i794.MessagesRepository>(),
        gh<_i943.ChatSocket>(),
      ),
    );
    gh.singleton<_i797.AuthBloc>(
      () => _i797.AuthBloc(
        gh<_i787.AuthRepository>(),
        gh<_i188.LoginUseCase>(),
        gh<_i57.CompleteSignupUseCase>(),
        gh<_i48.LogoutUseCase>(),
        gh<_i914.DeviceTokenService>(),
      ),
    );
    gh.lazySingleton<_i22.GetFeedUseCase>(
      () => _i22.GetFeedUseCase(gh<_i819.NewsfeedRepository>()),
    );
    gh.lazySingleton<_i22.ReactToPostUseCase>(
      () => _i22.ReactToPostUseCase(gh<_i819.NewsfeedRepository>()),
    );
    gh.lazySingleton<_i22.ToggleSavePostUseCase>(
      () => _i22.ToggleSavePostUseCase(gh<_i819.NewsfeedRepository>()),
    );
    gh.lazySingleton<_i22.HidePostUseCase>(
      () => _i22.HidePostUseCase(gh<_i819.NewsfeedRepository>()),
    );
    gh.lazySingleton<_i22.SharePostUseCase>(
      () => _i22.SharePostUseCase(gh<_i819.NewsfeedRepository>()),
    );
    gh.factory<_i920.FeedBloc>(
      () => _i920.FeedBloc(
        gh<_i22.GetFeedUseCase>(),
        gh<_i22.ReactToPostUseCase>(),
        gh<_i22.ToggleSavePostUseCase>(),
        gh<_i22.HidePostUseCase>(),
        gh<_i22.SharePostUseCase>(),
        gh<_i819.NewsfeedRepository>(),
        gh<_i760.FollowRepository>(),
      ),
    );
    gh.lazySingleton<_i469.ProfileBloc>(
      () => _i469.ProfileBloc(
        gh<_i894.ProfileRepository>(),
        gh<_i984.CloudUploadService>(),
      ),
    );
    gh.lazySingleton<_i981.GetMyProfileUseCase>(
      () => _i981.GetMyProfileUseCase(gh<_i894.ProfileRepository>()),
    );
    gh.lazySingleton<_i981.CheckProfileCompletionUseCase>(
      () => _i981.CheckProfileCompletionUseCase(gh<_i894.ProfileRepository>()),
    );
    return this;
  }
}

class _$NetworkModule extends _i557.NetworkModule {}
