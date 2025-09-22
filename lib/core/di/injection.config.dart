// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:bowlersnetworkapp/core/di/prefs_module.dart' as _i47;
import 'package:bowlersnetworkapp/core/network/network_info.dart' as _i149;
import 'package:bowlersnetworkapp/core/network/network_module.dart' as _i516;
import 'package:bowlersnetworkapp/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i1073;
import 'package:bowlersnetworkapp/features/auth/data/datasources/brands_remote_data_source.dart'
    as _i394;
import 'package:bowlersnetworkapp/features/auth/data/datasources/brands_remote_data_source_impl.dart'
    as _i483;
import 'package:bowlersnetworkapp/features/auth/data/repositories/auth_repository_impl.dart'
    as _i359;
import 'package:bowlersnetworkapp/features/auth/domain/repositories/auth_repository.dart'
    as _i994;
import 'package:bowlersnetworkapp/features/auth/domain/usecases/create_user.dart'
    as _i762;
import 'package:bowlersnetworkapp/features/auth/domain/usecases/get_profile.dart'
    as _i298;
import 'package:bowlersnetworkapp/features/auth/domain/usecases/login.dart'
    as _i459;
import 'package:bowlersnetworkapp/features/auth/domain/usecases/send_verification_code.dart'
    as _i182;
import 'package:bowlersnetworkapp/features/auth/domain/usecases/validate_signup_data.dart'
    as _i920;
import 'package:bowlersnetworkapp/features/auth/domain/usecases/verify_email.dart'
    as _i546;
import 'package:bowlersnetworkapp/features/auth/presentation/bloc/auth_cubit.dart'
    as _i506;
import 'package:bowlersnetworkapp/features/auth/presentation/bloc/signup_cubit.dart'
    as _i384;
import 'package:bowlersnetworkapp/features/auth/presentation/cubit/profile_completion_cubit.dart'
    as _i605;
import 'package:bowlersnetworkapp/features/events/data/datasources/events_remote_data_source.dart'
    as _i421;
import 'package:bowlersnetworkapp/features/events/data/datasources/events_remote_data_source_impl.dart'
    as _i154;
import 'package:bowlersnetworkapp/features/events/data/repositories/events_repository_impl.dart'
    as _i686;
import 'package:bowlersnetworkapp/features/events/domain/repositories/events_repository.dart'
    as _i924;
import 'package:bowlersnetworkapp/features/events/domain/usecases/get_calendar_events.dart'
    as _i956;
import 'package:bowlersnetworkapp/features/events/domain/usecases/get_tournaments.dart'
    as _i116;
import 'package:bowlersnetworkapp/features/events/presentation/cubit/events_cubit.dart'
    as _i415;
import 'package:bowlersnetworkapp/features/home/data/datasources/user_remote_data_source.dart'
    as _i528;
import 'package:bowlersnetworkapp/features/home/data/repositories/feed_repository.dart'
    as _i535;
import 'package:bowlersnetworkapp/features/home/data/repositories/user_repository_impl.dart'
    as _i224;
import 'package:bowlersnetworkapp/features/home/domain/repositories/user_repository.dart'
    as _i637;
import 'package:bowlersnetworkapp/features/home/domain/usecases/get_users.dart'
    as _i450;
import 'package:bowlersnetworkapp/features/home/presentation/bloc/home_bloc.dart'
    as _i229;
import 'package:bowlersnetworkapp/features/home/presentation/cubit/feed_cubit.dart'
    as _i813;
import 'package:bowlersnetworkapp/features/messages/data/datasources/messages_remote_data_source.dart'
    as _i154;
import 'package:bowlersnetworkapp/features/messages/data/repositories/messages_repository_impl.dart'
    as _i528;
import 'package:bowlersnetworkapp/features/messages/domain/repositories/messages_repository.dart'
    as _i599;
import 'package:bowlersnetworkapp/features/messages/presentation/cubit/messages_cubit.dart'
    as _i146;
import 'package:bowlersnetworkapp/features/overview/data/datasources/overview_remote_data_source.dart'
    as _i946;
import 'package:bowlersnetworkapp/features/overview/data/repositories/overview_repository_impl.dart'
    as _i659;
import 'package:bowlersnetworkapp/features/overview/presentation/cubit/overview_cubit.dart'
    as _i547;
import 'package:bowlersnetworkapp/features/pro_players/data/datasources/pro_players_remote_data_source.dart'
    as _i607;
import 'package:bowlersnetworkapp/features/pro_players/data/repositories/pro_players_repository_impl.dart'
    as _i290;
import 'package:bowlersnetworkapp/features/pro_players/domain/repositories/pro_players_repository.dart'
    as _i1062;
import 'package:bowlersnetworkapp/features/pro_players/domain/usecases/pro_players_usecases.dart'
    as _i74;
import 'package:bowlersnetworkapp/features/pro_players/presentation/cubit/pro_players_cubit.dart'
    as _i565;
