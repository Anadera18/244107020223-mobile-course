import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/announcement_page.dart';
import 'pages/debug_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'routes.dart';

/// GoRouter with an auth guard:
///  * unauthenticated users are always redirected to /login,
///  * a deep link that arrives while logged out (e.g. from a notification) is
///    remembered and opened right after login,
///  * a splash route covers the moment the stored token is being read.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen<AsyncValue<bool>>(
    authStateProvider,
    (previous, next) => refresh.value++,
  );
  ref.onDispose(refresh.dispose);

  String? returnTo;

  void remember(GoRouterState state) {
    final uri = state.uri.toString();
    if (uri != AppRoutes.home &&
        uri != AppRoutes.login &&
        uri != AppRoutes.splash) {
      returnTo = uri;
    }
  }

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final location = state.matchedLocation;

      // First read of secure storage is still running.
      if (auth.isLoading && !auth.hasValue) {
        if (location == AppRoutes.login) return null;
        if (location == AppRoutes.splash) return null;
        remember(state);
        return AppRoutes.splash;
      }

      final loggedIn = auth.valueOrNull ?? false;
      if (!loggedIn) {
        if (location == AppRoutes.login) return null;
        remember(state);
        return AppRoutes.login;
      }

      if (location == AppRoutes.login || location == AppRoutes.splash) {
        final destination = returnTo ?? AppRoutes.home;
        returnTo = null;
        return destination;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.announcementPattern,
        builder: (context, state) =>
            AnnouncementPage(id: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.debug,
        builder: (context, state) => const DebugPage(),
      ),
    ],
  );
});
