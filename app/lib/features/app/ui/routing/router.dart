import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_clean_architecture/features/app/bloc/app_bloc.dart';
import 'package:flutter_bloc_clean_architecture/features/authentication/login/ui/login_page.dart';
import 'package:flutter_bloc_clean_architecture/features/authentication/signup/ui/signup_page.dart';
import 'package:flutter_bloc_clean_architecture/features/home/ui/home_page.dart';
import 'package:go_router/go_router.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter router(BuildContext context, String? initialLocation) => GoRouter(
      initialLocation: initialLocation ?? Routes.login,
      debugLogDiagnostics: true,
      refreshListenable: GoRouterRefreshStream(context.read<AppBloc>().stream),
      routes: [
        GoRoute(
          path: Routes.signup,
          builder: (context, state) {
            return const SignUpPage();
          },
        ),
        GoRoute(
          path: Routes.login,
          builder: (context, state) {
            return const LoginPage();
          },
        ),
        GoRoute(
          path: Routes.home,
          builder: (context, state) {
            return const HomePage();
          },
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        final loggedIn = context.read<AppBloc>().state.isAuthenticated;
        final loggingIn = state.matchedLocation == Routes.login;
        final signingUp = state.matchedLocation == Routes.signup;

        if (signingUp) {
          return null;
        }

        if (!loggedIn) {
          return loggingIn ? null : Routes.login;
        }
        if (loggingIn) {
          return Routes.home;
        }

        return null;
      },
    );

class Routes {
  static const signup = '/signup';
  static const login = '/login';
  static const home = '/home';
}
