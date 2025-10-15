import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tictactoe_app/domain/models/game_mode.dart';
import 'package:tictactoe_app/presentation/cubits/game_mode_cubit.dart';
import 'package:tictactoe_app/presentation/cubits/game_ui_cubit.dart';

class MockGameModeCubit extends Mock implements GameModeCubit {}

class MockGameUICubit extends Mock implements GameUICubit {}

/// Sets up the dependency injection container for testing
///
/// This function configures GetIt with mocked dependencies that tests can use.
/// Call this in setUp() before tests that need DI-injected dependencies.
///
/// The mock cubits are configured with default behavior:
/// - GameModeCubit: Returns a non-loading state with no last played mode
/// - GameUICubit: Returns initial game state (empty board, X starts)
/// - Can be further customized in individual tests using when() stubs
Future<void> setupTestDI() async {
  final getIt = GetIt.instance;

  // Reset GetIt to ensure clean state
  await getIt.reset();

  // Create mock GameModeCubit with default behavior
  final mockGameModeCubit = MockGameModeCubit();
  when(
    () => mockGameModeCubit.state,
  ).thenReturn(const GameModeState(lastPlayedMode: null, isLoading: false));
  when(() => mockGameModeCubit.stream).thenAnswer(
    (_) => Stream.value(
      const GameModeState(lastPlayedMode: null, isLoading: false),
    ),
  );
  when(() => mockGameModeCubit.close()).thenAnswer((_) async {});
  when(
    () => mockGameModeCubit.initializeLastPlayedMode(),
  ).thenAnswer((_) async {});
  when(() => mockGameModeCubit.selectGameMode(any())).thenAnswer((_) async {});

  // Create mock GameUICubit with default behavior
  final mockGameUICubit = MockGameUICubit();
  when(() => mockGameUICubit.state).thenReturn(const GameUIState.initial());
  when(
    () => mockGameUICubit.stream,
  ).thenAnswer((_) => Stream.value(const GameUIState.initial()));
  when(() => mockGameUICubit.close()).thenAnswer((_) async {});
  when(() => mockGameUICubit.handleCellTap(any())).thenReturn(null);
  when(() => mockGameUICubit.resetGame()).thenReturn(null);

  // Register mocks in GetIt
  getIt.registerSingleton<GameModeCubit>(mockGameModeCubit);
  getIt.registerSingleton<GameUICubit>(mockGameUICubit);
}

/// Tears down the dependency injection container after testing
///
/// Call this in tearDown() to clean up the DI container and prevent
/// state pollution between tests.
Future<void> teardownTestDI() async {
  final getIt = GetIt.instance;

  if (getIt.isRegistered<GameModeCubit>()) {
    final cubit = getIt<GameModeCubit>();
    await cubit.close();
  }

  if (getIt.isRegistered<GameUICubit>()) {
    final cubit = getIt<GameUICubit>();
    await cubit.close();
  }

  await getIt.reset();
}

/// Gets the mock GameModeCubit from the DI container
///
/// Use this to customize the mock's behavior in individual tests:
/// ```dart
/// final mockCubit = getTestGameModeCubit();
/// when(() => mockCubit.state).thenReturn(customState);
/// ```
GameModeCubit getTestGameModeCubit() {
  return GetIt.instance<GameModeCubit>();
}

/// Gets the mock GameUICubit from the DI container
///
/// Use this to customize the mock's behavior in individual tests:
/// ```dart
/// final mockCubit = getTestGameUICubit();
/// when(() => mockCubit.state).thenReturn(customState);
/// ```
GameUICubit getTestGameUICubit() {
  return GetIt.instance<GameUICubit>();
}
