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

import '../../features/onboarding/data/onboarding_storage.dart' as _i861;
import '../localization/locale_cubit.dart' as _i960;
import '../network/api_client.dart' as _i557;
import '../services/cloud_upload_service.dart' as _i984;
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
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.uploadDio(),
      instanceName: 'uploadDio',
    );
    gh.lazySingleton<_i984.CloudUploadService>(
      () => _i984.CloudUploadService(
        gh<_i361.Dio>(),
        gh<_i361.Dio>(instanceName: 'uploadDio'),
      ),
    );
    return this;
  }
}

class _$NetworkModule extends _i557.NetworkModule {}
