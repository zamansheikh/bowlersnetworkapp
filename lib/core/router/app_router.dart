import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/profile/presentation/pages/user_profile_page.dart';

class AppRouter {
  static GoRouter create(AuthCubit authCubit) {
    return GoRouter(
      redirect: (context, state) {
        final isAuth = authCubit.state is Authenticated;
        final loggingIn = state.matchedLocation == '/login';
        if (!isAuth && !loggingIn) return '/login';
        if (isAuth && loggingIn) return '/';
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const SignInPage(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const UserProfilePage(),
        ),
      ],
      errorBuilder: (context, state) => const ErrorPage(),
    );
  }
}

// Simple ChangeNotifier tie-in for stream changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(child: Text('Page not found!')),
    );
  }
}
