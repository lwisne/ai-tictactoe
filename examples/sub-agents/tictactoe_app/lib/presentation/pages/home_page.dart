import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/game_mode.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_event.dart';
import '../blocs/game/game_state.dart' as game_states;
import '../cubits/game_mode_cubit.dart';
import '../widgets/mode_selection_button.dart';
import '../widgets/resume_game_dialog.dart';

/// Home page - Game mode selection screen
///
/// Critical feature from UX Review - provides dedicated entry point where users
/// select between 'Play vs AI' and 'Two Player' modes with clear navigation.
///
/// As specified in LWI-151, the home screen is the top-level navigation point
/// and should not have a back button. Users can access all main features from here.
///
/// Features:
/// - Two large, tappable mode selection buttons (min 56dp height)
/// - Material 3 design with welcoming visuals
/// - Highlights last played mode for quick access
/// - Clear navigation to History and Settings
/// - Accessible with screen reader support
/// - Responsive layout for various screen sizes
/// - Smooth navigation transitions
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Initialize cubit and immediately load last played mode for PRD requirement
      // that the home page should "highlight last played mode" on load.
      // The initialization is explicit and happens during cubit creation.
      create: (context) => getIt<GameModeCubit>()..initializeLastPlayedMode(),
      child: const HomePageContent(),
    );
  }
}

/// Internal content widget for HomePage
///
/// Exposed with @visibleForTesting to allow direct testing without
/// the BlocProvider dependency injection layer
@visibleForTesting
class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<GameBloc, game_states.GameState>(
      listener: (context, state) async {
        // Show resume dialog when saved game is detected
        if (state is game_states.GameSavedStateDetected) {
          final shouldResume = await ResumeGameDialog.show(context);

          if (shouldResume) {
            // User wants to resume - emit event and navigate to game
            if (context.mounted) {
              context.read<GameBloc>().add(const ResumeGame());
              context.push('/game');
            }
          } else {
            // User wants new game - clear saved state
            if (context.mounted) {
              context.read<GameBloc>().add(const ClearSavedGameState());
            }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tic-Tac-Toe'),
          centerTitle: true,
          // Explicitly disable automatic back button (LWI-151 requirement)
          automaticallyImplyLeading: false,
          actions: [
            // Settings button
            Semantics(
              button: true,
              label: 'Settings',
              child: IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Settings',
                onPressed: () => context.push('/settings'),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<GameModeCubit, GameModeState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingL,
                        vertical: AppTheme.spacingM,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Hero branding section
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // App icon/logo
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorScheme.primary.withOpacity(
                                          0.2,
                                        ),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.grid_3x3,
                                    size: 80,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacingL),

                                // App title
                                Text(
                                  'Tic-Tac-Toe',
                                  style: theme.textTheme.displayLarge?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppTheme.spacingS),

                                // Welcome subtitle
                                Text(
                                  'Select a game mode to begin',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(
                                      0.7,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          // Mode selection buttons
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Play vs AI button
                                ModeSelectionButton(
                                  mode: GameMode.vsAi,
                                  isLastPlayed:
                                      state.lastPlayedMode == GameMode.vsAi,
                                  onTap: () =>
                                      _onModeSelected(context, GameMode.vsAi),
                                ),
                                const SizedBox(height: AppTheme.spacingM),

                                // Two Player button
                                ModeSelectionButton(
                                  mode: GameMode.twoPlayer,
                                  isLastPlayed:
                                      state.lastPlayedMode ==
                                      GameMode.twoPlayer,
                                  onTap: () => _onModeSelected(
                                    context,
                                    GameMode.twoPlayer,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Bottom navigation section
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const SizedBox(height: AppTheme.spacingL),
                                // History button
                                OutlinedButton.icon(
                                  onPressed: () => context.push('/history'),
                                  icon: const Icon(Icons.history),
                                  label: const Text('Game History'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      48,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppTheme.spacingL,
                                      vertical: AppTheme.spacingM,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Handles game mode selection and navigation
  void _onModeSelected(BuildContext context, GameMode mode) {
    // Save the selected mode as last played
    context.read<GameModeCubit>().selectGameMode(mode);

    // Navigate based on the selected mode
    switch (mode) {
      case GameMode.vsAi:
        // Navigate to AI difficulty selection
        context.push('/ai-select');
        break;
      case GameMode.twoPlayer:
        // Navigate directly to game (two player mode)
        context.push('/game');
        break;
    }
  }
}
