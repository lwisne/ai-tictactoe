import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../domain/entities/game_config.dart';
import '../presentation/pages/game_page.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/settings_page.dart';

class AppRouter {
  static const String home = '/';
  static const String game = '/game';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: game,
        builder: (context, state) {
          final config = state.extra as GameConfig?;
          return GamePage(config: config);
        },
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
}
