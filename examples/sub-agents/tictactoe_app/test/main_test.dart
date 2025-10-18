import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tictactoe_app/core/lifecycle/app_lifecycle_observer.dart';
import 'package:tictactoe_app/data/repositories/game_state_persistence_repository.dart';
import 'package:tictactoe_app/domain/models/game_config.dart';
import 'package:tictactoe_app/domain/models/game_mode.dart';
import 'package:tictactoe_app/domain/models/persisted_game_state.dart';
import 'package:tictactoe_app/domain/models/player.dart';
import 'package:tictactoe_app/domain/services/game_service.dart';
import 'package:tictactoe_app/presentation/blocs/game/game_bloc.dart';
import 'package:tictactoe_app/presentation/blocs/game/game_event.dart';
import 'package:tictactoe_app/presentation/blocs/game/game_state.dart';

class MockGameStatePersistenceRepository extends Mock
    implements GameStatePersistenceRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App Lifecycle Integration Tests', () {
    late GameService gameService;
    late MockGameStatePersistenceRepository mockPersistenceRepository;
    late GameBloc gameBloc;
    late AppLifecycleObserver lifecycleObserver;
    late WidgetsBinding widgetsBinding;

    setUpAll(() {
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

      widgetsBinding = TestWidgetsFlutterBinding.instance;
    });

    tearDown(() async {
      await gameBloc.close();
      // Unregister observer if it was registered
      try {
        lifecycleObserver.unregister();
      } catch (_) {
        // Observer might not be registered, ignore
      }
    });

    test('should register AppLifecycleObserver on app startup', () {
      // Create lifecycle observer
      lifecycleObserver = AppLifecycleObserver(
        onPaused: () {
          gameBloc.add(const SaveGameState());
        },
        onDetached: () {
          gameBloc.add(const SaveGameState());
        },
      );

      // Register the observer
      lifecycleObserver.register();

      // Verify observer is registered by checking it doesn't throw
      expect(() => lifecycleObserver.unregister(), returnsNormally);
    });

    test('should dispatch SaveGameState when app is paused', () async {
      bool onPausedCalled = false;

      // Create lifecycle observer with tracking callback
      lifecycleObserver = AppLifecycleObserver(
        onPaused: () {
          onPausedCalled = true;
          gameBloc.add(const SaveGameState());
        },
        onDetached: () {
          gameBloc.add(const SaveGameState());
        },
      );

      lifecycleObserver.register();

      // Start a game so there's state to save
      const testConfig = GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );
      gameBloc.add(const StartNewGame(testConfig));

      // Wait for state emission
      await Future.delayed(const Duration(milliseconds: 100));

      // Simulate app lifecycle state change to paused
      widgetsBinding.handleAppLifecycleStateChanged(AppLifecycleState.paused);

      // Wait for callback
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify onPaused was called
      expect(onPausedCalled, isTrue);

      // Verify save was attempted
      verify(
        () => mockPersistenceRepository.saveGameState(any()),
      ).called(greaterThanOrEqualTo(1));
    });

    test('should dispatch SaveGameState when app is detached', () async {
      bool onDetachedCalled = false;

      // Create lifecycle observer with tracking callback
      lifecycleObserver = AppLifecycleObserver(
        onPaused: () {
          gameBloc.add(const SaveGameState());
        },
        onDetached: () {
          onDetachedCalled = true;
          gameBloc.add(const SaveGameState());
        },
      );

      lifecycleObserver.register();

      // Start a game so there's state to save
      const testConfig = GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );
      gameBloc.add(const StartNewGame(testConfig));

      // Wait for state emission
      await Future.delayed(const Duration(milliseconds: 100));

      // Simulate app lifecycle state change to detached
      widgetsBinding.handleAppLifecycleStateChanged(AppLifecycleState.detached);

      // Wait for callback
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify onDetached was called
      expect(onDetachedCalled, isTrue);

      // Verify save was attempted
      verify(
        () => mockPersistenceRepository.saveGameState(any()),
      ).called(greaterThanOrEqualTo(1));
    });

    test('should dispatch LoadSavedGameState on app init', () async {
      // Create a fresh bloc for this test
      final testBloc = GameBloc(
        gameService: gameService,
        persistenceRepository: mockPersistenceRepository,
      );

      // Track state changes
      final states = <GameState>[];
      final subscription = testBloc.stream.listen(states.add);

      // Dispatch LoadSavedGameState (simulating app startup)
      testBloc.add(const LoadSavedGameState());

      // Wait for state emission
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify loadGameState was called
      verify(() => mockPersistenceRepository.loadGameState()).called(1);

      // Verify GameInitial was emitted (since no saved state exists)
      expect(states, contains(isA<GameInitial>()));

      await subscription.cancel();
      await testBloc.close();
    });

    test('should properly dispose lifecycle observer', () {
      lifecycleObserver = AppLifecycleObserver(
        onPaused: () {},
        onDetached: () {},
      );

      lifecycleObserver.register();

      // Should not throw when unregistering
      expect(() => lifecycleObserver.unregister(), returnsNormally);

      // Should not throw when unregistering again (idempotent)
      expect(() => lifecycleObserver.unregister(), returnsNormally);
    });

    test('should not call callbacks when app resumes', () async {
      bool onPausedCalled = false;
      bool onDetachedCalled = false;

      lifecycleObserver = AppLifecycleObserver(
        onPaused: () {
          onPausedCalled = true;
        },
        onDetached: () {
          onDetachedCalled = true;
        },
      );

      lifecycleObserver.register();

      // Simulate app lifecycle state change to resumed
      widgetsBinding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

      // Wait to ensure callbacks don't fire
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify callbacks were not called
      expect(onPausedCalled, isFalse);
      expect(onDetachedCalled, isFalse);
    });

    test('should not call callbacks when app is inactive', () async {
      bool onPausedCalled = false;
      bool onDetachedCalled = false;

      lifecycleObserver = AppLifecycleObserver(
        onPaused: () {
          onPausedCalled = true;
        },
        onDetached: () {
          onDetachedCalled = true;
        },
      );

      lifecycleObserver.register();

      // Simulate app lifecycle state change to inactive
      widgetsBinding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);

      // Wait to ensure callbacks don't fire
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify callbacks were not called
      expect(onPausedCalled, isFalse);
      expect(onDetachedCalled, isFalse);
    });

    test('should handle multiple lifecycle transitions correctly', () async {
      int pauseCount = 0;
      int detachCount = 0;

      lifecycleObserver = AppLifecycleObserver(
        onPaused: () {
          pauseCount++;
          gameBloc.add(const SaveGameState());
        },
        onDetached: () {
          detachCount++;
          gameBloc.add(const SaveGameState());
        },
      );

      lifecycleObserver.register();

      // Start a game
      const testConfig = GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );
      gameBloc.add(const StartNewGame(testConfig));
      await Future.delayed(const Duration(milliseconds: 100));

      // Simulate multiple transitions
      widgetsBinding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await Future.delayed(const Duration(milliseconds: 50));

      widgetsBinding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await Future.delayed(const Duration(milliseconds: 50));

      widgetsBinding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await Future.delayed(const Duration(milliseconds: 50));

      widgetsBinding.handleAppLifecycleStateChanged(AppLifecycleState.detached);
      await Future.delayed(const Duration(milliseconds: 50));

      // Verify callbacks were called correct number of times
      expect(pauseCount, equals(2)); // Called twice
      expect(detachCount, equals(1)); // Called once

      // Verify save was called multiple times
      verify(
        () => mockPersistenceRepository.saveGameState(any()),
      ).called(greaterThanOrEqualTo(3));
    });
  });
}
