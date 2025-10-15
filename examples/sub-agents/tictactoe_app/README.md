# Tic-Tac-Toe Flutter App

A modern Tic-Tac-Toe game built with Flutter using Clean Architecture and the BLoC pattern for state management.

## Features

- **Multiple Game Modes**: Player vs Player, Player vs AI (Easy/Medium/Hard)
- **Material 3 Design**: Modern UI with light/dark theme support
- **Game History**: Review past games and their outcomes
- **Clean Architecture**: Maintainable, testable, and scalable codebase
- **Comprehensive Testing**: 304+ tests with high coverage

## Tech Stack

- **Flutter 3.x** - Cross-platform UI framework
- **Dart 3.9+** - Programming language
- **flutter_bloc 8.1.6** - State management
- **go_router 14.6.1** - Declarative routing
- **get_it + injectable** - Dependency injection
- **shared_preferences** - Local data persistence
- **Material 3** - Design system

## Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK 3.x](https://docs.flutter.dev/get-started/install)
- [Dart SDK 3.9+](https://dart.dev/get-dart) (included with Flutter)
- IDE: [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)
- For iOS development: [Xcode](https://developer.apple.com/xcode/) (macOS only)
- For Android development: [Android SDK](https://developer.android.com/studio)

### Verify Installation

```bash
flutter doctor
```

This command checks your environment and displays a report of the status of your Flutter installation.

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd tictactoe_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code

The project uses code generation for dependency injection. Run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates the `injection.config.dart` file needed for dependency injection.

### 4. Run the App

```bash
# Run on default device
flutter run

# Run on specific device
flutter devices  # List available devices
flutter run -d <device-id>

# Run in release mode
flutter run --release
```

## Project Structure

```
lib/
├── core/                 # Core functionality (DI, theming, navigation)
├── data/                 # Data layer (repositories, data sources)
├── domain/               # Domain layer (models, business logic)
├── presentation/         # Presentation layer (UI, BLoCs, widgets)
├── routes/               # Navigation configuration
└── main.dart            # App entry point

test/                    # Mirror structure of lib/ for tests
```

For detailed architecture documentation, see [ARCHITECTURE.md](ARCHITECTURE.md).

## Development Workflow

### Code Generation

When you add or modify injectable classes, run:

```bash
# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-generates on file changes)
flutter pub run build_runner watch
```

### Code Formatting

The project uses Flutter's default formatting:

```bash
# Format all Dart files
flutter format .

# Format specific file
flutter format lib/main.dart

# Check formatting without applying
flutter format --dry-run .
```

### Linting

Check code quality:

```bash
flutter analyze
```

Fix auto-fixable issues:

```bash
dart fix --apply
```

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage report
flutter test --coverage

# Run specific test file
flutter test test/presentation/blocs/theme/theme_bloc_test.dart

# Run tests in a specific directory
flutter test test/presentation/

# Verbose output
flutter test --verbose
```

### Coverage Report

After running tests with coverage:

```bash
# Install lcov (macOS)
brew install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html
```

## Building the App

### Android

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# App bundle for Play Store
flutter build appbundle --release
```

### iOS

```bash
# Debug build
flutter build ios --debug

# Release build (requires code signing)
flutter build ios --release

# Open in Xcode for further configuration
open ios/Runner.xcworkspace
```

### macOS

```bash
flutter build macos --release
```

### Web

```bash
flutter build web --release
```

## Common Tasks

### Adding a New Feature

1. Create domain model in `lib/domain/models/`
2. Create repository in `lib/data/repositories/`
3. Create BLoC/Cubit in `lib/presentation/blocs/`
4. Create UI page in `lib/presentation/pages/`
5. Add route in `lib/routes/app_router.dart`
6. Run code generation: `flutter pub run build_runner build`
7. Write tests for each component

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed patterns.

### Adding Dependencies

1. Add package to `pubspec.yaml`:
```yaml
dependencies:
  new_package: ^1.0.0
```

2. Install:
```bash
flutter pub get
```

3. Import in your code:
```dart
import 'package:new_package/new_package.dart';
```

### Debugging

#### Enable BLoC Logging

In `lib/main.dart`, the `AppBlocObserver` is configured with verbose logging:

```dart
Bloc.observer = const AppBlocObserver(enableVerboseLogging: true);
```

Set to `false` in production to reduce log noise.

#### Flutter DevTools

```bash
# Install DevTools
flutter pub global activate devtools

# Run DevTools
flutter pub global run devtools

# In another terminal, run your app
flutter run --observatory-port=9100
```

Then open http://localhost:9100 in DevTools.

## Troubleshooting

### Build Runner Issues

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Dependency Conflicts

```bash
# Check for outdated packages
flutter pub outdated

# Update dependencies
flutter pub upgrade

# Resolve conflicts
flutter pub downgrade <package>
```

### iOS Build Issues

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

### Android Build Issues

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter run
```

## Architecture

This project follows Clean Architecture principles with three main layers:

1. **Domain Layer** - Business logic and entities
2. **Data Layer** - Data sources and repositories
3. **Presentation Layer** - UI and state management

For comprehensive architecture documentation, including:
- BLoC pattern guidelines
- State management best practices
- Navigation approach
- Testing strategy
- Code organization standards

See [ARCHITECTURE.md](ARCHITECTURE.md).

## Coding Standards

The project enforces strict linting rules defined in `analysis_options.yaml`:

- Use single quotes for strings
- Prefer `const` constructors
- Always declare return types
- Use `final` for immutable variables
- Avoid `print()` statements (use logging)

## Testing

The project maintains high test coverage with:

- **Unit Tests** - For business logic and models
- **Widget Tests** - For UI components
- **BLoC Tests** - For state management
- **Integration Tests** - For complete flows

Current test count: **304+ tests**

### Testing Guidelines

- Write tests for all new features
- Aim for 80%+ code coverage
- Use descriptive test names
- Mock external dependencies
- Test edge cases and error scenarios

See [ARCHITECTURE.md - Testing Strategy](ARCHITECTURE.md#testing-strategy) for detailed patterns.

## Contributing

### Branch Naming

Follow this format for feature branches:

```
lwisne/LWI-<ISSUE-ID>-<short-description>
```

Example: `lwisne/LWI-98-architecture-documentation`

### Pull Request Process

1. Create a feature branch from `main`
2. Implement your changes
3. Run tests: `flutter test`
4. Format code: `flutter format .`
5. Run linter: `flutter analyze`
6. Push to your branch
7. Create a Pull Request to `main`

### Commit Message Format

```
<type>: <short summary>

<detailed description>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Example:
```
feat: Add dark mode theme support

Implemented ThemeBloc to manage theme preferences.
Added Material 3 dark theme with proper color tokens.
Persists user preference using SharedPreferences.
```

## Resources

### Flutter Documentation

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Material Design 3](https://m3.material.io/)

### State Management

- [BLoC Library](https://bloclibrary.dev/)
- [flutter_bloc Package](https://pub.dev/packages/flutter_bloc)
- [BLoC Architecture Guide](https://bloclibrary.dev/#/architecture)

### Testing

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [bloc_test Package](https://pub.dev/packages/bloc_test)
- [mocktail Package](https://pub.dev/packages/mocktail)

### Navigation

- [go_router Package](https://pub.dev/packages/go_router)
- [go_router Documentation](https://gorouter.dev/)

## License

This project is for educational purposes.

## Support

For questions or issues:
- Review [ARCHITECTURE.md](ARCHITECTURE.md) for technical details
- Check existing issues in the repository
- Contact the development team
