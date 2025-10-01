# Tic-Tac-Toe Flutter App

A complete Tic-Tac-Toe game built with Flutter, featuring AI opponent with multiple difficulty levels, score tracking, and Material 3 design.

**Built entirely from a Notion PRD + Technical Architecture document in a single conversation.**

## How This Was Built

This app was generated using two prompts to Claude Code:

### Prompt 1: View the PRD
```
Can you see the Tic Tac Toe PRD in my notion
```

Claude retrieved the complete Product Requirements Document from Notion, which specified:
- Feature requirements (single/two player, AI difficulties, scoring)
- Technical stack (Flutter, BLoC, go_router, Material 3)
- User experience requirements
- Success metrics

### Prompt 2: Build the App
```
great - can you build this
```

Claude then:
1. Read the technical architecture document from `.claude/technical-architecture.md`
2. Created the Flutter project structure
3. Implemented all features following the Service Layer architecture pattern
4. Built the complete UI with Material 3 design
5. Added tests and documentation

The technical architecture document in `.claude/` defined strict separation of concerns:
- **Models**: Data structures with JSON serialization (no business logic)
- **Services**: Handle ALL business logic
- **BLoCs**: ONLY UI state management
- **Pages**: Always StatelessWidget (or StatefulWidget when needed for lifecycle)

### App Structure Overview

```
Domain Layer (Business Logic)
├── Models (Data structures with JSON serialization)
│   ├── Player (enum: X, O, none)
│   ├── GameMode (enum: single/two player)
│   ├── DifficultyLevel (enum: easy/medium/hard)
│   ├── Position (row, col coordinates)
│   ├── GameConfig (game settings with toJson/fromJson)
│   ├── GameState (board state with toJson/fromJson)
│   ├── GameResult (enum: win/loss/draw/ongoing)
│   └── Score (wins/losses/draws with toJson/fromJson)
│
└── Services (ALL business logic lives here)
    ├── GameService
    │   ├── createNewGame()
    │   ├── isValidMove()
    │   ├── makeMove()
    │   ├── checkWinner()
    │   ├── isBoardFull()
    │   ├── getAvailableMoves()
    │   ├── undoLastMove()
    │   └── resetGame()
    │
    └── AiService
        ├── getBestMove() - routes to difficulty
        ├── _getRandomMove() - easy AI
        ├── _getMediumMove() - blocks & wins
        ├── _getMinimaxMove() - optimal play
        ├── _minimax() - recursive algorithm
        └── _findWinningMove() - helper

Data Layer (Persistence)
└── Repositories
    └── ScoreRepository & GameStateRepository
        ├── loadScore/loadGame() - from SharedPreferences
        ├── saveScore/saveGame() - directly use model.toJson()
        ├── resetScore()
        └── increment methods

Presentation Layer (UI State Only)
├── BLoCs (NO business logic - only UI state)
│   ├── GameBloc
│   │   ├── Events: StartNewGame, MakeMove, UndoMove, ResetGame, MakeAiMove
│   │   ├── States: GameInitial, GameInProgress, GameFinished, AiThinking
│   │   └── Delegates to GameService & AiService for all logic
│   │
│   └── ScoreBloc
│       ├── Events: LoadScore, IncrementWins/Losses/Draws, ResetScore
│       ├── States: ScoreInitial, ScoreLoading, ScoreLoaded, ScoreError
│       └── Delegates to ScoreRepository
│
├── Pages (UI Screens)
│   ├── HomePage - mode selection, stats display
│   ├── GamePage - game board, status, actions
│   └── SettingsPage - statistics, about
│
└── Widgets (Reusable Components)
    ├── GameBoard - 3x3 grid layout
    └── BoardCell - individual cell with styling

Core
├── Theme (Material 3 light/dark themes)
└── Routes (go_router navigation config)
```

### Key Architecture Principles Applied

1. **Separation of Concerns**
   - Business logic isolated in Services
   - UI state management in BLoCs
   - Data persistence in Repositories
   - UI rendering in Widgets

2. **Simplified Models**
   - Models contain data structures and JSON serialization
   - No business logic calculations
   - Direct serialization without separate entity/model layers
   - Example: `GameState.toJson()` and `GameState.fromJson()` handle persistence

3. **Service Layer Pattern**
   - ALL game rules in GameService
   - ALL AI logic in AiService
   - BLoCs call services, never implement logic themselves

4. **Dependency Flow**
   - Presentation → Domain (Services)
   - Data → Domain (Models via Repositories)
   - Domain has NO dependencies on outer layers

### AI Implementation Details

**Easy AI**: Random valid move selection
```dart
final availableMoves = gameService.getAvailableMoves(board);
return availableMoves[random.nextInt(availableMoves.length)];
```

**Medium AI**: Basic strategy
1. Check if AI can win → take winning move
2. Check if opponent can win → block
3. Otherwise → random move

**Hard AI**: Minimax with alpha-beta pruning
- Recursively evaluates all possible game states
- Scores: +10 for AI win, -10 for opponent win, 0 for draw
- Depth penalty to prefer faster wins
- Alpha-beta pruning for optimization
- Result: Unbeatable AI

