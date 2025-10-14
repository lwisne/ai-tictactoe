import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class AppRouter {
  // Private constructor to prevent instantiation
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const _PlaceholderHomePage(),
      ),
    ],
  );
}

// Placeholder home page - will be replaced in future tasks
class _PlaceholderHomePage extends StatelessWidget {
  const _PlaceholderHomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tic-Tac-Toe')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_3x3, size: 100, color: Colors.blue),
            SizedBox(height: 24),
            Text(
              'Tic-Tac-Toe',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Project initialized successfully!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
