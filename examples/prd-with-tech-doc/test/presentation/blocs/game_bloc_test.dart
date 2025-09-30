import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tic_tac_toe/domain/entities/difficulty_level.dart';
import 'package:tic_tac_toe/domain/entities/game_config.dart';
import 'package:tic_tac_toe/domain/entities/game_mode.dart';
import 'package:tic_tac_toe/domain/entities/game_result.dart';
import 'package:tic_tac_toe/domain/entities/player.dart';
import 'package:tic_tac_toe/domain/entities/position.dart';
import 'package:tic_tac_toe/presentation/blocs/game_bloc/game_bloc.dart';
import 'package:tic_tac_toe/presentation/blocs/game_bloc/game_event.dart';
import 'package:tic_tac_toe/presentation/blocs/game_bloc/game_state.dart';

import '../../helpers/builders.dart';
import '../../helpers/mocks.dart';

void main() {
  late GameBloc bloc;
  late MockGameService mockGameService;
  late MockAiService mockAiService;

  setUp(() {
    mockGameService = MockGameService();
    mockAiService = MockAiService();
    registerFallbackValues();
    bloc = GameBloc(
      gameService: mockGameService,
      aiService: mockAiService,
    );
  });

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(const Position(row: 0, col: 0));
    registerFallbackValue(Player.x);
    registerFallbackValue(DifficultyLevel.easy);
    registerFallbackValue(TestDataBuilder.createEmptyBoard());
    registerFallbackValue(TestDataBuilder.createGameState());
    registerFallbackValue(TestDataBuilder.createGameConfig());
  });

  tearDown(() {
    bloc.close();
  });

  group('GameBloc', () {
    test('initial state is GameInitial', () {
      expect(bloc.state, equals(const GameInitial()));
    });

    group('StartNewGame', () {
      blocTest<GameBloc, GameBlocState>(
        'should emit GameInProgress when StartNewGame is added for two player',
        build: () {
          final config = TestDataBuilder.createGameConfig(
            gameMode: GameMode.twoPlayer,
            firstPlayer: Player.x,
          );
          final gameState = TestDataBuilder.createGameState(config: config);

          when(() => mockGameService.createNewGame(any()))
              .thenReturn(gameState);

          return bloc;
        },
        act: (bloc) => bloc.add(
          StartNewGame(
            TestDataBuilder.createGameConfig(
              gameMode: GameMode.twoPlayer,
              firstPlayer: Player.x,
            ),
          ),
        ),
        expect: () => [
          isA<GameInProgress>()
              .having((s) => s.gameState, 'gameState', isNotNull)
              .having(
                (s) => s.gameState.config.gameMode,
                'gameMode',
                GameMode.twoPlayer,
              ),
        ],
        verify: (_) {
          verify(() => mockGameService.createNewGame(any())).called(1);
        },
      );

      blocTest<GameBloc, GameBlocState>(
        'should emit GameInProgress when StartNewGame is added for single player',
        build: () {
          final config = TestDataBuilder.createGameConfig(
            gameMode: GameMode.singlePlayer,
            firstPlayer: Player.x,
            difficultyLevel: DifficultyLevel.easy,
          );
          final gameState = TestDataBuilder.createGameState(config: config);

          when(() => mockGameService.createNewGame(any()))
              .thenReturn(gameState);

          return bloc;
        },
        act: (bloc) => bloc.add(
          StartNewGame(
            TestDataBuilder.createGameConfig(
              gameMode: GameMode.singlePlayer,
              firstPlayer: Player.x,
              difficultyLevel: DifficultyLevel.easy,
            ),
          ),
        ),
        expect: () => [
          isA<GameInProgress>()
              .having((s) => s.gameState, 'gameState', isNotNull)
              .having(
                (s) => s.gameState.config.gameMode,
                'gameMode',
                GameMode.singlePlayer,
              ),
        ],
      );

      blocTest<GameBloc, GameBlocState>(
        'should trigger AI move when AI plays first',
        build: () {
          final config = TestDataBuilder.createGameConfig(
            gameMode: GameMode.singlePlayer,
            firstPlayer: Player.o, // AI plays first
            difficultyLevel: DifficultyLevel.easy,
          );
          final gameState = TestDataBuilder.createGameState(config: config);
          final gameStateAfterAi = TestDataBuilder.createGameState(
            config: config,
            currentPlayer: Player.x,
            board: [
              [Player.none, Player.none, Player.none],
              [Player.none, Player.o, Player.none],
              [Player.none, Player.none, Player.none],
            ],
          );

          when(() => mockGameService.createNewGame(any()))
              .thenReturn(gameState);
          when(() => mockAiService.getBestMove(any(), any(), any()))
              .thenReturn(const Position(row: 1, col: 1));
          when(() => mockGameService.makeMove(any(), any()))
              .thenReturn(gameStateAfterAi);

          return bloc;
        },
        act: (bloc) => bloc.add(
          StartNewGame(
            TestDataBuilder.createGameConfig(
              gameMode: GameMode.singlePlayer,
              firstPlayer: Player.o,
              difficultyLevel: DifficultyLevel.easy,
            ),
          ),
        ),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          isA<GameInProgress>(),
          isA<AiThinking>(),
          isA<GameInProgress>()
              .having(
                (s) => s.gameState.board[1][1],
                'center cell',
                Player.o,
              ),
        ],
      );
    });

    group('MakeMove', () {
      blocTest<GameBloc, GameBlocState>(
        'should emit GameInProgress with updated state when valid move made',
        build: () {
          final initialState = TestDataBuilder.createGameState(
            currentPlayer: Player.x,
          );
          final updatedState = TestDataBuilder.createGameState(
            currentPlayer: Player.o,
            board: [
              [Player.x, Player.none, Player.none],
              [Player.none, Player.none, Player.none],
              [Player.none, Player.none, Player.none],
            ],
          );

          when(() => mockGameService.isValidMove(any(), any())).thenReturn(true);
          when(() => mockGameService.makeMove(any(), any()))
              .thenReturn(updatedState);

          return bloc;
        },
        seed: () => GameInProgress(TestDataBuilder.createGameState()),
        act: (bloc) => bloc.add(const MakeMove(Position(row: 0, col: 0))),
        expect: () => [
          isA<GameInProgress>().having(
            (s) => s.gameState.board[0][0],
            'position (0,0)',
            Player.x,
          ),
        ],
        verify: (_) {
          verify(() => mockGameService.isValidMove(any(), any())).called(1);
          verify(() => mockGameService.makeMove(any(), any())).called(1);
        },
      );

      blocTest<GameBloc, GameBlocState>(
        'should not emit new state when invalid move attempted',
        build: () {
          when(() => mockGameService.isValidMove(any(), any()))
              .thenReturn(false);

          return bloc;
        },
        seed: () => GameInProgress(TestDataBuilder.createGameState()),
        act: (bloc) => bloc.add(const MakeMove(Position(row: 0, col: 0))),
        expect: () => [],
        verify: (_) {
          verify(() => mockGameService.isValidMove(any(), any())).called(1);
          verifyNever(() => mockGameService.makeMove(any(), any()));
        },
      );

      blocTest<GameBloc, GameBlocState>(
        'should emit GameFinished when move results in win',
        build: () {
          final winningBoard = TestDataBuilder.createWinningBoard(
            winner: Player.x,
            type: 'horizontal',
          );
          final winningState = TestDataBuilder.createGameState(
            board: winningBoard,
            result: GameResult.win,
            winner: Player.x,
            winningLine: const [
              Position(row: 0, col: 0),
              Position(row: 0, col: 1),
              Position(row: 0, col: 2),
            ],
          );

          when(() => mockGameService.isValidMove(any(), any())).thenReturn(true);
          when(() => mockGameService.makeMove(any(), any()))
              .thenReturn(winningState);

          return bloc;
        },
        seed: () => GameInProgress(TestDataBuilder.createGameState()),
        act: (bloc) => bloc.add(const MakeMove(Position(row: 0, col: 2))),
        expect: () => [
          isA<GameFinished>()
              .having((s) => s.gameState.result, 'result', GameResult.win)
              .having((s) => s.gameState.winner, 'winner', Player.x),
        ],
      );

      blocTest<GameBloc, GameBlocState>(
        'should emit GameFinished when move results in draw',
        build: () {
          final drawBoard = TestDataBuilder.createDrawBoard();
          final drawState = TestDataBuilder.createGameState(
            board: drawBoard,
            result: GameResult.draw,
          );

          when(() => mockGameService.isValidMove(any(), any())).thenReturn(true);
          when(() => mockGameService.makeMove(any(), any()))
              .thenReturn(drawState);

          return bloc;
        },
        seed: () => GameInProgress(TestDataBuilder.createGameState()),
        act: (bloc) => bloc.add(const MakeMove(Position(row: 2, col: 1))),
        expect: () => [
          isA<GameFinished>()
              .having((s) => s.gameState.result, 'result', GameResult.draw)
              .having((s) => s.gameState.winner, 'winner', isNull),
        ],
      );

      blocTest<GameBloc, GameBlocState>(
        'should trigger AI move after player move in single player mode',
        build: () {
          final config = TestDataBuilder.createGameConfig(
            gameMode: GameMode.singlePlayer,
            firstPlayer: Player.x,
            difficultyLevel: DifficultyLevel.medium,
          );
          final stateAfterPlayer = TestDataBuilder.createGameState(
            config: config,
            currentPlayer: Player.o,
            board: [
              [Player.x, Player.none, Player.none],
              [Player.none, Player.none, Player.none],
              [Player.none, Player.none, Player.none],
            ],
          );
          final stateAfterAi = TestDataBuilder.createGameState(
            config: config,
            currentPlayer: Player.x,
            board: [
              [Player.x, Player.none, Player.none],
              [Player.none, Player.o, Player.none],
              [Player.none, Player.none, Player.none],
            ],
          );

          when(() => mockGameService.isValidMove(any(), any())).thenReturn(true);
          when(() => mockGameService.makeMove(any(), any()))
              .thenReturn(stateAfterPlayer);
          when(() => mockAiService.getBestMove(any(), any(), any()))
              .thenReturn(const Position(row: 1, col: 1));
          when(() => mockGameService.makeMove(
            stateAfterPlayer,
            const Position(row: 1, col: 1),
          )).thenReturn(stateAfterAi);

          return bloc;
        },
        seed: () => GameInProgress(
          TestDataBuilder.createGameState(
            config: TestDataBuilder.createGameConfig(
              gameMode: GameMode.singlePlayer,
              firstPlayer: Player.x,
              difficultyLevel: DifficultyLevel.medium,
            ),
          ),
        ),
        act: (bloc) => bloc.add(const MakeMove(Position(row: 0, col: 0))),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          isA<GameInProgress>().having(
            (s) => s.gameState.board[0][0],
            'player move',
            Player.x,
          ),
          isA<AiThinking>(),
          isA<GameInProgress>()
              .having((s) => s.gameState.board[1][1], 'AI move', Player.o),
        ],
      );
    });

    group('MakeAiMove', () {
      blocTest<GameBloc, GameBlocState>(
        'should emit AiThinking then GameInProgress with AI move',
        build: () {
          final config = TestDataBuilder.createGameConfig(
            gameMode: GameMode.singlePlayer,
            firstPlayer: Player.x,
            difficultyLevel: DifficultyLevel.hard,
          );
          final initialState = TestDataBuilder.createGameState(
            config: config,
            currentPlayer: Player.o,
          );
          final stateAfterAi = TestDataBuilder.createGameState(
            config: config,
            currentPlayer: Player.x,
            board: [
              [Player.none, Player.none, Player.none],
              [Player.none, Player.o, Player.none],
              [Player.none, Player.none, Player.none],
            ],
          );

          when(() => mockAiService.getBestMove(any(), any(), any()))
              .thenReturn(const Position(row: 1, col: 1));
          when(() => mockGameService.makeMove(any(), any()))
              .thenReturn(stateAfterAi);

          return bloc;
        },
        seed: () => GameInProgress(
          TestDataBuilder.createGameState(
            config: TestDataBuilder.createGameConfig(
              gameMode: GameMode.singlePlayer,
              firstPlayer: Player.x,
              difficultyLevel: DifficultyLevel.hard,
            ),
            currentPlayer: Player.o,
          ),
        ),
        act: (bloc) => bloc.add(const MakeAiMove()),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          isA<AiThinking>(),
          isA<GameInProgress>().having(
            (s) => s.gameState.board[1][1],
            'AI move',
            Player.o,
          ),
        ],
      );

      blocTest<GameBloc, GameBlocState>(
        'should emit GameFinished when AI wins',
        build: () {
          final config = TestDataBuilder.createGameConfig(
            gameMode: GameMode.singlePlayer,
            firstPlayer: Player.x,
            difficultyLevel: DifficultyLevel.hard,
          );
          final winningBoard = TestDataBuilder.createWinningBoard(
            winner: Player.o,
            type: 'vertical',
          );
          final winningState = TestDataBuilder.createGameState(
            config: config,
            board: winningBoard,
            result: GameResult.loss, // Player lost
            winner: Player.o,
          );

          when(() => mockAiService.getBestMove(any(), any(), any()))
              .thenReturn(const Position(row: 2, col: 0));
          when(() => mockGameService.makeMove(any(), any()))
              .thenReturn(winningState);

          return bloc;
        },
        seed: () => GameInProgress(
          TestDataBuilder.createGameState(
            config: TestDataBuilder.createGameConfig(
              gameMode: GameMode.singlePlayer,
              firstPlayer: Player.x,
              difficultyLevel: DifficultyLevel.hard,
            ),
            currentPlayer: Player.o,
          ),
        ),
        act: (bloc) => bloc.add(const MakeAiMove()),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          isA<AiThinking>(),
          isA<GameFinished>()
              .having((s) => s.gameState.result, 'result', GameResult.loss)
              .having((s) => s.gameState.winner, 'winner', Player.o),
        ],
      );

      blocTest<GameBloc, GameBlocState>(
        'should not make AI move in two player mode',
        build: () {
          return bloc;
        },
        seed: () => GameInProgress(
          TestDataBuilder.createGameState(
            config: TestDataBuilder.createGameConfig(
              gameMode: GameMode.twoPlayer,
            ),
          ),
        ),
        act: (bloc) => bloc.add(const MakeAiMove()),
        wait: const Duration(milliseconds: 600),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockAiService.getBestMove(any(), any(), any()));
        },
      );
    });

    group('UndoMove', () {
      blocTest<GameBloc, GameBlocState>(
        'should undo last move in two player mode',
        build: () {
          final currentState = TestDataBuilder.createGameState(
            board: [
              [Player.x, Player.none, Player.none],
              [Player.none, Player.none, Player.none],
              [Player.none, Player.none, Player.none],
            ],
            moveHistory: const [Position(row: 0, col: 0)],
          );
          final previousState = TestDataBuilder.createGameState(
            board: TestDataBuilder.createEmptyBoard(),
            moveHistory: [],
          );

          when(() => mockGameService.undoLastMove(any()))
              .thenReturn(previousState);

          return bloc;
        },
        seed: () => GameInProgress(
          TestDataBuilder.createGameState(
            board: [
              [Player.x, Player.none, Player.none],
              [Player.none, Player.none, Player.none],
              [Player.none, Player.none, Player.none],
            ],
            moveHistory: const [Position(row: 0, col: 0)],
          ),
        ),
        act: (bloc) => bloc.add(const UndoMove()),
        expect: () => [
          isA<GameInProgress>().having(
            (s) => s.gameState.moveHistory.length,
            'move history',
            0,
          ),
        ],
      );

      blocTest<GameBloc, GameBlocState>(
        'should undo two moves in single player mode',
        build: () {
          final config = TestDataBuilder.createGameConfig(
            gameMode: GameMode.singlePlayer,
            difficultyLevel: DifficultyLevel.easy,
          );
          final afterOneUndo = TestDataBuilder.createGameState(
            config: config,
            board: [
              [Player.x, Player.none, Player.none],
              [Player.none, Player.none, Player.none],
              [Player.none, Player.none, Player.none],
            ],
            moveHistory: const [Position(row: 0, col: 0)],
          );
          final afterTwoUndos = TestDataBuilder.createGameState(
            config: config,
            board: TestDataBuilder.createEmptyBoard(),
            moveHistory: [],
          );

          when(() => mockGameService.undoLastMove(any()))
              .thenReturn(afterOneUndo);
          when(() => mockGameService.undoLastMove(afterOneUndo))
              .thenReturn(afterTwoUndos);

          return bloc;
        },
        seed: () => GameInProgress(
          TestDataBuilder.createGameState(
            config: TestDataBuilder.createGameConfig(
              gameMode: GameMode.singlePlayer,
              difficultyLevel: DifficultyLevel.easy,
            ),
            board: [
              [Player.x, Player.none, Player.none],
              [Player.none, Player.o, Player.none],
              [Player.none, Player.none, Player.none],
            ],
            moveHistory: const [
              Position(row: 0, col: 0),
              Position(row: 1, col: 1),
            ],
          ),
        ),
        act: (bloc) => bloc.add(const UndoMove()),
        expect: () => [
          isA<GameInProgress>().having(
            (s) => s.gameState.moveHistory.length,
            'move history',
            0,
          ),
        ],
      );

      blocTest<GameBloc, GameBlocState>(
        'should not emit new state when no moves to undo',
        build: () {
          when(() => mockGameService.undoLastMove(any())).thenReturn(null);

          return bloc;
        },
        seed: () => GameInProgress(TestDataBuilder.createGameState()),
        act: (bloc) => bloc.add(const UndoMove()),
        expect: () => [],
      );
    });

    group('ResetGame', () {
      blocTest<GameBloc, GameBlocState>(
        'should reset game to initial state',
        build: () {
          final config = TestDataBuilder.createGameConfig(
            gameMode: GameMode.twoPlayer,
          );
          final currentState = TestDataBuilder.createGameState(
            config: config,
            board: [
              [Player.x, Player.o, Player.x],
              [Player.o, Player.x, Player.none],
              [Player.none, Player.none, Player.none],
            ],
            moveHistory: const [
              Position(row: 0, col: 0),
              Position(row: 0, col: 1),
              Position(row: 0, col: 2),
              Position(row: 1, col: 0),
              Position(row: 1, col: 1),
            ],
          );
          final resetState = TestDataBuilder.createGameState(
            config: config,
            board: TestDataBuilder.createEmptyBoard(),
            moveHistory: [],
          );

          when(() => mockGameService.resetGame(any())).thenReturn(resetState);

          return bloc;
        },
        seed: () => GameInProgress(
          TestDataBuilder.createGameState(
            board: [
              [Player.x, Player.o, Player.x],
              [Player.o, Player.x, Player.none],
              [Player.none, Player.none, Player.none],
            ],
          ),
        ),
        act: (bloc) => bloc.add(const ResetGame()),
        expect: () => [
          isA<GameInProgress>()
              .having(
                (s) => s.gameState.board,
                'board',
                TestDataBuilder.createEmptyBoard(),
              )
              .having((s) => s.gameState.moveHistory, 'move history', isEmpty),
        ],
      );

      blocTest<GameBloc, GameBlocState>(
        'should trigger AI move after reset if AI plays first',
        build: () {
          final config = TestDataBuilder.createGameConfig(
            gameMode: GameMode.singlePlayer,
            firstPlayer: Player.o,
            difficultyLevel: DifficultyLevel.medium,
          );
          final resetState = TestDataBuilder.createGameState(
            config: config,
            currentPlayer: Player.o,
            board: TestDataBuilder.createEmptyBoard(),
          );
          final stateAfterAi = TestDataBuilder.createGameState(
            config: config,
            currentPlayer: Player.x,
            board: [
              [Player.none, Player.none, Player.none],
              [Player.none, Player.o, Player.none],
              [Player.none, Player.none, Player.none],
            ],
          );

          when(() => mockGameService.resetGame(any())).thenReturn(resetState);
          when(() => mockAiService.getBestMove(any(), any(), any()))
              .thenReturn(const Position(row: 1, col: 1));
          when(() => mockGameService.makeMove(any(), any()))
              .thenReturn(stateAfterAi);

          return bloc;
        },
        seed: () => GameInProgress(
          TestDataBuilder.createGameState(
            config: TestDataBuilder.createGameConfig(
              gameMode: GameMode.singlePlayer,
              firstPlayer: Player.o,
              difficultyLevel: DifficultyLevel.medium,
            ),
          ),
        ),
        act: (bloc) => bloc.add(const ResetGame()),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          isA<GameInProgress>().having(
            (s) => s.gameState.board,
            'board after reset',
            TestDataBuilder.createEmptyBoard(),
          ),
          isA<AiThinking>(),
          isA<GameInProgress>().having(
            (s) => s.gameState.board[1][1],
            'AI move',
            Player.o,
          ),
        ],
      );
    });
  });
}