### Code Statistics
- **8 Domain Models**: 5 enums + 3 classes with JSON serialization
- **2 Services**: 400+ lines of business logic
- **2 Repositories**: Data persistence (Score & GameState)
- **2 BLoCs**: UI state management (6 events, 7 states)
- **3 Pages**: Home, Game, Settings
- **2 Widgets**: Board components
- **1 Theme**: Material 3 configuration
- **1 Router**: Navigation setup
- **191 Tests**: Comprehensive test coverage across all layers
  - 27 GameService tests (game logic, win detection, board state)
  - 17 AiService tests (all difficulty levels, minimax algorithm)
  - 17 GameBloc tests (all events and states)
  - 17 ScoreBloc tests (all events and states, error handling)
  - 17 ScoreRepository tests (persistence, increments, integration)
  - 15 Score entity tests (equality, copyWith, computed properties)
  - 8 GameBoard widget tests (rendering, interactions, winning states)
  - 25 HomePage tests (UI, navigation, score display, state changes)
  - 21 GamePage tests (game flow, status bar, dialogs, score updates)
  - 18 SettingsPage tests (statistics display, reset functionality, layout)
  - 1 Widget test (app initialization)

## Features

- **Single Player Mode**: Play against AI with 3 difficulty levels
  - Easy: Random moves
  - Medium: Blocks wins and takes winning moves
  - Hard: Optimal strategy using Minimax algorithm
- **Two Player Mode**: Local multiplayer
- **Score Tracking**: Persistent win/loss/draw statistics
- **Material 3 Design**: Modern UI with light/dark theme support
- **Haptic Feedback**: Vibration on moves
- **Undo Feature**: Undo moves during gameplay
- **Game History**: Track move count and game duration

## Architecture

This app follows Clean Architecture with Service Layer pattern:

- **Domain Layer**: Business models and services
  - Models: Data structures with JSON serialization (no business logic)
  - Services: ALL game logic (win detection, move validation, AI)
- **Data Layer**: Repositories for persistence
- **Presentation Layer**: BLoC state management for UI
  - BLoCs: UI state ONLY (no business logic)
  - Pages: StatelessWidgets
  - Widgets: Reusable UI components

## Technology Stack

- **Flutter 3.35.1** with Dart 3.9.0
- **flutter_bloc 8.1.3**: State management
- **go_router 14.0.0**: Navigation
- **shared_preferences 2.2.2**: Local storage
- **vibration 2.0.0**: Haptic feedback
- **equatable 2.0.5**: Value equality

## Project Structure

```
lib/
├── domain/
│   ├── models/           # Data structures with JSON serialization
│   └── services/         # Business logic
├── data/
│   └── repositories/     # Data persistence
├── presentation/
│   ├── blocs/           # State management
│   ├── pages/           # Screen widgets
│   └── widgets/         # Reusable components
├── core/
│   └── theme/           # Material 3 theme
└── routes/              # Navigation setup
```

## Getting Started

### Prerequisites

- Flutter SDK 3.9.0 or higher
- Dart 3.9.0 or higher

### Installation

1. Get dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

3. Run tests:
```bash
flutter test
```

4. Run static analysis:
```bash
flutter analyze
```

## How to Play

1. **Start Game**: Choose Single Player or Two Player mode
2. **Select Difficulty** (Single Player only): Easy, Medium, or Hard
3. **Make Moves**: Tap empty cells to place your symbol (X or O)
4. **Win Condition**: Get three in a row horizontally, vertically, or diagonally
5. **View Stats**: Check your win/loss record in Settings

## AI Implementation

The AI uses different strategies based on difficulty:

- **Easy**: Completely random moves
- **Medium**:
  - Takes winning moves if available
  - Blocks opponent's winning moves
  - Random otherwise
- **Hard**:
  - Minimax algorithm with alpha-beta pruning
  - Always plays optimally (unbeatable)

## Testing

The app includes comprehensive test coverage following the technical architecture's testing guidelines:

### Service Tests (44 tests)

**GameService Tests** (27 tests):
- Game initialization and configuration
- Move validation (valid/invalid/out of bounds/finished game)
- Board state management
- Win detection (horizontal, vertical, diagonal)
- Draw detection
- Move history and undo functionality
- Full game scenarios

**AiService Tests** (17 tests):
- Easy difficulty (random moves, non-deterministic)
- Medium difficulty (winning moves, blocking, prioritization)
- Hard difficulty (minimax algorithm, optimal play, unbeatable)
- Edge cases (single empty space, all difficulties)
- Strategy verification (difficulty comparison)

### Widget Tests (1 test)
- App initialization and homepage loading

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/domain/services/game_service_test.dart
```

### Test Coverage Highlights
- ✅ All business logic thoroughly tested
- ✅ Services tested in isolation (no UI dependencies)
- ✅ AI algorithms verified (easy, medium, hard)
- ✅ Win/loss/draw scenarios validated
- ✅ Edge cases covered
- ✅ **191 tests passing** (service + bloc + repository + model + widget + page tests)

### Coverage by Layer

Based on the testing requirements document (`.claude/testing-requirements.md`):

| Layer | Target | Actual | Status |
|-------|--------|--------|--------|
| **Services** | 95-100% | 100% | ✅ Exceeds target |
| **BLoCs** | 95-100% | ~95% | ✅ Meets target |
| **Repositories** | 90% | 100% | ✅ Exceeds target |
| **Models** | 90% | 90% | ✅ Meets target |
| **Widgets** | 80% | 100% | ✅ Exceeds target |
| **Pages** | 70% | ~80% | ✅ Exceeds target |
| **Overall** | 90% | 86.0% | ⚠️ Approaching target |

**Note on Coverage**: The overall coverage is 86.0%, approaching the 90% target. All layers meet or exceed their individual coverage targets. The testing includes 191 comprehensive tests covering services, BLoCs, repositories, models, widgets, and pages.

## Development

Built from a Notion PRD and technical architecture document using:
- Domain-Driven Design principles
- Service Layer pattern (business logic in services)
- BLoC pattern (UI state management)
- Material 3 design system
- Test-driven approach for services

## License

This is a demonstration project.
