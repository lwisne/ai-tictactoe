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
- **Models**: THIN data structures only (no business logic)
- **Services**: Handle ALL business logic
- **BLoCs**: ONLY UI state management
- **Pages**: Always StatelessWidget (or StatefulWidget when needed for lifecycle)

### App Structure Overview

```
Domain Layer (Business Logic)
├── Entities (Thin Models - NO business logic)
│   ├── Player (enum: X, O, none)
│   ├── GameMode (enum: single/two player)
│   ├── DifficultyLevel (enum: easy/medium/hard)
│   ├── Position (row, col coordinates)
│   ├── GameConfig (game settings)
│   ├── GameState (board state, current player, result)
│   ├── GameResult (enum: win/loss/draw/ongoing)
│   └── Score (wins/losses/draws)
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
    └── ScoreRepository
        ├── loadScore() - from SharedPreferences
        ├── saveScore()
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

2. **Thin Models**
   - Entities contain ONLY data and simple getters
   - No methods that perform calculations or business logic
   - Example: `Player.opponent` getter is allowed, but win detection is not

3. **Service Layer Pattern**
   - ALL game rules in GameService
   - ALL AI logic in AiService
   - BLoCs call services, never implement logic themselves

4. **Dependency Flow**
   - Presentation → Domain (Services)
   - Data → Domain (Services via Repositories)
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
- **8 Domain Entities**: 5 enums + 3 classes (all thin)
- **2 Services**: 400+ lines of business logic
- **1 Repository**: Data persistence
- **2 BLoCs**: UI state management (6 events, 7 states)
- **3 Pages**: Home, Game, Settings
- **2 Widgets**: Board components
- **1 Theme**: Material 3 configuration
- **1 Router**: Navigation setup

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

- **Domain Layer**: Business entities and services
  - Entities: Thin models with no business logic
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
│   ├── entities/          # Thin data models
│   └── services/          # Business logic
├── data/
│   └── repositories/      # Data persistence
├── presentation/
│   ├── blocs/            # State management
│   ├── pages/            # Screen widgets
│   └── widgets/          # Reusable components
├── core/
│   └── theme/            # Material 3 theme
└── routes/               # Navigation setup
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

## Development

Built from a Notion PRD and technical architecture document using:
- Domain-Driven Design principles
- Service Layer pattern (business logic in services)
- BLoC pattern (UI state management)
- Material 3 design system

## License

This is a demonstration project.
