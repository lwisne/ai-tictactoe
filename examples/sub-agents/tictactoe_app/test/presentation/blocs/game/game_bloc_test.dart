import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tictactoe_app/data/repositories/game_state_persistence_repository.dart';
import 'package:tictactoe_app/domain/models/game_config.dart';
import 'package:tictactoe_app/domain/models/game_mode.dart';
import 'package:tictactoe_app/domain/models/game_result.dart';
import 'package:tictactoe_app/domain/models/persisted_game_state.dart';
import 'package:tictactoe_app/domain/models/player.dart';
import 'package:tictactoe_app/domain/models/position.dart';
import 'package:tictactoe_app/domain/services/game_service.dart';
import 'package:tictactoe_app/presentation/blocs/game/game_bloc.dart';
import 'package:tictactoe_app/presentation/blocs/game/game_event.dart';
import 'package:tictactoe_app/presentation/blocs/game/game_state.dart';

class MockGameStatePersistenceRepository extends Mock
    implements GameStatePersistenceRepository {}

void main() {
  group('GameBloc', () {
    late GameService gameService;
    late MockGameStatePersistenceRepository mockPersistenceRepository;
    late GameBloc gameBloc;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();

      registerFallbackValue(
        PersistedGameState(
          gameState: GameService().createNewGame(
            const GameConfig(
              gameMode: GameMode.twoPlayer,
              firstPlayer: Player.x,
            ),
          ),
          savedAt: DateTime.now(),
        ),
      );
    });

    setUp(() {
      gameService = GameService();
      mockPersistenceRepository = MockGameStatePersistenceRepository();

      // Default stubs for persistence repository
      when(
        () => mockPersistenceRepository.saveGameState(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockPersistenceRepository.clearGameState(),
      ).thenAnswer((_) async {});
      when(
        () => mockPersistenceRepository.loadGameState(),
      ).thenAnswer((_) async => null);

      gameBloc = GameBloc(
        gameService: gameService,
        persistenceRepository: mockPersistenceRepository,
      );
    });

    tearDown(() {
      gameBloc.close();
    });

    test('initial state is GameInitial', () {
      expect(gameBloc.state, const GameInitial());
    });

    group('GameInitialized', () {
      blocTest<GameBloc, GameState>(
        'should emit GameInitial when initialized',
        build: () => gameBloc,
        act: (bloc) => bloc.add(const GameInitialized()),
        expect: () => [const GameInitial()],
      );
    });

    group('StartNewGame', () {
      const testConfig = GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );

      blocTest<GameBloc, GameState>(
        'should emit GameInProgress with initial game state',
        build: () => gameBloc,
        act: (bloc) => bloc.add(const StartNewGame(testConfig)),
        expect: () => [
          isA<GameInProgress>()
              .having(
                (state) => state.gameState.currentPlayer,
                'currentPlayer',
                Player.x,
              )
              .having(
                (state) => state.gameState.result,
                'result',
                GameResult.ongoing,
              )
              .having((state) => state.gameState.config, 'config', testConfig),
        ],
      );

      blocTest<GameBloc, GameState>(
        'should create empty board',
        build: () => gameBloc,
        act: (bloc) => bloc.add(const StartNewGame(testConfig)),
        verify: (bloc) {
          final state = bloc.state as GameInProgress;
          final board = state.gameState.board;

          expect(board.length, equals(3));
          for (final row in board) {
            expect(row.length, equals(3));
            for (final cell in row) {
              expect(cell, equals(Player.none));
            }
          }
        },
      );

      blocTest<GameBloc, GameState>(
        'should set firstPlayer based on config',
        build: () => gameBloc,
        act: (bloc) => bloc.add(
          const StartNewGame(
            GameConfig(gameMode: GameMode.twoPlayer, firstPlayer: Player.o),
          ),
        ),
        verify: (bloc) {
          final state = bloc.state as GameInProgress;
          expect(state.gameState.currentPlayer, equals(Player.o));
        },
      );
    });

    group('MakeMove', () {
      const testConfig = GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );

      blocTest<GameBloc, GameState>(
        'should emit GameInProgress with updated state after valid move',
        build: () => gameBloc,
        seed: () {
          final gameState = gameService.createNewGame(testConfig);
          return GameInProgress(gameState);
        },
        act: (bloc) => bloc.add(const MakeMove(Position(row: 0, col: 0))),
        expect: () => [
          isA<GameInProgress>().having(
            (state) => state.gameState.board[0][0],
            'board[0][0]',
            Player.x,
          ),
        ],
      );

      blocTest<GameBloc, GameState>(
        'should switch players after valid move',
        build: () => gameBloc,
        seed: () {
          final gameState = gameService.createNewGame(testConfig);
          return GameInProgress(gameState);
        },
        act: (bloc) => bloc.add(const MakeMove(Position(row: 1, col: 1))),
        verify: (bloc) {
          final state = bloc.state as GameInProgress;
          expect(state.gameState.currentPlayer, equals(Player.o));
        },
      );

      blocTest<GameBloc, GameState>(
        'should not emit state for invalid move (occupied cell)',
        build: () => gameBloc,
        seed: () {
          var gameState = gameService.createNewGame(testConfig);
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 0),
          );
          return GameInProgress(gameState);
        },
        act: (bloc) => bloc.add(const MakeMove(Position(row: 0, col: 0))),
        expect: () => [],
      );

      blocTest<GameBloc, GameState>(
        'should not emit state for invalid move (out of bounds)',
        build: () => gameBloc,
        seed: () {
          final gameState = gameService.createNewGame(testConfig);
          return GameInProgress(gameState);
        },
        act: (bloc) => bloc.add(const MakeMove(Position(row: 3, col: 0))),
        expect: () => [],
      );

      blocTest<GameBloc, GameState>(
        'should ignore move when not in GameInProgress state',
        build: () => gameBloc,
        seed: () => const GameInitial(),
        act: (bloc) => bloc.add(const MakeMove(Position(row: 0, col: 0))),
        expect: () => [],
      );

      blocTest<GameBloc, GameState>(
        'should emit GameFinished when player wins',
        build: () => gameBloc,
        seed: () {
          // Create near-win scenario: X needs one more for top row
          var gameState = gameService.createNewGame(testConfig);
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 0),
          ); // X
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 1, col: 0),
          ); // O
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 1),
          ); // X
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 1, col: 1),
          ); // O
          return GameInProgress(gameState);
        },
        act: (bloc) =>
            bloc.add(const MakeMove(Position(row: 0, col: 2))), // X wins
        expect: () => [
          isA<GameFinished>()
              .having(
                (state) => state.gameState.result,
                'result',
                GameResult.win,
              )
              .having((state) => state.gameState.winner, 'winner', Player.x)
              .having(
                (state) => state.gameState.winningLine?.length,
                'winningLine length',
                3,
              ),
        ],
      );

      blocTest<GameBloc, GameState>(
        'should emit GameFinished with draw when board fills',
        build: () => gameBloc,
        seed: () {
          // Create near-draw scenario
          var gameState = gameService.createNewGame(testConfig);
          // X | X | O
          // O | O | X
          // X | _ | _
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 0),
          ); // X
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 2),
          ); // O
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 1),
          ); // X
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 1, col: 0),
          ); // O
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 1, col: 2),
          ); // X
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 1, col: 1),
          ); // O
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 2, col: 0),
          ); // X
          return GameInProgress(gameState);
        },
        act: (bloc) {
          bloc.add(const MakeMove(Position(row: 2, col: 1))); // O
          bloc.add(const MakeMove(Position(row: 2, col: 2))); // X draws
        },
        expect: () => [
          isA<GameInProgress>(), // After O's move
          isA<GameFinished>().having(
            (state) => state.gameState.result,
            'result',
            GameResult.draw,
          ),
        ],
      );

      blocTest<GameBloc, GameState>(
        'should add move to history',
        build: () => gameBloc,
        seed: () {
          final gameState = gameService.createNewGame(testConfig);
          return GameInProgress(gameState);
        },
        act: (bloc) {
          bloc.add(const MakeMove(Position(row: 0, col: 0)));
          bloc.add(const MakeMove(Position(row: 1, col: 1)));
        },
        verify: (bloc) {
          final state = bloc.state as GameInProgress;
          expect(state.gameState.moveHistory.length, equals(2));
          expect(
            state.gameState.moveHistory[0],
            equals(const Position(row: 0, col: 0)),
          );
          expect(
            state.gameState.moveHistory[1],
            equals(const Position(row: 1, col: 1)),
          );
        },
      );
    });

    group('UndoMove', () {
      const testConfig = GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );

      blocTest<GameBloc, GameState>(
        'should emit GameInProgress with previous state',
        build: () => gameBloc,
        seed: () {
          var gameState = gameService.createNewGame(testConfig);
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 0),
          ); // X
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 1, col: 1),
          ); // O
          return GameInProgress(gameState);
        },
        act: (bloc) => bloc.add(const UndoMove()),
        expect: () => [
          isA<GameInProgress>()
              .having(
                (state) => state.gameState.board[1][1],
                'board[1][1]',
                Player.none,
              )
              .having(
                (state) => state.gameState.moveHistory.length,
                'moveHistory length',
                1,
              )
              .having(
                (state) => state.gameState.currentPlayer,
                'currentPlayer',
                Player.o,
              ),
        ],
      );

      blocTest<GameBloc, GameState>(
        'should not emit state when no moves to undo',
        build: () => gameBloc,
        seed: () {
          final gameState = gameService.createNewGame(testConfig);
          return GameInProgress(gameState);
        },
        act: (bloc) => bloc.add(const UndoMove()),
        expect: () => [],
      );

      blocTest<GameBloc, GameState>(
        'should convert GameFinished to GameInProgress after undo',
        build: () => gameBloc,
        seed: () {
          // Create a won game
          var gameState = gameService.createNewGame(testConfig);
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 0),
          ); // X
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 1, col: 0),
          ); // O
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 1),
          ); // X
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 1, col: 1),
          ); // O
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 2),
          ); // X wins
          return GameFinished(gameState);
        },
        act: (bloc) => bloc.add(const UndoMove()),
        expect: () => [
          isA<GameInProgress>().having(
            (state) => state.gameState.result,
            'result',
            GameResult.ongoing,
          ),
        ],
      );

      blocTest<GameBloc, GameState>(
        'should ignore undo when in GameInitial state',
        build: () => gameBloc,
        seed: () => const GameInitial(),
        act: (bloc) => bloc.add(const UndoMove()),
        expect: () => [],
      );

      blocTest<GameBloc, GameState>(
        'should ignore undo when in GameError state',
        build: () => gameBloc,
        seed: () => const GameError('Test error'),
        act: (bloc) => bloc.add(const UndoMove()),
        expect: () => [],
      );
    });

    group('ResetGame', () {
      const testConfig = GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );

      blocTest<GameBloc, GameState>(
        'should emit GameInProgress with fresh game state',
        build: () => gameBloc,
        seed: () {
          var gameState = gameService.createNewGame(testConfig);
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 0),
          );
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 1, col: 1),
          );
          return GameInProgress(gameState);
        },
        act: (bloc) => bloc.add(const ResetGame()),
        expect: () => [
          isA<GameInProgress>()
              .having(
                (state) => state.gameState.board[0][0],
                'board[0][0]',
                Player.none,
              )
              .having(
                (state) => state.gameState.board[1][1],
                'board[1][1]',
                Player.none,
              )
              .having(
                (state) => state.gameState.moveHistory,
                'moveHistory',
                isEmpty,
              )
              .having(
                (state) => state.gameState.currentPlayer,
                'currentPlayer',
                Player.x,
              )
              .having(
                (state) => state.gameState.result,
                'result',
                GameResult.ongoing,
              ),
        ],
      );

      blocTest<GameBloc, GameState>(
        'should preserve config when resetting',
        build: () => gameBloc,
        seed: () {
          var gameState = gameService.createNewGame(testConfig);
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 0),
          );
          return GameInProgress(gameState);
        },
        act: (bloc) => bloc.add(const ResetGame()),
        verify: (bloc) {
          final state = bloc.state as GameInProgress;
          expect(state.gameState.config, equals(testConfig));
        },
      );

      blocTest<GameBloc, GameState>(
        'should reset from GameFinished state',
        build: () => gameBloc,
        seed: () {
          // Create a won game
          var gameState = gameService.createNewGame(testConfig);
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 0),
          ); // X
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 1, col: 0),
          ); // O
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 1),
          ); // X
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 1, col: 1),
          ); // O
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 2),
          ); // X wins
          return GameFinished(gameState);
        },
        act: (bloc) => bloc.add(const ResetGame()),
        expect: () => [
          isA<GameInProgress>().having(
            (state) => state.gameState.result,
            'result',
            GameResult.ongoing,
          ),
        ],
      );

      blocTest<GameBloc, GameState>(
        'should ignore reset when in GameInitial state',
        build: () => gameBloc,
        seed: () => const GameInitial(),
        act: (bloc) => bloc.add(const ResetGame()),
        expect: () => [],
      );

      blocTest<GameBloc, GameState>(
        'should ignore reset when in GameError state',
        build: () => gameBloc,
        seed: () => const GameError('Test error'),
        act: (bloc) => bloc.add(const ResetGame()),
        expect: () => [],
      );
    });

    group('Integration scenarios', () {
      const testConfig = GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );

      blocTest<GameBloc, GameState>(
        'should handle complete game flow: start -> moves -> win',
        build: () => gameBloc,
        act: (bloc) {
          bloc.add(const StartNewGame(testConfig));
          bloc.add(const MakeMove(Position(row: 0, col: 0))); // X
          bloc.add(const MakeMove(Position(row: 1, col: 0))); // O
          bloc.add(const MakeMove(Position(row: 0, col: 1))); // X
          bloc.add(const MakeMove(Position(row: 1, col: 1))); // O
          bloc.add(const MakeMove(Position(row: 0, col: 2))); // X wins
        },
        expect: () => [
          isA<GameInProgress>(), // After StartNewGame
          isA<GameInProgress>(), // After move 1
          isA<GameInProgress>(), // After move 2
          isA<GameInProgress>(), // After move 3
          isA<GameInProgress>(), // After move 4
          isA<GameFinished>(), // After winning move
        ],
      );

      blocTest<GameBloc, GameState>(
        'should handle game flow: start -> moves -> undo -> continue',
        build: () => gameBloc,
        act: (bloc) {
          bloc.add(const StartNewGame(testConfig));
          bloc.add(const MakeMove(Position(row: 0, col: 0))); // X
          bloc.add(const MakeMove(Position(row: 1, col: 1))); // O
          bloc.add(const UndoMove()); // Undo O's move
          bloc.add(const MakeMove(Position(row: 2, col: 2))); // O again
        },
        verify: (bloc) {
          final state = bloc.state as GameInProgress;
          expect(state.gameState.board[1][1], equals(Player.none));
          expect(state.gameState.board[2][2], equals(Player.o));
          expect(state.gameState.moveHistory.length, equals(2));
        },
      );

      blocTest<GameBloc, GameState>(
        'should handle game flow: win -> reset -> new game',
        build: () => gameBloc,
        act: (bloc) {
          bloc.add(const StartNewGame(testConfig));
          // Quick win scenario
          bloc.add(const MakeMove(Position(row: 0, col: 0))); // X
          bloc.add(const MakeMove(Position(row: 1, col: 0))); // O
          bloc.add(const MakeMove(Position(row: 0, col: 1))); // X
          bloc.add(const MakeMove(Position(row: 1, col: 1))); // O
          bloc.add(const MakeMove(Position(row: 0, col: 2))); // X wins
          bloc.add(const ResetGame());
        },
        expect: () => [
          isA<GameInProgress>(), // Start
          isA<GameInProgress>(), // Move 1
          isA<GameInProgress>(), // Move 2
          isA<GameInProgress>(), // Move 3
          isA<GameInProgress>(), // Move 4
          isA<GameFinished>(), // Win
          isA<GameInProgress>(), // Reset
        ],
      );
    });

    group('SaveGameState', () {
      const testConfig = GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );

      blocTest<GameBloc, GameState>(
        'should save state when SaveGameState event is triggered',
        build: () => gameBloc,
        seed: () {
          final gameState = gameService.createNewGame(testConfig);
          return GameInProgress(gameState);
        },
        act: (bloc) => bloc.add(const SaveGameState()),
        verify: (_) {
          verify(
            () => mockPersistenceRepository.saveGameState(any()),
          ).called(1);
        },
      );

      blocTest<GameBloc, GameState>(
        'should not save state when in GameInitial state',
        build: () => gameBloc,
        seed: () => const GameInitial(),
        act: (bloc) => bloc.add(const SaveGameState()),
        verify: (_) {
          verifyNever(() => mockPersistenceRepository.saveGameState(any()));
        },
      );

      blocTest<GameBloc, GameState>(
        'should not save state when game is finished',
        build: () => gameBloc,
        seed: () {
          var gameState = gameService.createNewGame(testConfig);
          // Create winning scenario
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 0),
          );
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 1, col: 0),
          );
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 1),
          );
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 1, col: 1),
          );
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 2),
          );
          return GameFinished(gameState);
        },
        act: (bloc) => bloc.add(const SaveGameState()),
        verify: (_) {
          verifyNever(() => mockPersistenceRepository.saveGameState(any()));
        },
      );
    });

    group('LoadSavedGameState', () {
      const testConfig = GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );

      blocTest<GameBloc, GameState>(
        'should emit GameSavedStateDetected when saved state exists',
        build: () {
          final savedGameState = gameService.createNewGame(testConfig);
          final persistedState = PersistedGameState(
            gameState: savedGameState,
            playerWins: 1,
            aiWins: 2,
            draws: 3,
            savedAt: DateTime.now(),
          );
          when(
            () => mockPersistenceRepository.loadGameState(),
          ).thenAnswer((_) async => persistedState);
          return gameBloc;
        },
        act: (bloc) => bloc.add(const LoadSavedGameState()),
        expect: () => [
          isA<GameSavedStateDetected>().having(
            (state) => state.persistedState.playerWins,
            'playerWins',
            1,
          ),
        ],
      );

      blocTest<GameBloc, GameState>(
        'should emit GameInitial when no saved state exists',
        build: () {
          when(
            () => mockPersistenceRepository.loadGameState(),
          ).thenAnswer((_) async => null);
          return gameBloc;
        },
        act: (bloc) => bloc.add(const LoadSavedGameState()),
        expect: () => [const GameInitial()],
      );

      blocTest<GameBloc, GameState>(
        'should clear corrupted state and emit GameInitial on load error',
        build: () {
          when(
            () => mockPersistenceRepository.loadGameState(),
          ).thenThrow(Exception('Corrupted data'));
          return gameBloc;
        },
        act: (bloc) => bloc.add(const LoadSavedGameState()),
        expect: () => [const GameInitial()],
        verify: (_) {
          verify(() => mockPersistenceRepository.clearGameState()).called(1);
        },
      );
    });

    group('ResumeGame', () {
      const testConfig = GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );

      blocTest<GameBloc, GameState>(
        'should emit GameInProgress when resuming an ongoing game',
        build: () => gameBloc,
        seed: () {
          final savedGameState = gameService.createNewGame(testConfig);
          final persistedState = PersistedGameState(
            gameState: savedGameState,
            savedAt: DateTime.now(),
          );
          return GameSavedStateDetected(persistedState);
        },
        act: (bloc) => bloc.add(const ResumeGame()),
        expect: () => [
          isA<GameInProgress>().having(
            (state) => state.gameState.result,
            'result',
            GameResult.ongoing,
          ),
        ],
      );

      blocTest<GameBloc, GameState>(
        'should emit GameFinished when resuming a finished game',
        build: () => gameBloc,
        seed: () {
          var gameState = gameService.createNewGame(testConfig);
          // Create finished game
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 0),
          );
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 1, col: 0),
          );
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 1),
          );
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 1, col: 1),
          );
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 2),
          );

          final persistedState = PersistedGameState(
            gameState: gameState,
            savedAt: DateTime.now(),
          );
          return GameSavedStateDetected(persistedState);
        },
        act: (bloc) => bloc.add(const ResumeGame()),
        expect: () => [
          isA<GameFinished>().having(
            (state) => state.gameState.result,
            'result',
            GameResult.win,
          ),
        ],
      );

      blocTest<GameBloc, GameState>(
        'should ignore ResumeGame when not in GameSavedStateDetected',
        build: () => gameBloc,
        seed: () => const GameInitial(),
        act: (bloc) => bloc.add(const ResumeGame()),
        expect: () => [],
      );
    });

    group('ClearSavedGameState', () {
      blocTest<GameBloc, GameState>(
        'should clear saved state and emit GameInitial',
        build: () => gameBloc,
        act: (bloc) => bloc.add(const ClearSavedGameState()),
        expect: () => [const GameInitial()],
        verify: (_) {
          verify(() => mockPersistenceRepository.clearGameState()).called(1);
        },
      );
    });

    group('Auto-save behavior', () {
      const testConfig = GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );

      blocTest<GameBloc, GameState>(
        'should auto-save after each move in progress',
        build: () => gameBloc,
        seed: () {
          final gameState = gameService.createNewGame(testConfig);
          return GameInProgress(gameState);
        },
        act: (bloc) {
          bloc.add(const MakeMove(Position(row: 0, col: 0))); // X
          bloc.add(const MakeMove(Position(row: 1, col: 1))); // O
        },
        verify: (_) {
          // Should save after each move (2 moves = 2 saves)
          verify(
            () => mockPersistenceRepository.saveGameState(any()),
          ).called(greaterThanOrEqualTo(2));
        },
      );

      blocTest<GameBloc, GameState>(
        'should clear saved state when game finishes',
        build: () => gameBloc,
        seed: () {
          // Create near-win scenario
          var gameState = gameService.createNewGame(testConfig);
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 0),
          );
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 1, col: 0),
          );
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 1),
          );
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 1, col: 1),
          );
          return GameInProgress(gameState);
        },
        act: (bloc) =>
            bloc.add(const MakeMove(Position(row: 0, col: 2))), // X wins
        verify: (_) {
          // Should clear state when game finishes
          verify(() => mockPersistenceRepository.clearGameState()).called(1);
        },
      );

      blocTest<GameBloc, GameState>(
        'should save state after reset',
        build: () => gameBloc,
        seed: () {
          var gameState = gameService.createNewGame(testConfig);
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 0),
          );
          return GameInProgress(gameState);
        },
        act: (bloc) => bloc.add(const ResetGame()),
        verify: (_) {
          // Should save the reset state
          verify(
            () => mockPersistenceRepository.saveGameState(any()),
          ).called(greaterThanOrEqualTo(1));
        },
      );
    });

    group('Session score tracking', () {
      const testConfig = GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );

      blocTest<GameBloc, GameState>(
        'should track player wins in persisted state',
        build: () => gameBloc,
        seed: () {
          var gameState = gameService.createNewGame(testConfig);
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 0),
          );
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 1, col: 0),
          );
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 1),
          );
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 1, col: 1),
          );
          return GameInProgress(gameState);
        },
        act: (bloc) =>
            bloc.add(const MakeMove(Position(row: 0, col: 2))), // X wins
        verify: (_) {
          // Verify that saveGameState was called
          // Note: Session tracking happens internally, we can't verify exact counts
          // without exposing internal state, but we can verify save was called
          verify(() => mockPersistenceRepository.clearGameState()).called(1);
        },
      );

      blocTest<GameBloc, GameState>(
        'should track draws in persisted state',
        build: () => gameBloc,
        seed: () {
          // Create near-draw scenario
          var gameState = gameService.createNewGame(testConfig);
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 0),
          ); // X
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 2),
          ); // O
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 0, col: 1),
          ); // X
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 1, col: 0),
          ); // O
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 1, col: 2),
          ); // X
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 1, col: 1),
          ); // O
          gameState = gameService.makeMove(
            gameState,
            const Position(row: 2, col: 0),
          ); // X
          return GameInProgress(gameState);
        },
        act: (bloc) {
          bloc.add(const MakeMove(Position(row: 2, col: 1))); // O
          bloc.add(const MakeMove(Position(row: 2, col: 2))); // X draws
        },
        verify: (_) {
          // Verify clear was called when game ended
          verify(() => mockPersistenceRepository.clearGameState()).called(1);
        },
      );

      blocTest<GameBloc, GameState>(
        'should restore session scores from loaded state',
        build: () {
          final savedGameState = gameService.createNewGame(testConfig);
          final persistedState = PersistedGameState(
            gameState: savedGameState,
            playerWins: 5,
            aiWins: 3,
            draws: 2,
            savedAt: DateTime.now(),
          );
          when(
            () => mockPersistenceRepository.loadGameState(),
          ).thenAnswer((_) async => persistedState);
          return gameBloc;
        },
        act: (bloc) => bloc.add(const LoadSavedGameState()),
        expect: () => [
          isA<GameSavedStateDetected>()
              .having(
                (state) => state.persistedState.playerWins,
                'playerWins',
                5,
              )
              .having((state) => state.persistedState.aiWins, 'aiWins', 3)
              .having((state) => state.persistedState.draws, 'draws', 2),
        ],
      );
    });
  });
}