import 'package:bowlersnetworkapp/features/profile/presentation/cubit/profile_cubit.dart'
    as _i341;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final prefsModule = _$PrefsModule();
    final networkModule = _$NetworkModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => prefsModule.prefs,
      preResolve: true,
    );
    gh.factory<_i229.HomeBloc>(() => _i229.HomeBloc());
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i528.UserRemoteDataSource>(
      () => _i528.UserRemoteDataSourceImpl(),
    );
    gh.lazySingleton<_i607.ProPlayersRemoteDataSource>(
      () => _i607.ProPlayersRemoteDataSourceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i149.NetworkInfo>(() => _i149.NetworkInfoImpl());
    gh.factory<_i535.FeedRepository>(
      () => _i535.FeedRepository(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i946.OverviewRemoteDataSource>(
      () => _i946.OverviewRemoteDataSourceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i394.BrandsRemoteDataSource>(
      () => _i483.BrandsRemoteDataSourceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i341.ProfileCubit>(() => _i341.ProfileCubit(gh<_i361.Dio>()));
    gh.factory<_i813.FeedCubit>(
      () => _i813.FeedCubit(repository: gh<_i535.FeedRepository>()),
    );
    gh.lazySingleton<_i1073.AuthRemoteDataSource>(
      () => _i1073.AuthRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i154.MessagesRemoteDataSource>(
      () => _i154.MessagesRemoteDataSourceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i421.EventsRemoteDataSource>(
      () => _i154.EventsRemoteDataSourceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i659.OverviewRepository>(
      () => _i659.OverviewRepositoryImpl(gh<_i946.OverviewRemoteDataSource>()),
    );
    gh.lazySingleton<_i637.UserRepository>(
      () => _i224.UserRepositoryImpl(
        remoteDataSource: gh<_i528.UserRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i1062.ProPlayersRepository>(
      () => _i290.ProPlayersRepositoryImpl(
        gh<_i607.ProPlayersRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i599.MessagesRepository>(
      () => _i528.MessagesRepositoryImpl(gh<_i154.MessagesRemoteDataSource>()),
    );
    gh.lazySingleton<_i924.EventsRepository>(
      () => _i686.EventsRepositoryImpl(
        remoteDataSource: gh<_i421.EventsRemoteDataSource>(),
      ),
    );
    gh.factory<_i450.GetUsers>(
      () => _i450.GetUsers(gh<_i637.UserRepository>()),
    );
    gh.factory<_i547.OverviewCubit>(
      () => _i547.OverviewCubit(gh<_i659.OverviewRepository>()),
    );
    gh.lazySingleton<_i994.AuthRepository>(
      () => _i359.AuthRepositoryImpl(
        remote: gh<_i1073.AuthRemoteDataSource>(),
        prefs: gh<_i460.SharedPreferences>(),
      ),
    );
    gh.factory<_i146.MessagesCubit>(
      () => _i146.MessagesCubit(gh<_i599.MessagesRepository>()),
    );
    gh.factory<_i762.CreateUser>(
      () => _i762.CreateUser(gh<_i994.AuthRepository>()),
    );
    gh.factory<_i298.GetProfile>(
      () => _i298.GetProfile(gh<_i994.AuthRepository>()),
    );
    gh.factory<_i459.Login>(() => _i459.Login(gh<_i994.AuthRepository>()));
    gh.factory<_i182.SendVerificationCode>(
      () => _i182.SendVerificationCode(gh<_i994.AuthRepository>()),
    );
    gh.factory<_i920.ValidateSignupData>(
      () => _i920.ValidateSignupData(gh<_i994.AuthRepository>()),
    );
    gh.factory<_i546.VerifyEmail>(
      () => _i546.VerifyEmail(gh<_i994.AuthRepository>()),
    );
    gh.factory<_i605.ProfileCompletionCubit>(
      () => _i605.ProfileCompletionCubit(
        gh<_i394.BrandsRemoteDataSource>(),
        gh<_i994.AuthRepository>(),
      ),
    );
    gh.factory<_i506.AuthCubit>(
      () => _i506.AuthCubit(
        gh<_i459.Login>(),
        gh<_i298.GetProfile>(),
        gh<_i994.AuthRepository>(),
      ),
    );
    gh.factory<_i74.GetProPlayers>(
      () => _i74.GetProPlayers(gh<_i1062.ProPlayersRepository>()),
    );
    gh.factory<_i74.GetProPlayerById>(
      () => _i74.GetProPlayerById(gh<_i1062.ProPlayersRepository>()),
    );
    gh.factory<_i74.FollowPlayer>(
      () => _i74.FollowPlayer(gh<_i1062.ProPlayersRepository>()),
    );
    gh.factory<_i74.UnfollowPlayer>(
      () => _i74.UnfollowPlayer(gh<_i1062.ProPlayersRepository>()),
    );
    gh.factory<_i384.SignupCubit>(
      () => _i384.SignupCubit(
        gh<_i920.ValidateSignupData>(),
        gh<_i182.SendVerificationCode>(),
        gh<_i546.VerifyEmail>(),
        gh<_i762.CreateUser>(),
        gh<_i459.Login>(),
        gh<_i298.GetProfile>(),
      ),
    );
    gh.factory<_i956.GetCalendarEvents>(
      () => _i956.GetCalendarEvents(gh<_i924.EventsRepository>()),
    );
    gh.factory<_i116.GetTournaments>(
      () => _i116.GetTournaments(gh<_i924.EventsRepository>()),
    );
    gh.factory<_i415.EventsCubit>(
      () => _i415.EventsCubit(
        getTournaments: gh<_i116.GetTournaments>(),
        getCalendarEvents: gh<_i956.GetCalendarEvents>(),
      ),
    );
    gh.factory<_i565.ProPlayersCubit>(
      () => _i565.ProPlayersCubit(
        gh<_i74.GetProPlayers>(),
        gh<_i74.GetProPlayerById>(),
        gh<_i74.FollowPlayer>(),
        gh<_i74.UnfollowPlayer>(),
        gh<_i607.ProPlayersRemoteDataSource>(),
      ),
    );
    return this;
  }
}

class _$PrefsModule extends _i47.PrefsModule {}

class _$NetworkModule extends _i516.NetworkModule {}
