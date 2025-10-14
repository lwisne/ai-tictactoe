import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/pages/ai_difficulty_page.dart';
import '../presentation/pages/game_details_page.dart';
import '../presentation/pages/game_page.dart';
import '../presentation/pages/history_page.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/settings_page.dart';

/// Application router configuration using go_router
///
/// Implements declarative routing with support for:
/// - Named routes for all app screens
/// - Dynamic route parameters (e.g., game ID)
/// - Deep linking
/// - Error/404 handling
class AppRouter {
  // Private constructor to prevent instantiation
  AppRouter._();

  // Route path constants
  static const String home = '/';
  static const String game = '/game';
  static const String aiSelect = '/ai-select';
  static const String history = '/history';
  static const String gameDetails = '/history/:gameId';
  static const String settings = '/settings';

  /// Main router instance configured with all application routes
  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      // Home route - main entry point for mode selection
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // Game route - active game board
      GoRoute(
        path: game,
        name: 'game',
        builder: (context, state) => const GamePage(),
      ),

      // AI Difficulty Selection route - choose AI difficulty level
      GoRoute(
        path: aiSelect,
        name: 'ai-select',
        builder: (context, state) => const AiDifficultyPage(),
      ),

      // Game History route - list of past games
      GoRoute(
        path: history,
        name: 'history',
        builder: (context, state) => const HistoryPage(),
      ),

      // Game Details route - view specific historical game
      // Uses path parameter :gameId to identify which game to display
      GoRoute(
        path: gameDetails,
        name: 'game-details',
        builder: (context, state) {
          final gameId = state.pathParameters['gameId'];

          // Validate game ID parameter
          if (gameId == null || gameId.isEmpty) {
            // Redirect to history if game ID is missing
            return const HistoryPage();
          }

          return GameDetailsPage(gameId: gameId);
        },
      ),

      // Settings route - app configuration
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],

    // Error handler for invalid routes (404)
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(home),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 100, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              '404',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.matchedLocation}',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go(home),
              icon: const Icon(Icons.home),
              label: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
