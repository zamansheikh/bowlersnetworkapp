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
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/newsfeed/data/datasources/newsfeed_remote_datasource.dart'
    as _i452;
import '../../features/newsfeed/data/repositories/newsfeed_repository_impl.dart'
    as _i306;
import '../../features/newsfeed/domain/repositories/newsfeed_repository.dart'
    as _i819;
import '../../features/newsfeed/presentation/bloc/feed_bloc.dart' as _i920;
import '../../features/profile/data/datasources/profile_remote_datasource.dart'
    as _i327;
import '../../features/profile/data/repositories/profile_repository_impl.dart'
    as _i334;
import '../../features/profile/domain/repositories/profile_repository.dart'
    as _i894;
import '../../features/profile/presentation/bloc/profile_bloc.dart' as _i469;
import '../../features/profile/presentation/cubits/profile_wizard_cubit.dart'
    as _i187;
import '../network/api_client.dart' as _i557;
import '../services/cloud_upload_service.dart' as _i984;
import '../storage/local_storage_service.dart' as _i744;
import '../storage/secure_storage_service.dart' as _i666;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i744.LocalStorageService>(
      () => _i744.LocalStorageService(),
    );
    gh.lazySingleton<_i666.SecureStorageService>(
      () => _i666.SecureStorageService(),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.dio(gh<_i666.SecureStorageService>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.uploadDio(),
      instanceName: 'uploadDio',
    );
    gh.lazySingleton<_i161.AuthRemoteDataSource>(
      () => _i161.AuthRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i452.NewsfeedRemoteDataSource>(
      () => _i452.NewsfeedRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i327.ProfileRemoteDataSource>(
      () => _i327.ProfileRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i984.CloudUploadService>(
      () => _i984.CloudUploadService(
        gh<_i361.Dio>(),
        gh<_i361.Dio>(instanceName: 'uploadDio'),
      ),
    );
    gh.lazySingleton<_i894.ProfileRepository>(
      () => _i334.ProfileRepositoryImpl(
        gh<_i327.ProfileRemoteDataSource>(),
        gh<_i984.CloudUploadService>(),
      ),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i161.AuthRemoteDataSource>(),
        gh<_i666.SecureStorageService>(),
      ),
    );
    gh.factory<_i797.AuthBloc>(
      () => _i797.AuthBloc(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i819.NewsfeedRepository>(
      () => _i306.NewsfeedRepositoryImpl(gh<_i452.NewsfeedRemoteDataSource>()),
    );
    gh.factory<_i469.ProfileBloc>(
      () => _i469.ProfileBloc(gh<_i894.ProfileRepository>()),
    );
    gh.factory<_i187.ProfileWizardCubit>(
      () => _i187.ProfileWizardCubit(gh<_i894.ProfileRepository>()),
    );
    gh.factory<_i920.FeedBloc>(
      () => _i920.FeedBloc(gh<_i819.NewsfeedRepository>()),
    );
    return this;
  }
}

class _$NetworkModule extends _i557.NetworkModule {}
