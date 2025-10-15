# Architecture Documentation

## Table of Contents
- [Overview](#overview)
- [Project Structure](#project-structure)
- [Clean Architecture Layers](#clean-architecture-layers)
- [BLoC Pattern Guidelines](#bloc-pattern-guidelines)
- [State Management](#state-management)
- [Navigation](#navigation)
- [Dependency Injection](#dependency-injection)
- [Theming](#theming)
- [Testing Strategy](#testing-strategy)
- [Code Organization Standards](#code-organization-standards)
- [Coding Standards](#coding-standards)
- [Common Patterns](#common-patterns)

## Overview

This Tic-Tac-Toe Flutter application follows Clean Architecture principles combined with the BLoC (Business Logic Component) pattern for state management. The architecture emphasizes:

- **Separation of Concerns**: Clear boundaries between UI, business logic, and data layers
- **Testability**: All components are designed to be easily testable
- **Maintainability**: Consistent patterns and standards throughout the codebase
- **Scalability**: Structure that supports growth and feature additions

### Tech Stack
- **Flutter 3.x**: UI framework
- **Dart 3.9+**: Programming language
- **flutter_bloc 8.1.6**: State management
- **go_router 14.6.1**: Navigation
- **get_it 8.0.2 + injectable 2.5.0**: Dependency injection
- **shared_preferences 2.3.3**: Local storage
- **Material 3**: Design system

## Project Structure

```
lib/
├── core/                      # Core functionality used across the app
│   ├── bloc/                  # Global BLoC configuration
│   │   └── app_bloc_observer.dart
│   ├── di/                    # Dependency injection setup
│   │   ├── injection.dart
│   │   └── injection.config.dart (generated)
│   ├── navigation/            # Navigation utilities
│   │   └── navigation_behavior.dart
│   ├── theme/                 # Theme configuration
│   │   └── app_theme.dart
│   ├── constants/             # App-wide constants
│   └── utils/                 # Utility functions
├── data/                      # Data layer (repositories, data sources)
│   └── repositories/          # Repository implementations
│       ├── theme_repository.dart
│       └── game_mode_repository.dart
├── domain/                    # Domain layer (business logic, models)
│   ├── models/                # Domain models
│   │   ├── theme_preference.dart
│   │   └── game_mode.dart
│   └── services/              # Business logic services
├── presentation/              # Presentation layer (UI, BLoCs, Cubits)
│   ├── blocs/                 # BLoCs for complex state management
│   │   ├── game/
│   │   │   ├── game_bloc.dart
│   │   │   ├── game_event.dart
│   │   │   └── game_state.dart
│   │   ├── theme/
│   │   │   ├── theme_bloc.dart
│   │   │   ├── theme_event.dart
│   │   │   └── theme_state.dart
│   │   └── settings/
│   │       ├── settings_bloc.dart
│   │       ├── settings_event.dart
│   │       └── settings_state.dart
│   ├── cubits/                # Cubits for simple state management
│   │   └── game_mode_cubit.dart
│   ├── extensions/            # UI extensions for domain models
│   │   └── game_mode_ui_extensions.dart
│   ├── pages/                 # Full screen pages
│   │   ├── home_page.dart
│   │   ├── game_page.dart
│   │   ├── ai_difficulty_page.dart
│   │   ├── settings_page.dart
│   │   ├── history_page.dart
│   │   └── game_details_page.dart
│   └── widgets/               # Reusable widgets
│       ├── mode_selection_button.dart
│       └── exit_game_dialog.dart
├── routes/                    # Navigation configuration
│   └── app_router.dart
└── main.dart                  # App entry point

test/                          # Mirror structure of lib/
├── core/
├── data/
├── domain/
├── presentation/
├── routes/
└── helpers/                   # Test utilities
    └── test_helpers.dart
```

## Clean Architecture Layers

### Domain Layer (`lib/domain/`)

The innermost layer containing business logic and entities.

**Responsibilities:**
- Define domain models (data classes)
- Define business rules and logic
- No dependencies on other layers

**Example - Domain Model:**
```dart
// lib/domain/models/theme_preference.dart
enum ThemePreference {
  system,
  light,
  dark;
}

class ThemeSettings extends Equatable {
  final ThemePreference preference;

  const ThemeSettings({this.preference = ThemePreference.system});

  @override
  List<Object?> get props => [preference];
}
```

**Key Principles:**
- Models should extend `Equatable` for value comparison
- Use immutable data classes (final fields)
- Include `copyWith` methods for state updates
- Provide JSON serialization when needed

### Data Layer (`lib/data/`)

Handles data persistence and external data sources.

**Responsibilities:**
- Implement repositories defined in domain layer
- Handle data persistence (SharedPreferences, databases)
- Manage API calls (if applicable)
- Transform data between external format and domain models

**Example - Repository:**
```dart
// lib/data/repositories/theme_repository.dart
@LazySingleton()
class ThemeRepository {
  Future<void> saveThemeSettings(ThemeSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(settings.toJson());
    await prefs.setString(_themeSettingsKey, jsonString);
  }

  Future<ThemeSettings> loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_themeSettingsKey);

    if (jsonString == null) {
      return const ThemeSettings();
    }

    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return ThemeSettings.fromJson(json);
  }
}
```

**Key Principles:**
- Repositories are registered with `@LazySingleton()` or `@Injectable()`
- Handle errors gracefully, return defaults when appropriate
- Keep data transformation logic in this layer
- No business logic - just data operations

### Presentation Layer (`lib/presentation/`)

Contains UI components and presentation logic.

**Responsibilities:**
- Build UI widgets
- Manage UI state with BLoCs/Cubits
- Handle user interactions
- Format data for display

**Components:**
- **Pages**: Full-screen views
- **Widgets**: Reusable UI components
- **BLoCs**: State management for complex features
- **Cubits**: State management for simple features
- **Extensions**: UI-specific extensions for domain models

## BLoC Pattern Guidelines

### When to Use BLoC vs Cubit

**Use BLoC when:**
- You need explicit event tracking
- The state flow is complex
- You want to trace every state change
- Multiple events can trigger the same state

**Use Cubit when:**
- State management is simple
- Direct method calls are sufficient
- Event tracking is not needed
- The state flow is straightforward

### BLoC Structure

Every BLoC should have three files:
1. `*_bloc.dart` - The BLoC class
2. `*_event.dart` - All events
3. `*_state.dart` - All states

**Example - BLoC Implementation:**

```dart
// theme_bloc.dart
@injectable
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeRepository _themeRepository;

  ThemeBloc(this._themeRepository) : super(const ThemeState()) {
    on<ThemeInitialized>(_onThemeInitialized);
    on<ThemeChanged>(_onThemeChanged);
  }

  Future<void> _onThemeInitialized(
    ThemeInitialized event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final settings = await _themeRepository.loadThemeSettings();
      emit(ThemeState(preference: settings.preference, isLoading: false));
    } catch (e) {
      emit(const ThemeState(isLoading: false));
    }
  }
}

// theme_event.dart
sealed class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ThemeInitialized extends ThemeEvent {
  const ThemeInitialized();
}

class ThemeChanged extends ThemeEvent {
  final ThemePreference preference;

  const ThemeChanged(this.preference);

  @override
  List<Object?> get props => [preference];
}

// theme_state.dart
class ThemeState extends Equatable {
  final ThemePreference preference;
  final bool isLoading;

  const ThemeState({
    this.preference = ThemePreference.system,
    this.isLoading = false,
  });

  ThemeState copyWith({
    ThemePreference? preference,
    bool? isLoading,
  }) {
    return ThemeState(
      preference: preference ?? this.preference,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [preference, isLoading];
}
```

### BLoC Best Practices

1. **Always use `sealed class` for events** to enable exhaustive pattern matching
2. **Extend `Equatable`** for both events and states
3. **Include loading states** when performing async operations
4. **Handle errors gracefully** - always have a fallback state
5. **Keep BLoCs focused** - one BLoC per feature/domain
6. **No business logic in BLoCs** - delegate to services/repositories
7. **Use descriptive event names** - `ThemeChanged`, not `UpdateTheme`
8. **Register with `@injectable`** for dependency injection

## State Management

### Global vs Local State

**Global State (BLoC/Cubit):**
- Theme preferences
- User settings
- Game state
- Authentication status

**Local State (StatefulWidget):**
- Form input
- Animation controllers
- Scroll positions
- Temporary UI state

### State Access Patterns

**Providing BLoCs:**
```dart
// In main.dart or parent widget
MultiBlocProvider(
  providers: [
    BlocProvider<ThemeBloc>(
      create: (context) => getIt<ThemeBloc>()..add(const ThemeInitialized()),
    ),
    BlocProvider<GameBloc>(
      create: (context) => getIt<GameBloc>(),
    ),
  ],
  child: MyApp(),
)
```

**Consuming BLoCs:**
```dart
// Listen to state changes and rebuild
BlocBuilder<ThemeBloc, ThemeState>(
  builder: (context, state) {
    return Text('Current theme: ${state.preference}');
  },
)

// Listen without rebuilding
BlocListener<ThemeBloc, ThemeState>(
  listener: (context, state) {
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading theme')),
      );
    }
  },
  child: MyWidget(),
)

// Both listen and build
BlocConsumer<ThemeBloc, ThemeState>(
  listener: (context, state) { /* side effects */ },
  builder: (context, state) { /* UI */ },
)
```

**Dispatching Events:**
```dart
// Access bloc and add event
context.read<ThemeBloc>().add(const ThemeChanged(ThemePreference.dark));
```

## Navigation

### go_router Configuration

The app uses `go_router` for declarative routing with support for:
- Named routes
- Path parameters
- Deep linking
- Type-safe navigation
- Error handling (404)

**Route Definition:**
```dart
// lib/routes/app_router.dart
class AppRouter {
  static const String home = '/';
  static const String game = '/game';
  static const String gameDetails = '/history/:gameId';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: gameDetails,
        name: 'game-details',
        builder: (context, state) {
          final gameId = state.pathParameters['gameId'];
          return GameDetailsPage(gameId: gameId);
        },
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(),
  );
}
```

**Navigation API:**
```dart
// Push new route
context.go('/game');
context.goNamed('game');

// Pop current route
context.pop();

// Replace current route
context.replace('/home');

// With parameters
context.goNamed('game-details', pathParameters: {'gameId': '123'});

// Check if can pop
if (context.canPop()) {
  context.pop();
}
```

### Navigation Utilities

**NavigationBehavior** provides common navigation patterns:
```dart
// lib/core/navigation/navigation_behavior.dart
mixin NavigationBehavior {
  void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }

  void goHome(BuildContext context) {
    context.go(AppRouter.home);
  }

  bool canNavigateBack(BuildContext context) {
    return context.canPop();
  }
}
```

## Dependency Injection

### Setup with get_it + injectable

**Configuration:**
```dart
// lib/core/di/injection.dart
final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() {
  getIt.init(); // Calls generated code
}

// In main.dart
void main() {
  configureDependencies();
  runApp(MyApp());
}
```

**Registration Annotations:**

```dart
// Singleton (lazy) - created when first accessed
@LazySingleton()
class ThemeRepository { }

// Singleton (eager) - created at startup
@Singleton()
class AppConfig { }

// Factory - new instance every time
@injectable
class ThemeBloc { }

// With dependencies
@injectable
class ThemeBloc {
  final ThemeRepository _repository;

  ThemeBloc(this._repository); // Auto-injected
}
```

**Code Generation:**
```bash
# Generate injection configuration
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes
flutter pub run build_runner watch
```

**Using Dependencies:**
```dart
// Retrieve from service locator
final themeBloc = getIt<ThemeBloc>();
final repository = getIt<ThemeRepository>();
```

### Best Practices

1. **Always annotate injectable classes** with `@injectable`, `@LazySingleton()`, or `@Singleton()`
2. **Use constructor injection** - dependencies as constructor parameters
3. **Run build_runner** after adding new injectable classes
4. **Repositories should be singletons** - use `@LazySingleton()`
5. **BLoCs should be factories** - use `@injectable`
6. **Don't use getIt directly in widgets** - use BlocProvider instead

## Theming

### Material 3 Design System

The app implements Material 3 with custom design tokens:

**Color Scheme:**
- Primary: Blue 600 (#1E88E5)
- Secondary: Amber 600 (#FFB300)
- Light background: #FAFAFA
- Dark background: #121212

**Spacing System (8dp base unit):**
- XS: 4dp
- S: 8dp
- M: 16dp
- L: 24dp
- XL: 32dp

**Typography:**
- Display Large: 32sp (Turn indicators)
- Title Large: 24sp (Page titles)
- Body Large: 16sp (Main text)
- Label Large: 14sp (Captions)

**Theme Access:**
```dart
// Access theme in widgets
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;
final textTheme = theme.textTheme;

// Use theme colors
Container(
  color: colorScheme.primary,
  child: Text(
    'Hello',
    style: textTheme.titleLarge,
  ),
)

// Use spacing constants
Padding(
  padding: const EdgeInsets.all(AppTheme.spacingM),
  child: child,
)
```

### Dynamic Theme Switching

Theme changes are managed by `ThemeBloc`:
```dart
// Change theme
context.read<ThemeBloc>().add(const ThemeChanged(ThemePreference.dark));

// Listen to theme changes
BlocBuilder<ThemeBloc, ThemeState>(
  builder: (context, state) {
    return MaterialApp(
      themeMode: state.themeMode, // system, light, or dark
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
    );
  },
)
```

## Testing Strategy

### Test Organization

Tests mirror the `lib/` structure:
```
test/
├── core/
├── data/
├── domain/
├── presentation/
└── helpers/
```

### Testing Levels

**1. Unit Tests**
- Test individual functions and classes
- Mock all dependencies
- Fast and isolated

**2. Widget Tests**
- Test UI components
- Verify widget behavior
- Use `flutter_test` package

**3. BLoC Tests**
- Test state management logic
- Use `bloc_test` package
- Verify state transitions

**4. Integration Tests**
- Test feature flows
- Minimal mocking
- Test realistic scenarios

### Testing Tools

**Dependencies:**
- `flutter_test`: Widget and unit testing
- `bloc_test`: BLoC testing utilities
- `mocktail`: Mocking framework

**Test Helpers:**
```dart
// test/helpers/test_helpers.dart
class MockThemeRepository extends Mock implements ThemeRepository {}

Future<void> setupTestDI() async {
  final getIt = GetIt.instance;
  await getIt.reset();

  final mockCubit = MockGameModeCubit();
  when(() => mockCubit.state).thenReturn(initialState);

  getIt.registerSingleton<GameModeCubit>(mockCubit);
}
```

### BLoC Testing Pattern

```dart
void main() {
  late ThemeRepository mockRepository;
  late ThemeBloc themeBloc;

  setUp(() {
    mockRepository = MockThemeRepository();
    themeBloc = ThemeBloc(mockRepository);
  });

  tearDown(() {
    themeBloc.close();
  });

  blocTest<ThemeBloc, ThemeState>(
    'ThemeChanged should save and update state',
    setUp: () {
      when(() => mockRepository.saveThemeSettings(any()))
          .thenAnswer((_) async {});
    },
    build: () => themeBloc,
    act: (bloc) => bloc.add(const ThemeChanged(ThemePreference.dark)),
    expect: () => [
      const ThemeState(isLoading: true),
      const ThemeState(preference: ThemePreference.dark, isLoading: false),
    ],
    verify: (_) {
      verify(() => mockRepository.saveThemeSettings(any())).called(1);
    },
  );
}
```

### Widget Testing Pattern

```dart
void main() {
  testWidgets('HomePage displays mode selection buttons', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => MockGameModeCubit(),
          child: const HomePage(),
        ),
      ),
    );

    expect(find.text('Player vs Player'), findsOneWidget);
    expect(find.text('Player vs AI'), findsOneWidget);
  });
}
```

### Testing Best Practices

1. **Test behavior, not implementation** - focus on what, not how
2. **Use descriptive test names** - explain what is being tested
3. **Arrange-Act-Assert pattern** - clear test structure
4. **Mock external dependencies** - use mocktail for repositories
5. **Test edge cases** - null values, errors, empty states
6. **Clean up resources** - close BLoCs in tearDown
7. **Use test helpers** - centralize mock setup
8. **Aim for high coverage** - target 80%+ code coverage

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/presentation/blocs/theme/theme_bloc_test.dart

# Watch mode (using external tool)
flutter test --watch
```

## Code Organization Standards

### File Naming

- **Dart files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `camelCase` or `SCREAMING_SNAKE_CASE` for compile-time constants

**Examples:**
```dart
// File: theme_repository.dart
class ThemeRepository { }

// File: game_mode.dart
enum GameMode { }

// File: navigation_behavior.dart
mixin NavigationBehavior { }
```

### Directory Organization

**Feature-based organization:**
```
presentation/
├── blocs/
│   ├── game/           # All game-related BLoC files
│   ├── theme/          # All theme-related BLoC files
│   └── settings/       # All settings-related BLoC files
├── pages/              # Full-screen pages
└── widgets/            # Reusable widgets
```

**Single Responsibility:**
- One class per file
- Related classes (event/state) can share a directory
- Utility functions in separate files

### Import Organization

**Order of imports:**
1. Dart SDK imports
2. Flutter imports
3. Package imports
4. Relative imports

**Example:**
```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/models/theme_preference.dart';
import '../repositories/theme_repository.dart';
```

**Best Practices:**
- Avoid relative imports across layers (`avoid_relative_lib_imports`)
- Group imports by type
- Keep imports sorted alphabetically within groups

## Coding Standards

### Code Style

The project enforces strict linting rules via `analysis_options.yaml`:

**Key Rules:**
- `prefer_single_quotes`: Use single quotes for strings
- `prefer_const_constructors`: Use const where possible
- `always_declare_return_types`: Explicit return types
- `prefer_final_fields`: Use final for immutable fields
- `prefer_final_locals`: Use final for local variables
- `avoid_print`: Use logging instead of print

**Example:**
```dart
// Good
const SizedBox(height: 16)
final String userName = 'John';

Future<void> loadData() async { }

// Bad
SizedBox(height: 16)  // Missing const
String userName = 'John';  // Missing final

loadData() async { }  // Missing return type
```

### Documentation

**Class Documentation:**
```dart
/// Repository for persisting theme preferences
///
/// Follows Clean Architecture - handles data persistence only.
/// Uses SharedPreferences for local storage.
@LazySingleton()
class ThemeRepository {
  /// Saves theme settings to persistent storage
  Future<void> saveThemeSettings(ThemeSettings settings) async {
    // Implementation
  }
}
```

**Complex Logic:**
```dart
// Initialize dependency injection
// Note: injection.config.dart is generated by build_runner
// Run: flutter pub run build_runner build
configureDependencies();
```

**Documentation Best Practices:**
1. Document public APIs
2. Explain "why", not "what"
3. Document complex algorithms
4. Keep comments up-to-date
5. Use /// for documentation comments
6. Use // for inline comments

### Error Handling

**Repository Error Handling:**
```dart
Future<ThemeSettings> loadThemeSettings() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) {
      return const ThemeSettings(); // Default value
    }

    return ThemeSettings.fromJson(jsonDecode(jsonString));
  } catch (e) {
    // Log error and return default
    await deleteThemeSettings(); // Cleanup corrupted data
    return const ThemeSettings();
  }
}
```

**BLoC Error Handling:**
```dart
Future<void> _onThemeInitialized(
  ThemeInitialized event,
  Emitter<ThemeState> emit,
) async {
  emit(state.copyWith(isLoading: true));

  try {
    final settings = await _themeRepository.loadThemeSettings();
    emit(ThemeState(preference: settings.preference, isLoading: false));
  } catch (e) {
    // Revert to safe default state
    emit(const ThemeState(isLoading: false, hasError: true));
  }
}
```

**Best Practices:**
1. **Always handle async errors** with try-catch
2. **Provide fallback values** for failures
3. **Log errors** for debugging
4. **Don't expose implementation details** in error messages
5. **Clean up invalid data** when detected
6. **Use specific exception types** when appropriate

## Common Patterns

### 1. Creating a New Feature

**Step-by-step guide:**

1. **Create domain model** (`lib/domain/models/my_feature.dart`)
```dart
class MyFeature extends Equatable {
  final String id;
  final String name;

  const MyFeature({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
```

2. **Create repository** (`lib/data/repositories/my_feature_repository.dart`)
```dart
@LazySingleton()
class MyFeatureRepository {
  Future<MyFeature> loadFeature() async {
    // Implementation
  }
}
```

3. **Create BLoC/Cubit** (`lib/presentation/blocs/my_feature/`)
```dart
// my_feature_event.dart
sealed class MyFeatureEvent extends Equatable { }

// my_feature_state.dart
class MyFeatureState extends Equatable { }

// my_feature_bloc.dart
@injectable
class MyFeatureBloc extends Bloc<MyFeatureEvent, MyFeatureState> { }
```

4. **Create UI** (`lib/presentation/pages/my_feature_page.dart`)
```dart
class MyFeaturePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyFeatureBloc, MyFeatureState>(
      builder: (context, state) {
        return Scaffold(/* ... */);
      },
    );
  }
}
```

5. **Add route** (`lib/routes/app_router.dart`)
```dart
GoRoute(
  path: '/my-feature',
  name: 'my-feature',
  builder: (context, state) => const MyFeaturePage(),
)
```

6. **Run code generation**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

7. **Write tests**
```
test/
├── domain/models/my_feature_test.dart
├── data/repositories/my_feature_repository_test.dart
└── presentation/blocs/my_feature/my_feature_bloc_test.dart
```

### 2. Adding a New Repository

```dart
// 1. Create interface (optional, recommended)
abstract class IThemeRepository {
  Future<ThemeSettings> loadThemeSettings();
  Future<void> saveThemeSettings(ThemeSettings settings);
}

// 2. Implement repository
@LazySingleton(as: IThemeRepository) // Register as interface
class ThemeRepository implements IThemeRepository {
  @override
  Future<ThemeSettings> loadThemeSettings() async {
    // Implementation
  }
}

// 3. Inject in BLoC
@injectable
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final IThemeRepository _repository;

  ThemeBloc(this._repository) : super(const ThemeState());
}
```

### 3. Creating Reusable Widgets

```dart
// lib/presentation/widgets/custom_button.dart
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const CircularProgressIndicator()
          : Text(label),
    );
  }
}
```

### 4. Extension Methods for UI

```dart
// lib/presentation/extensions/game_mode_ui_extensions.dart
extension GameModeUI on GameMode {
  String get displayName {
    switch (this) {
      case GameMode.playerVsPlayer:
        return 'Player vs Player';
      case GameMode.playerVsAi:
        return 'Player vs AI';
    }
  }

  IconData get icon {
    switch (this) {
      case GameMode.playerVsPlayer:
        return Icons.people;
      case GameMode.playerVsAi:
        return Icons.smart_toy;
    }
  }
}

// Usage
Text(gameMode.displayName)
Icon(gameMode.icon)
```

### 5. Dialog Pattern

```dart
// lib/presentation/widgets/exit_game_dialog.dart
class ExitGameDialog extends StatelessWidget {
  const ExitGameDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Exit Game?'),
      content: const Text('Your progress will be lost.'),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => context.pop(true),
          child: const Text('Exit'),
        ),
      ],
    );
  }
}

// Usage
final result = await showDialog<bool>(
  context: context,
  builder: (_) => const ExitGameDialog(),
);

if (result == true) {
  // User confirmed exit
}
```

## Debugging

### BLoC Observer

All BLoC events and state changes are logged via `AppBlocObserver`:

```dart
// In main.dart
Bloc.observer = const AppBlocObserver(enableVerboseLogging: true);

// Logs output:
// onCreate -- ThemeBloc
// onEvent -- ThemeBloc, Event: ThemeChanged
// onChange -- ThemeBloc, CurrentState: ThemeState, NextState: ThemeState
```

**Disable verbose logging in production:**
```dart
Bloc.observer = const AppBlocObserver(enableVerboseLogging: false);
```

### Flutter DevTools

Enable Flutter DevTools for:
- Widget inspector
- Performance profiling
- Network monitoring
- Memory analysis

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

## Performance Considerations

### 1. Const Constructors

Use `const` constructors wherever possible to reduce widget rebuilds:
```dart
const SizedBox(height: 16)
const Padding(padding: EdgeInsets.all(8.0))
```

### 2. BLoC Optimization

**Avoid unnecessary rebuilds:**
```dart
// Good - rebuilds only when specific property changes
BlocBuilder<ThemeBloc, ThemeState>(
  buildWhen: (previous, current) => previous.preference != current.preference,
  builder: (context, state) { },
)

// Bad - rebuilds on every state change
BlocBuilder<ThemeBloc, ThemeState>(
  builder: (context, state) { },
)
```

### 3. Widget Keys

Use keys for lists and conditionally rendered widgets:
```dart
ListView.builder(
  itemBuilder: (context, index) {
    return ListTile(
      key: ValueKey(items[index].id),
      title: Text(items[index].name),
    );
  },
)
```

## Conclusion

This architecture provides a solid foundation for building scalable Flutter applications. Key takeaways:

- **Clean Architecture** separates concerns across layers
- **BLoC Pattern** manages state predictably
- **Dependency Injection** enables testability
- **Comprehensive Testing** ensures reliability
- **Consistent Standards** improve maintainability

For questions or suggestions, refer to the project's README.md or consult with the development team.
