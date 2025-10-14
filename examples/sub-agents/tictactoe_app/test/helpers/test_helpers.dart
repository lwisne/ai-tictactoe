import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tictactoe_app/domain/models/game_mode.dart';
import 'package:tictactoe_app/presentation/cubits/game_mode_cubit.dart';

class MockGameModeCubit extends Mock implements GameModeCubit {}

/// Sets up the dependency injection container for testing
///
/// This function configures GetIt with mocked dependencies that tests can use.
/// Call this in setUp() before tests that need DI-injected dependencies.
///
/// The mock cubit is configured with default behavior:
/// - Returns a non-loading state with no last played mode
/// - Can be further customized in individual tests using when() stubs
Future<void> setupTestDI() async {
  final getIt = GetIt.instance;

  // Reset GetIt to ensure clean state
  if (getIt.isRegistered<GameModeCubit>()) {
    await getIt.reset();
  }

  // Create mock cubit with default behavior
  final mockCubit = MockGameModeCubit();
  when(
    () => mockCubit.state,
  ).thenReturn(const GameModeState(lastPlayedMode: null, isLoading: false));
  when(() => mockCubit.stream).thenAnswer(
    (_) => Stream.value(
      const GameModeState(lastPlayedMode: null, isLoading: false),
    ),
  );
  when(() => mockCubit.close()).thenAnswer((_) async {});
  when(() => mockCubit.initializeLastPlayedMode()).thenAnswer((_) async {});
  when(() => mockCubit.selectGameMode(any())).thenAnswer((_) async {});

  // Register mock in GetIt
  getIt.registerSingleton<GameModeCubit>(mockCubit);
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
    await getIt.reset();
  }
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
