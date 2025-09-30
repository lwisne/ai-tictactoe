import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/score_repository.dart';
import 'domain/services/ai_service.dart';
import 'domain/services/game_service.dart';
import 'presentation/blocs/game_bloc/game_bloc.dart';
import 'presentation/blocs/score_bloc/score_bloc.dart';
import 'presentation/blocs/score_bloc/score_event.dart';
import 'routes/app_router.dart';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final gameService = GameService();
    final aiService = AiService(gameService);
    final scoreRepository = ScoreRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: gameService),
        RepositoryProvider.value(value: aiService),
        RepositoryProvider.value(value: scoreRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => GameBloc(
              gameService: gameService,
              aiService: aiService,
            ),
          ),
          BlocProvider(
            create: (context) => ScoreBloc(
              scoreRepository: scoreRepository,
            )..add(const LoadScore()),
          ),
        ],
        child: MaterialApp.router(
          title: 'Tic-Tac-Toe',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
