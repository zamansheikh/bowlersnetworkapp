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
import 'l10n/generated/app_localizations.dart';

class BowlersNetworkApp extends StatelessWidget {
  const BowlersNetworkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>.value(value: getIt<LocaleCubit>()),
        BlocProvider<ThemeCubit>.value(value: getIt<ThemeCubit>()),
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
                    routerConfig: appRouter,
                    builder: (context, child) {
                      // Clamp text scaling to prevent extreme system sizes
                      // from breaking layouts (per design spec, cap at 1.3x).
                      final clamped = MediaQuery.of(context).copyWith(
                        textScaler: MediaQuery.textScalerOf(
                          context,
                        ).clamp(minScaleFactor: 0.9, maxScaleFactor: 1.3),
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
    );
  }
}
