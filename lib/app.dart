import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/constants/app_constants.dart';
import 'core/di/injection.dart';
import 'core/localization/app_locale.dart';
import 'core/localization/locale_cubit.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'l10n/generated/app_localizations.dart';

class BowlersNetworkApp extends StatefulWidget {
  const BowlersNetworkApp({super.key});

  @override
  State<BowlersNetworkApp> createState() => _BowlersNetworkAppState();
}

class _BowlersNetworkAppState extends State<BowlersNetworkApp> {
  late final AuthBloc _authBloc = getIt<AuthBloc>();
  late final ProfileBloc _profileBloc = getIt<ProfileBloc>();
  late final _router = buildAppRouter(_authBloc);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>.value(value: getIt<LocaleCubit>()),
        BlocProvider<ThemeCubit>.value(value: getIt<ThemeCubit>()),
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<ProfileBloc>.value(value: _profileBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          // Bridge ProfileBloc → AuthBloc: once completion status is known,
          // tell AuthBloc so the router guard can lift the profile gate.
          BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (p, n) => p.isComplete != n.isComplete,
            listener: (context, state) {
              if (state.profile == null) return;
              if (state.isComplete) {
                _authBloc.add(const AuthProfileCompletionConfirmed());
              } else {
                _authBloc.add(const AuthProfileIncomplete());
              }
            },
          ),
          // Clear profile data on logout so the next user starts clean.
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (p, n) =>
                p.status != AuthStatus.unauthenticated &&
                n.status == AuthStatus.unauthenticated,
            listener: (_, _) => _profileBloc.add(const ProfileCleared()),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return BlocBuilder<LocaleCubit, AppLocale>(
              builder: (context, appLocale) {
                return ScreenUtilInit(
                  designSize: const Size(
                    AppConstants.designWidth,
                    AppConstants.designHeight,
                  ),
                  minTextAdapt: true,
                  splitScreenMode: true,
                  builder: (_, _) {
                    return MaterialApp.router(
                      title: AppConstants.appName,
                      debugShowCheckedModeBanner: false,
                      theme: AppTheme.light,
                      darkTheme: AppTheme.dark,
                      themeMode: themeMode,
                      locale: appLocale.locale,
                      supportedLocales: AppLocale.supportedLocales,
                      localizationsDelegates: const [
                        AppLocalizations.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                      routerConfig: _router,
                      builder: (context, child) {
                        final clamped = MediaQuery.of(context).copyWith(
                          textScaler: MediaQuery.textScalerOf(context)
                              .clamp(minScaleFactor: 0.9, maxScaleFactor: 1.3),
                        );
                        return MediaQuery(data: clamped, child: child!);
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
