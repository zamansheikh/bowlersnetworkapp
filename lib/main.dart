import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/strings.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = getIt<AuthCubit>();
    final router = AppRouter.create(authCubit);
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (_) => getIt<HomeBloc>()..add(LoadHome()),
        ),
        BlocProvider<AuthCubit>(create: (_) => authCubit),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
