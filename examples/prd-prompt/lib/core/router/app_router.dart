import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/game/game_screen.dart';
import '../../features/game/models/game_mode.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/game',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final gameMode = extra?['gameMode'] as GameMode? ?? GameMode.twoPlayer;
        final aiDifficulty = extra?['aiDifficulty'] as AiDifficulty?;

        return GameScreen(
          gameMode: gameMode,
          aiDifficulty: aiDifficulty,
        );
      },
    ),
  ],
);