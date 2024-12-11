import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tests_flutter/commons/constants.dart';
import 'package:tests_flutter/views/favorites/favorites_view.dart';
import 'package:tests_flutter/views/home/home_view.dart';

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static String? getCurrentLocation(BuildContext context) {
    final GoRouterState state = GoRouterState.of(context);
    return state.name;
  }

  static final appRouter = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: rootPath,
      routes: [
        GoRoute(
            path: rootPath,
            name: "home",
            parentNavigatorKey: rootNavigatorKey,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeView()),
            routes: [
              GoRoute(
                path: favoritesPath,
                name: "favorites",
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const FavoritesView(),
              )
            ]),
      ]);
}
