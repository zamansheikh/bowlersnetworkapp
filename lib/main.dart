import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/strings.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/auth/presentation/bloc/signup_cubit.dart';
import 'features/home/presentation/cubit/feed_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthCubit authCubit;
  late final GoRouter router;

  @override
  void initState() {
    super.initState();
    authCubit = getIt<AuthCubit>();
    router = AppRouter.create(authCubit);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (_) => getIt<HomeBloc>()..add(LoadHome()),
        ),
        BlocProvider<AuthCubit>(create: (_) => authCubit),
        BlocProvider<SignupCubit>(create: (_) => getIt<SignupCubit>()),
        // Provide FeedCubit globally to prevent recreation
        BlocProvider<FeedCubit>(create: (_) => getIt<FeedCubit>()),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
