# Architecture Specifications for Tic-Tac-Toe Application

## Section 5: Architecture Specifications

### 5.0 Overview

This Tic-Tac-Toe application follows a **Clean Architecture** approach with clear separation of concerns across three primary layers: Domain, Data, and Presentation. The architecture enforces strict boundaries to ensure maintainability, testability, and scalability.

**Core Architectural Principles:**
- **Single Responsibility**: Each layer has one clear purpose
- **Dependency Rule**: Dependencies flow inward (Presentation → Domain ← Data)
- **Separation of Concerns**: Models = data structure, Services = business logic, Blocs = UI state coordination
- **No Business Logic in Models**: Models are pure data containers with serialization only
- **No Business Logic in Blocs**: Blocs coordinate services and manage UI state only

---

## 5.1 Layer Architecture

### 5.1.1 Folder Structure

```
lib/
├── core/                           # Shared utilities and configuration
│   ├── constants/                  # App-wide constants
│   ├── theme/                      # Theme configuration
│   │   └── app_theme.dart
│   └── utils/                      # Utility functions
│
├── domain/                         # Business logic layer (PURE DART)
│   ├── models/                     # Data models (NO business logic)
│   │   ├── difficulty_level.dart   # Enum: easy, medium, hard
│   │   ├── game_config.dart        # Configuration data model
│   │   ├── game_mode.dart          # Enum: singlePlayer, twoPlayer
│   │   ├── game_result.dart        # Enum: ongoing, win, loss, draw
│   │   ├── game_state.dart         # Complete game state model
│   │   ├── player.dart             # Enum: x, o, none
│   │   ├── position.dart           # Board position model
│   │   └── score.dart              # Score tracking model
│   │
│   └── services/                   # Business logic (ALL logic here)
│       ├── game_service.dart       # Game rules and mechanics
│       └── ai_service.dart         # AI move calculation
│
├── data/                           # Data persistence layer
│   └── repositories/               # Repository implementations
│       ├── game_state_repository.dart  # Game save/load
│       └── score_repository.dart       # Score persistence
│
├── presentation/                   # UI layer (Flutter-specific)
│   ├── blocs/                      # State management (NO business logic)
│   │   ├── game_bloc/
│   │   │   ├── game_bloc.dart      # Game flow coordination
│   │   │   ├── game_event.dart     # User actions
│   │   │   └── game_state.dart     # UI states
│   │   └── score_bloc/
│   │       ├── score_bloc.dart     # Score coordination
│   │       ├── score_event.dart
│   │       └── score_state.dart
│   │
│   ├── extensions/                 # Display logic (presentation only)
│   │   ├── player_extensions.dart  # Player display symbols
│   │   └── game_result_extensions.dart  # Result display text
│   │
│   ├── pages/                      # Full-screen views
│   │   ├── home_page.dart
│   │   ├── game_page.dart
│   │   └── settings_page.dart
│   │
│   └── widgets/                    # Reusable UI components
│       ├── game_board.dart
│       └── board_cell.dart
│
├── routes/                         # Navigation configuration
│   └── app_router.dart
│
└── main.dart                       # Application entry point

test/                               # Mirror lib/ structure
├── domain/
│   ├── models/
│   └── services/
├── data/
│   └── repositories/
└── presentation/
    ├── blocs/
    ├── pages/
    └── widgets/
```

### 5.1.2 Layer Responsibilities

#### Domain Layer (Pure Dart - No Flutter Dependencies)
**Purpose**: Contains all business logic and domain models

**Responsibilities:**
- Define data structures (models)
- Implement game rules and mechanics (services)
- Provide business logic operations
- Define domain interfaces

**Forbidden:**
- Flutter/UI dependencies
- Direct storage access
- UI state management
- HTTP calls or external I/O

**Example:**
```dart
// ✅ CORRECT: Service contains business logic
class GameService {
  GameState makeMove(GameState state, Position position) {
    // Business logic here
  }
}

// ❌ INCORRECT: Model contains business logic
class GameState {
  bool isWinningMove(Position pos) { // NO! Logic belongs in service
    // ...
  }
}
```

#### Data Layer
**Purpose**: Handles data persistence and external data sources

**Responsibilities:**
- Implement repositories for data persistence
- Handle serialization/deserialization using model methods
- Manage SharedPreferences, databases, APIs
- Handle data caching strategies

**Forbidden:**
- Business logic (delegate to services)
- UI dependencies
- Direct UI state management

**Example:**
```dart
// ✅ CORRECT: Repository handles persistence only
class GameStateRepository {
  Future<void> saveGame(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.toJson()); // Uses model's toJson
    await prefs.setString(_savedGameKey, jsonString);
  }
}
```

#### Presentation Layer (Flutter-specific)
**Purpose**: Manages UI rendering and user interaction

**Responsibilities:**
- Coordinate services via Blocs
- Manage UI state (loading, error, success)
- Handle user input and navigation
- Display data using extensions for formatting
- Render widgets and animations

**Forbidden:**
- Business logic (use services)
- Direct repository access (use blocs)
- Complex calculations (use services)

**Example:**
```dart
// ✅ CORRECT: Bloc coordinates services
class GameBloc extends Bloc<GameEvent, GameBlocState> {
  final GameService _gameService;

  void _onMakeMove(MakeMove event, Emitter<GameBlocState> emit) {
    final newGameState = _gameService.makeMove(currentState, event.position);
    emit(GameInProgress(newGameState));
  }
}

// ❌ INCORRECT: Bloc contains business logic
void _onMakeMove(MakeMove event, Emitter<GameBlocState> emit) {
  // Checking win conditions here - should be in GameService!
  if (board[0][0] == board[1][1] && board[1][1] == board[2][2]) {
    // ...
  }
}
```

---

## 5.2 Domain Models

### 5.2.1 Model Design Philosophy

**Golden Rule**: Models are **pure data containers** with serialization only. NO business logic.

**Allowed in Models:**
- Properties (fields)
- Constructor
- `copyWith()` method
- `toJson()` method
- `fromJson()` factory
- `Equatable` props
- Simple getter calculations (e.g., `totalGames = wins + losses + draws`)

**Forbidden in Models:**
- Game logic
- Validation logic
- State transitions
- Complex calculations
- Side effects

### 5.2.2 Core Models

#### GameState Model
**Purpose**: Represents the complete state of a game at any point in time

```dart
class GameState extends Equatable {
  final List<List<Player>> board;           // 3x3 grid of players
  final Player currentPlayer;                // Whose turn it is
  final GameResult result;                   // Game outcome
  final Player? winner;                      // Winner if game finished
  final List<Position>? winningLine;         // Winning positions
  final List<Position> moveHistory;          // All moves made
  final GameConfig config;                   // Game configuration
  final DateTime startTime;                  // When game started
  final Duration elapsedTime;                // Time since start

  const GameState({
    required this.board,
    required this.currentPlayer,
    this.result = GameResult.ongoing,
    this.winner,
    this.winningLine,
    this.moveHistory = const [],
    required this.config,
    required this.startTime,
    this.elapsedTime = Duration.zero,
  });

  GameState copyWith({...}) { /* ... */ }

  Map<String, dynamic> toJson() { /* ... */ }
  factory GameState.fromJson(Map<String, dynamic> json) { /* ... */ }

  @override
  List<Object?> get props => [board, currentPlayer, result, ...];
}
```

**Key Points:**
- Immutable (all fields final)
- Uses `Equatable` for value comparison
- `copyWith()` for creating modified copies
- JSON methods use helper functions for enum conversion
- NO business logic - checking wins is in `GameService`

#### GameConfig Model
**Purpose**: Stores game configuration settings

```dart
class GameConfig extends Equatable {
  final GameMode gameMode;                   // Single or two player
  final DifficultyLevel? difficultyLevel;    // AI difficulty (if single player)
  final Player firstPlayer;                  // Who goes first
  final bool soundEnabled;                   // Sound effects on/off
  final bool vibrationEnabled;               // Haptic feedback on/off

  const GameConfig({
    required this.gameMode,
    this.difficultyLevel,
    required this.firstPlayer,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  GameConfig copyWith({...}) { /* ... */ }
  Map<String, dynamic> toJson() { /* ... */ }
  factory GameConfig.fromJson(Map<String, dynamic> json) { /* ... */ }
}
```

#### Score Model
**Purpose**: Tracks player statistics across games

```dart
class Score extends Equatable {
  final int wins;
  final int losses;
  final int draws;

  const Score({
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
  });

  // Simple calculated getters are allowed
  int get totalGames => wins + losses + draws;
  double get winRate => totalGames > 0 ? wins / totalGames : 0.0;

  Score copyWith({...}) { /* ... */ }
  Map<String, dynamic> toJson() { /* ... */ }
  factory Score.fromJson(Map<String, dynamic> json) { /* ... */ }
}
```

**Note**: Simple calculated getters like `totalGames` are acceptable because they're pure data transformations with no business logic.

#### Position Model
**Purpose**: Represents a board position

```dart
class Position extends Equatable {
  final int row;  // 0-2
  final int col;  // 0-2

  const Position({required this.row, required this.col});

  @override
  List<Object?> get props => [row, col];
}
```

### 5.2.3 Enums

All enums are **pure** with NO logic:

```dart
// Player enum - pure, no display logic
enum Player {
  x,
  o,
  none;

  // Domain logic: getting opponent is business rule
  Player get opponent {
    switch (this) {
      case Player.x: return Player.o;
      case Player.o: return Player.x;
      case Player.none: return Player.none;
    }
  }
}

enum GameMode {
  singlePlayer,
  twoPlayer;
}

enum DifficultyLevel {
  easy,
  medium,
  hard;
}

enum GameResult {
  ongoing,
  win,
  loss,
  draw;
}
```

**Display Logic Separation**: Display strings (like "Easy", "Medium", "Hard") live in presentation layer extensions, NOT in enums.

---

## 5.3 Service Layer Design

### 5.3.1 Service Philosophy

**ALL business logic lives in services.** Services are the brain of the application.

**Service Characteristics:**
- Stateless (no instance state)
- Pure functions (given same input → same output)
- No UI dependencies
- No direct storage access
- Testable with unit tests

### 5.3.2 GameService API

**Purpose**: Implements core game mechanics and rules

```dart
class GameService {
  /// Creates a new game with empty board
  GameState createNewGame(GameConfig config);

  /// Validates if a move is legal
  /// Returns false if:
  /// - Game is finished
  /// - Position out of bounds
  /// - Cell already occupied
  bool isValidMove(GameState state, Position position);

  /// Makes a move and returns new game state
  /// Handles:
  /// - Board update
  /// - Turn switching
  /// - Win/draw detection
  /// - Move history tracking
  /// - Time tracking
  GameState makeMove(GameState state, Position position);

  /// Checks if board is completely filled
  bool isBoardFull(List<List<Player>> board);

  /// Checks for winner
  /// Returns WinResult with winner and winning line, or null
  WinResult? checkWinner(List<List<Player>> board);

  /// Gets all available positions for next move
  List<Position> getAvailableMoves(List<List<Player>> board);

  /// Undoes last move (returns new state or null if no history)
  GameState? undoLastMove(GameState state);

  /// Resets game with same configuration
  GameState resetGame(GameState state);
}

/// Helper class returned by checkWinner
class WinResult {
  final Player winner;
  final List<Position> line;  // The winning line positions
}
```

**Example Implementation Pattern:**
```dart
GameState makeMove(GameState state, Position position) {
  // 1. Validate
  if (!isValidMove(state, position)) return state;

  // 2. Update board
  final newBoard = state.board.map((row) => List<Player>.from(row)).toList();
  newBoard[position.row][position.col] = state.currentPlayer;

  // 3. Check game outcome
  final winResult = checkWinner(newBoard);
  final gameResult = winResult != null
      ? (winResult.winner == state.currentPlayer ? GameResult.win : GameResult.loss)
      : (isBoardFull(newBoard) ? GameResult.draw : GameResult.ongoing);

  // 4. Return new state
  return state.copyWith(
    board: newBoard,
    currentPlayer: gameResult == GameResult.ongoing
        ? state.currentPlayer.opponent
        : state.currentPlayer,
    result: gameResult,
    winner: winResult?.winner,
    winningLine: winResult?.line,
  );
}
```

### 5.3.3 AIService API

**Purpose**: Calculates AI moves based on difficulty level

```dart
class AiService {
  final GameService _gameService;  // Depends on GameService for board analysis

  AiService(this._gameService);

  /// Gets the best move for AI based on difficulty
  Position getBestMove(
    List<List<Player>> board,
    Player aiPlayer,
    DifficultyLevel difficulty,
  );
}
```

**Difficulty Implementations:**

```dart
// Easy: Random valid move
Position _getRandomMove(List<List<Player>> board) {
  final availableMoves = _gameService.getAvailableMoves(board);
  return availableMoves[_random.nextInt(availableMoves.length)];
}

// Medium: Win if possible, block opponent, else random
Position _getMediumMove(List<List<Player>> board, Player aiPlayer) {
  // 1. Check if AI can win
  final winningMove = _findWinningMove(board, aiPlayer);
  if (winningMove != null) return winningMove;

  // 2. Check if need to block opponent
  final blockingMove = _findWinningMove(board, aiPlayer.opponent);
  if (blockingMove != null) return blockingMove;

  // 3. Random move
  return _getRandomMove(board);
}

// Hard: Minimax algorithm with alpha-beta pruning
Position _getMinimaxMove(List<List<Player>> board, Player aiPlayer) {
  int bestScore = -1000;
  Position? bestMove;

  for (final move in _gameService.getAvailableMoves(board)) {
    final newBoard = _copyBoard(board);
    newBoard[move.row][move.col] = aiPlayer;

    final score = _minimax(newBoard, 0, false, aiPlayer, -1000, 1000);

    if (score > bestScore) {
      bestScore = score;
      bestMove = move;
    }
  }

  return bestMove ?? _getRandomMove(board);
}

// Minimax with alpha-beta pruning
int _minimax(
  List<List<Player>> board,
  int depth,
  bool isMaximizing,
  Player aiPlayer,
  int alpha,
  int beta,
) {
  // Terminal state checks
  final winner = _gameService.checkWinner(board);
  if (winner != null) {
    return winner.winner == aiPlayer ? 10 - depth : depth - 10;
  }
  if (_gameService.isBoardFull(board)) return 0;

  // Recursive minimax...
}
```

---

## 5.4 Repository Pattern

### 5.4.1 Repository Philosophy

Repositories provide a clean abstraction over data storage, using model serialization methods directly.

**Key Principles:**
- Use model's `toJson()` / `fromJson()` directly
- **NO DTOs** (Data Transfer Objects) - models serve both roles
- Handle storage errors gracefully
- Provide async API for all operations

### 5.4.2 GameStateRepository

**Purpose**: Persists game state for save/resume functionality

```dart
class GameStateRepository {
  static const String _savedGameKey = 'saved_game';

  /// Saves current game state
  Future<void> saveGame(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.toJson());  // Uses model's toJson
    await prefs.setString(_savedGameKey, jsonString);
  }

  /// Loads saved game state
  /// Returns null if no saved game exists or deserialization fails
  Future<GameState?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_savedGameKey);

    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return GameState.fromJson(json);  // Uses model's fromJson
    } catch (e) {
      // Clean up corrupted data
      await deleteSavedGame();
      return null;
    }
  }

  /// Checks if saved game exists
  Future<bool> hasSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_savedGameKey);
  }

  /// Deletes saved game
  Future<void> deleteSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedGameKey);
  }
}
```

### 5.4.3 ScoreRepository

**Purpose**: Persists player statistics

```dart
class ScoreRepository {
  /// Loads score from storage
  Future<Score> loadScore() async {
    final prefs = await SharedPreferences.getInstance();
    final wins = prefs.getInt('wins') ?? 0;
    final losses = prefs.getInt('losses') ?? 0;
    final draws = prefs.getInt('draws') ?? 0;

    return Score(wins: wins, losses: losses, draws: draws);
  }

  /// Saves score to storage
  Future<void> saveScore(Score score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('wins', score.wins);
    await prefs.setInt('losses', score.losses);
    await prefs.setInt('draws', score.draws);
  }

  /// Resets score to zero
  Future<void> resetScore() async {
    await saveScore(const Score());
  }

  /// Increments win count
  Future<Score> incrementWins(Score currentScore) async {
    final newScore = currentScore.copyWith(wins: currentScore.wins + 1);
    await saveScore(newScore);
    return newScore;
  }

  /// Similar for incrementLosses() and incrementDraws()
}
```

### 5.4.4 Repository Interface Pattern

For larger applications, define interfaces:

```dart
// Interface
abstract class IGameStateRepository {
  Future<void> saveGame(GameState state);
  Future<GameState?> loadGame();
  Future<bool> hasSavedGame();
  Future<void> deleteSavedGame();
}

// Implementation
class GameStateRepository implements IGameStateRepository {
  // Implementation using SharedPreferences
}

// Future: Could add alternative implementations
class GameStateApiRepository implements IGameStateRepository {
  // Implementation using REST API
}
```

---

## 5.5 State Management Architecture

### 5.5.1 Bloc/Cubit Philosophy

**Critical Rule**: Blocs coordinate services and manage UI state. They contain **ZERO business logic**.

**Bloc Responsibilities:**
- Listen to user events
- Call appropriate services
- Transform service results into UI states
- Handle async operations
- Manage UI-specific state (loading, error, etc.)

**Bloc Forbidden Actions:**
- Implement game rules
- Calculate AI moves
- Validate game logic
- Perform complex calculations
- Direct storage access (use repositories via services)

### 5.5.2 GameBloc Architecture

**Purpose**: Coordinates game flow between UI and services

```dart
class GameBloc extends Bloc<GameEvent, GameBlocState> {
  final GameService _gameService;
  final AiService _aiService;

  GameBloc({
    required GameService gameService,
    required AiService aiService,
  }) : _gameService = gameService,
       _aiService = aiService,
       super(const GameInitial()) {
    on<StartNewGame>(_onStartNewGame);
    on<MakeMove>(_onMakeMove);
    on<MakeAiMove>(_onMakeAiMove);
    on<UndoMove>(_onUndoMove);
    on<ResetGame>(_onResetGame);
  }
}
```

**Events:**
```dart
abstract class GameEvent extends Equatable {
  const GameEvent();
}

class StartNewGame extends GameEvent {
  final GameConfig config;
  const StartNewGame(this.config);
}

class MakeMove extends GameEvent {
  final Position position;
  const MakeMove(this.position);
}

class MakeAiMove extends GameEvent {
  const MakeAiMove();
}

class UndoMove extends GameEvent {
  const UndoMove();
}

class ResetGame extends GameEvent {
  const ResetGame();
}
```

**States:**
```dart
abstract class GameBlocState extends Equatable {
  const GameBlocState();
}

class GameInitial extends GameBlocState {
  const GameInitial();
}

class GameInProgress extends GameBlocState {
  final GameState gameState;  // Domain model
  const GameInProgress(this.gameState);
}

class AiThinking extends GameBlocState {
  final GameState gameState;  // Show loading indicator
  const AiThinking(this.gameState);
}

class GameFinished extends GameBlocState {
  final GameState gameState;  // Show game over screen
  const GameFinished(this.gameState);
}
```

**Event Handler Example:**
```dart
void _onMakeMove(MakeMove event, Emitter<GameBlocState> emit) {
  if (state is! GameInProgress) return;

  final currentState = (state as GameInProgress).gameState;

  // ✅ CORRECT: Delegate validation to service
  if (!_gameService.isValidMove(currentState, event.position)) {
    return;  // Invalid move, ignore
  }

  // ✅ CORRECT: Delegate game logic to service
  final newGameState = _gameService.makeMove(currentState, event.position);

  // ✅ CORRECT: Bloc handles UI state transitions
  if (newGameState.result != GameResult.ongoing) {
    emit(GameFinished(newGameState));
    return;
  }

  emit(GameInProgress(newGameState));

  // ✅ CORRECT: Trigger AI move in single player mode
  if (newGameState.config.gameMode == GameMode.singlePlayer) {
    add(const MakeAiMove());
  }
}

// ❌ INCORRECT Example:
void _onMakeMoveWrong(MakeMove event, Emitter<GameBlocState> emit) {
  // ❌ BAD: Implementing validation in bloc
  if (event.position.row < 0 || event.position.row > 2) {
    return;
  }

  // ❌ BAD: Implementing game logic in bloc
  final board = currentState.board;
  board[event.position.row][event.position.col] = currentState.currentPlayer;

  // ❌ BAD: Checking win condition in bloc
  if (board[0][0] == board[1][1] && board[1][1] == board[2][2]) {
    emit(GameFinished(...));
  }
}
```

**AI Move Handler:**
```dart
Future<void> _onMakeAiMove(MakeAiMove event, Emitter<GameBlocState> emit) async {
  if (state is! GameInProgress) return;

  final currentState = (state as GameInProgress).gameState;

  // Show thinking state for UX
  emit(AiThinking(currentState));

  // Add delay for better UX
  await Future.delayed(const Duration(milliseconds: 500));

  // ✅ CORRECT: Delegate AI logic to AIService
  final aiPlayer = Player.o;
  final difficulty = currentState.config.difficultyLevel!;
  final aiMove = _aiService.getBestMove(
    currentState.board,
    aiPlayer,
    difficulty,
  );

  // ✅ CORRECT: Use GameService to make the move
  final newGameState = _gameService.makeMove(currentState, aiMove);

  // Handle state transition
  if (newGameState.result != GameResult.ongoing) {
    emit(GameFinished(newGameState));
  } else {
    emit(GameInProgress(newGameState));
  }
}
```

### 5.5.3 ScoreBloc Architecture

**Purpose**: Manages score persistence and updates

```dart
class ScoreBloc extends Bloc<ScoreEvent, ScoreState> {
  final ScoreRepository _scoreRepository;

  ScoreBloc({required ScoreRepository scoreRepository})
      : _scoreRepository = scoreRepository,
        super(const ScoreInitial()) {
    on<LoadScore>(_onLoadScore);
    on<UpdateScore>(_onUpdateScore);
    on<ResetScore>(_onResetScore);
  }

  Future<void> _onLoadScore(LoadScore event, Emitter<ScoreState> emit) async {
    emit(const ScoreLoading());
    try {
      final score = await _scoreRepository.loadScore();
      emit(ScoreLoaded(score));
    } catch (e) {
      emit(ScoreError(e.toString()));
    }
  }

  Future<void> _onUpdateScore(UpdateScore event, Emitter<ScoreState> emit) async {
    if (state is! ScoreLoaded) return;

    final currentScore = (state as ScoreLoaded).score;

    try {
      final newScore = switch (event.result) {
        GameResult.win => await _scoreRepository.incrementWins(currentScore),
        GameResult.loss => await _scoreRepository.incrementLosses(currentScore),
        GameResult.draw => await _scoreRepository.incrementDraws(currentScore),
        _ => currentScore,
      };

      emit(ScoreLoaded(newScore));
    } catch (e) {
      emit(ScoreError(e.toString()));
    }
  }
}
```

---

## 5.6 Dependency Injection

### 5.6.1 DI Philosophy

Use `get_it` with `injectable` for compile-safe dependency injection.

**Benefits:**
- Centralized dependency management
- Easy testing with mock injection
- Lazy initialization for performance
- Clear dependency graph

### 5.6.2 Setup Pattern

**1. Add dependencies to `pubspec.yaml`:**
```yaml
dependencies:
  get_it: ^7.6.0
  injectable: ^2.3.2

dev_dependencies:
  injectable_generator: ^2.4.0
  build_runner: ^2.4.6
```

**2. Create injection configuration:**

```dart
// lib/core/di/injection.dart

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  await getIt.init();
}
```

**3. Annotate services:**

```dart
// Services are singletons (one instance)
@LazySingleton()
class GameService {
  GameState createNewGame(GameConfig config) { /* ... */ }
}

@LazySingleton()
class AiService {
  final GameService _gameService;

  AiService(this._gameService);  // Auto-injected
}

// Repositories are singletons
@LazySingleton()
class GameStateRepository {
  Future<void> saveGame(GameState state) async { /* ... */ }
}

@LazySingleton()
class ScoreRepository {
  Future<Score> loadScore() async { /* ... */ }
}

// Blocs are created per use (injectable, not singleton)
@injectable
class GameBloc extends Bloc<GameEvent, GameBlocState> {
  final GameService _gameService;
  final AiService _aiService;

  GameBloc(
    this._gameService,
    this._aiService,
  ) : super(const GameInitial());
}

@injectable
class ScoreBloc extends Bloc<ScoreEvent, ScoreState> {
  final ScoreRepository _scoreRepository;

  ScoreBloc(this._scoreRepository) : super(const ScoreInitial());
}
```

**4. Initialize in main:**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await configureDependencies();

  runApp(const MyApp());
}
```

**5. Generate injection code:**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5.6.3 Using Dependencies in UI

```dart
// Provide blocs to widget tree
class GamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<GameBloc>()..add(StartNewGame(config)),
      child: GameView(),
    );
  }
}

// Access blocs in widgets
class GameView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameBlocState>(
      builder: (context, state) {
        if (state is GameInProgress) {
          return GameBoard(gameState: state.gameState);
        }
        // ...
      },
    );
  }
}
```

---

## 5.7 Presentation Layer Helpers

### 5.7.1 Extension Philosophy

**Keep enums pure, put display logic in extensions.**

Enums should only contain domain logic. All presentation concerns (labels, icons, colors) belong in presentation layer extensions.

### 5.7.2 Player Extensions

```dart
// lib/presentation/extensions/player_extensions.dart

import '../../domain/models/player.dart';

/// Presentation layer helper for Player display
class PlayerDisplay {
  static String symbol(Player player) {
    switch (player) {
      case Player.x: return 'X';
      case Player.o: return 'O';
      case Player.none: return '';
    }
  }
}

/// Extension for convenient access
extension PlayerExtensions on Player {
  String get symbol => PlayerDisplay.symbol(this);

  // Could add more presentation helpers:
  // Color get color => ...
  // IconData get icon => ...
}
```

**Usage:**
```dart
// In widgets
Text(currentPlayer.symbol)  // Shows "X" or "O"
```

### 5.7.3 GameResult Extensions

```dart
// lib/presentation/extensions/game_result_extensions.dart

import '../../domain/models/game_result.dart';
import '../../domain/models/player.dart';

extension GameResultExtensions on GameResult {
  /// Gets user-friendly message for game result
  String getMessage(Player playerSymbol) {
    switch (this) {
      case GameResult.win:
        return 'Player ${playerSymbol.symbol} Wins!';
      case GameResult.loss:
        return 'Player ${playerSymbol.opponent.symbol} Wins!';
      case GameResult.draw:
        return 'It\'s a Draw!';
      case GameResult.ongoing:
        return 'Game in Progress';
    }
  }

  /// Gets color for result
  Color getColor() {
    switch (this) {
      case GameResult.win: return Colors.green;
      case GameResult.loss: return Colors.red;
      case GameResult.draw: return Colors.orange;
      case GameResult.ongoing: return Colors.blue;
    }
  }
}
```

### 5.7.4 Difficulty Extensions

```dart
// lib/presentation/extensions/difficulty_extensions.dart

import '../../domain/models/difficulty_level.dart';

extension DifficultyExtensions on DifficultyLevel {
  String get displayName {
    switch (this) {
      case DifficultyLevel.easy: return 'Easy';
      case DifficultyLevel.medium: return 'Medium';
      case DifficultyLevel.hard: return 'Hard';
    }
  }

  String get description {
    switch (this) {
      case DifficultyLevel.easy: return 'Random moves';
      case DifficultyLevel.medium: return 'Blocks your wins';
      case DifficultyLevel.hard: return 'Unbeatable AI';
    }
  }

  IconData get icon {
    switch (this) {
      case DifficultyLevel.easy: return Icons.sentiment_satisfied;
      case DifficultyLevel.medium: return Icons.sentiment_neutral;
      case DifficultyLevel.hard: return Icons.sentiment_very_dissatisfied;
    }
  }
}
```

---

## 5.8 Testing Architecture

### 5.8.1 Test Structure

Mirror the `lib/` structure in `test/`:

```
test/
├── domain/
│   ├── models/
│   │   ├── game_state_test.dart
│   │   ├── game_config_test.dart
│   │   ├── score_test.dart
│   │   └── position_test.dart
│   └── services/
│       ├── game_service_test.dart
│       └── ai_service_test.dart
│
├── data/
│   └── repositories/
│       ├── game_state_repository_test.dart
│       ├── game_state_repository_integration_test.dart
│       └── score_repository_test.dart
│
├── presentation/
│   ├── blocs/
│   │   ├── game_bloc_test.dart
│   │   └── score_bloc_test.dart
│   ├── pages/
│   │   ├── home_page_test.dart
│   │   ├── game_page_test.dart
│   │   └── settings_page_test.dart
│   └── widgets/
│       ├── game_board_test.dart
│       └── board_cell_test.dart
│
└── helpers/
    ├── mocks.dart          # Mock classes
    └── builders.dart       # Test data builders
```

### 5.8.2 Coverage Targets

**Minimum coverage requirements:**

| Layer | Target | Rationale |
|-------|--------|-----------|
| Domain Models | 100% | Simple serialization, easy to test |
| Domain Services | 90%+ | Contains all business logic |
| Repositories | 80%+ | Storage operations |
| Blocs | 80%+ | UI state coordination |
| Widgets | 70%+ | UI rendering |
| Extensions | 80%+ | Display logic helpers |

### 5.8.3 Testing Strategy by Layer

#### Domain Models Tests
**Focus**: Serialization, equality, copyWith

```dart
// test/domain/models/game_state_test.dart

void main() {
  group('GameState', () {
    test('should serialize to JSON correctly', () {
      final state = GameState(
        board: [...],
        currentPlayer: Player.x,
        config: config,
        startTime: DateTime.now(),
      );

      final json = state.toJson();
      expect(json['currentPlayer'], 'x');
      expect(json['board'], isNotEmpty);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'board': [[...], [...], [...]],
        'currentPlayer': 'x',
        // ...
      };

      final state = GameState.fromJson(json);
      expect(state.currentPlayer, Player.x);
    });

    test('should create copy with modified values', () {
      final state1 = GameState(...);
      final state2 = state1.copyWith(currentPlayer: Player.o);

      expect(state2.currentPlayer, Player.o);
      expect(state2.board, state1.board); // Unchanged
    });

    test('should support equality comparison', () {
      final state1 = GameState(...);
      final state2 = GameState(...);  // Same values

      expect(state1, equals(state2));
    });
  });
}
```

#### Domain Service Tests
**Focus**: Business logic, edge cases

```dart
// test/domain/services/game_service_test.dart

void main() {
  late GameService gameService;

  setUp(() {
    gameService = GameService();
  });

  group('GameService - makeMove', () {
    test('should update board when move is valid', () {
      final state = gameService.createNewGame(config);
      final newState = gameService.makeMove(state, Position(row: 0, col: 0));

      expect(newState.board[0][0], Player.x);
    });

    test('should detect horizontal win', () {
      // Arrange: Set up board with two X's in a row
      final state = GameState(
        board: [
          [Player.x, Player.x, Player.none],
          [Player.o, Player.o, Player.none],
          [Player.none, Player.none, Player.none],
        ],
        currentPlayer: Player.x,
        config: config,
        startTime: DateTime.now(),
      );

      // Act: Make winning move
      final newState = gameService.makeMove(state, Position(row: 0, col: 2));

      // Assert
      expect(newState.result, GameResult.win);
      expect(newState.winner, Player.x);
      expect(newState.winningLine, [
        Position(row: 0, col: 0),
        Position(row: 0, col: 1),
        Position(row: 0, col: 2),
      ]);
    });

    test('should detect draw when board is full', () {
      final state = GameState(
        board: [
          [Player.x, Player.o, Player.x],
          [Player.x, Player.o, Player.o],
          [Player.o, Player.x, Player.none],
        ],
        currentPlayer: Player.x,
        config: config,
        startTime: DateTime.now(),
      );

      final newState = gameService.makeMove(state, Position(row: 2, col: 2));

      expect(newState.result, GameResult.draw);
      expect(newState.winner, null);
    });

    test('should return same state for invalid move', () {
      final state = gameService.createNewGame(config);

      // Occupy a cell
      final state2 = gameService.makeMove(state, Position(row: 0, col: 0));

      // Try to move on same cell
      final state3 = gameService.makeMove(state2, Position(row: 0, col: 0));

      expect(state3, state2); // State unchanged
    });
  });

  group('GameService - undoLastMove', () {
    test('should revert to previous state', () {
      final state1 = gameService.createNewGame(config);
      final state2 = gameService.makeMove(state1, Position(row: 0, col: 0));
      final state3 = gameService.makeMove(state2, Position(row: 1, col: 1));

      final undone = gameService.undoLastMove(state3);

      expect(undone?.board[1][1], Player.none);
      expect(undone?.board[0][0], Player.x);
    });
  });
}
```

#### AI Service Tests
**Focus**: Move calculation logic

```dart
// test/domain/services/ai_service_test.dart

void main() {
  late GameService gameService;
  late AiService aiService;

  setUp(() {
    gameService = GameService();
    aiService = AiService(gameService);
  });

  group('AiService - Easy Difficulty', () {
    test('should return valid move', () {
      final board = [
        [Player.x, Player.none, Player.none],
        [Player.none, Player.none, Player.none],
        [Player.none, Player.none, Player.none],
      ];

      final move = aiService.getBestMove(board, Player.o, DifficultyLevel.easy);

      expect(move.row, inInclusiveRange(0, 2));
      expect(move.col, inInclusiveRange(0, 2));
      expect(board[move.row][move.col], Player.none);
    });
  });

  group('AiService - Medium Difficulty', () {
    test('should take winning move when available', () {
      final board = [
        [Player.o, Player.o, Player.none],  // AI can win here
        [Player.x, Player.x, Player.none],
        [Player.none, Player.none, Player.none],
      ];

      final move = aiService.getBestMove(board, Player.o, DifficultyLevel.medium);

      expect(move, Position(row: 0, col: 2)); // Winning move
    });

    test('should block opponent winning move', () {
      final board = [
        [Player.x, Player.x, Player.none],  // Must block here
        [Player.o, Player.none, Player.none],
        [Player.none, Player.none, Player.none],
      ];

      final move = aiService.getBestMove(board, Player.o, DifficultyLevel.medium);

      expect(move, Position(row: 0, col: 2)); // Blocking move
    });
  });

  group('AiService - Hard Difficulty', () {
    test('should never lose when playing optimally', () {
      // Simulate multiple games
      for (int i = 0; i < 10; i++) {
        var state = gameService.createNewGame(configHard);

        while (state.result == GameResult.ongoing) {
          if (state.currentPlayer == Player.o) {
            final aiMove = aiService.getBestMove(
              state.board,
              Player.o,
              DifficultyLevel.hard
            );
            state = gameService.makeMove(state, aiMove);
          } else {
            // Human makes random move
            final moves = gameService.getAvailableMoves(state.board);
            state = gameService.makeMove(state, moves.first);
          }
        }

        // AI should never lose
        expect(state.result, isNot(GameResult.loss));
      }
    });
  });
}
```

#### Repository Tests
**Focus**: Persistence operations

```dart
// test/data/repositories/game_state_repository_test.dart

void main() {
  late GameStateRepository repository;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = GameStateRepository();
  });

  group('GameStateRepository', () {
    test('should save and load game state', () async {
      final state = GameState(...);

      await repository.saveGame(state);
      final loaded = await repository.loadGame();

      expect(loaded, equals(state));
    });

    test('should return null when no saved game exists', () async {
      final loaded = await repository.loadGame();
      expect(loaded, null);
    });

    test('should return null and clean up corrupted data', () async {
      await prefs.setString('saved_game', 'invalid json');

      final loaded = await repository.loadGame();

      expect(loaded, null);
      expect(await repository.hasSavedGame(), false);
    });
  });
}
```

#### Bloc Tests
**Focus**: State transitions, service coordination

**Use mocks for services:**

```dart
// test/helpers/mocks.dart

@GenerateMocks([GameService, AiService, ScoreRepository])
void main() {}

// Generate mocks with: flutter pub run build_runner build
```

```dart
// test/presentation/blocs/game_bloc_test.dart

void main() {
  late GameBloc gameBloc;
  late MockGameService mockGameService;
  late MockAiService mockAiService;

  setUp(() {
    mockGameService = MockGameService();
    mockAiService = MockAiService();
    gameBloc = GameBloc(
      gameService: mockGameService,
      aiService: mockAiService,
    );
  });

  tearDown(() {
    gameBloc.close();
  });

  group('GameBloc - StartNewGame', () {
    test('should emit GameInProgress when game starts', () {
      final config = GameConfig(
        gameMode: GameMode.twoPlayer,
        firstPlayer: Player.x,
      );
      final expectedState = GameState(...);

      when(mockGameService.createNewGame(config))
          .thenReturn(expectedState);

      expectLater(
        gameBloc.stream,
        emitsInOrder([
          isA<GameInProgress>()
              .having((s) => s.gameState, 'gameState', expectedState),
        ]),
      );

      gameBloc.add(StartNewGame(config));
    });

    test('should trigger AI move when AI goes first', () {
      final config = GameConfig(
        gameMode: GameMode.singlePlayer,
        firstPlayer: Player.o,  // AI goes first
        difficultyLevel: DifficultyLevel.easy,
      );
      final gameState = GameState(...);

      when(mockGameService.createNewGame(config))
          .thenReturn(gameState);
      when(mockAiService.getBestMove(any, any, any))
          .thenReturn(Position(row: 0, col: 0));
      when(mockGameService.makeMove(any, any))
          .thenReturn(gameState);

      gameBloc.add(StartNewGame(config));

      // Verify AI move was triggered
      verify(mockAiService.getBestMove(any, any, any)).called(1);
    });
  });

  group('GameBloc - MakeMove', () {
    test('should emit GameInProgress after valid move', () {
      final currentState = GameState(...);
      final newState = currentState.copyWith(
        currentPlayer: Player.o,
      );
      final position = Position(row: 0, col: 0);

      gameBloc.emit(GameInProgress(currentState));

      when(mockGameService.isValidMove(currentState, position))
          .thenReturn(true);
      when(mockGameService.makeMove(currentState, position))
          .thenReturn(newState);

      expectLater(
        gameBloc.stream,
        emitsInOrder([
          isA<GameInProgress>()
              .having((s) => s.gameState, 'gameState', newState),
        ]),
      );

      gameBloc.add(MakeMove(position));
    });

    test('should emit GameFinished when game ends', () {
      final currentState = GameState(...);
      final finishedState = currentState.copyWith(
        result: GameResult.win,
        winner: Player.x,
      );
      final position = Position(row: 0, col: 0);

      gameBloc.emit(GameInProgress(currentState));

      when(mockGameService.isValidMove(currentState, position))
          .thenReturn(true);
      when(mockGameService.makeMove(currentState, position))
          .thenReturn(finishedState);

      expectLater(
        gameBloc.stream,
        emitsInOrder([
          isA<GameFinished>()
              .having((s) => s.gameState.result, 'result', GameResult.win),
        ]),
      );

      gameBloc.add(MakeMove(position));
    });

    test('should ignore invalid moves', () {
      final currentState = GameState(...);
      final position = Position(row: 0, col: 0);

      gameBloc.emit(GameInProgress(currentState));

      when(mockGameService.isValidMove(currentState, position))
          .thenReturn(false);

      expectLater(
        gameBloc.stream,
        emitsInOrder([]),  // No state change
      );

      gameBloc.add(MakeMove(position));

      verifyNever(mockGameService.makeMove(any, any));
    });
  });
}
```

#### Widget Tests
**Focus**: UI rendering, user interaction

```dart
// test/presentation/widgets/game_board_test.dart

void main() {
  testWidgets('should render 3x3 grid', (tester) async {
    final gameState = GameState(
      board: [
        [Player.x, Player.o, Player.none],
        [Player.none, Player.x, Player.none],
        [Player.none, Player.none, Player.o],
      ],
      currentPlayer: Player.x,
      config: config,
      startTime: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameBoard(
            gameState: gameState,
            onCellTap: (position) {},
          ),
        ),
      ),
    );

    // Should render 9 cells
    expect(find.byType(BoardCell), findsNWidgets(9));

    // Check specific cells display correctly
    expect(find.text('X'), findsNWidgets(2));
    expect(find.text('O'), findsNWidgets(2));
  });

  testWidgets('should call onCellTap when cell tapped', (tester) async {
    Position? tappedPosition;

    final gameState = GameState(...);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameBoard(
            gameState: gameState,
            onCellTap: (position) {
              tappedPosition = position;
            },
          ),
        ),
      ),
    );

    // Tap center cell
    await tester.tap(find.byType(BoardCell).at(4));
    await tester.pump();

    expect(tappedPosition, Position(row: 1, col: 1));
  });
}
```

### 5.8.4 Test Helpers

**Mock builders for consistent test data:**

```dart
// test/helpers/builders.dart

class GameStateBuilder {
  List<List<Player>> _board = List.generate(
    3,
    (_) => List.generate(3, (_) => Player.none)
  );
  Player _currentPlayer = Player.x;
  GameResult _result = GameResult.ongoing;
  GameConfig? _config;

  GameStateBuilder withBoard(List<List<Player>> board) {
    _board = board;
    return this;
  }

  GameStateBuilder withCurrentPlayer(Player player) {
    _currentPlayer = player;
    return this;
  }

  GameStateBuilder withResult(GameResult result) {
    _result = result;
    return this;
  }

  GameStateBuilder withConfig(GameConfig config) {
    _config = config;
    return this;
  }

  GameState build() {
    return GameState(
      board: _board,
      currentPlayer: _currentPlayer,
      result: _result,
      config: _config ?? GameConfigBuilder().build(),
      startTime: DateTime.now(),
    );
  }
}

// Usage in tests:
final state = GameStateBuilder()
    .withCurrentPlayer(Player.x)
    .withResult(GameResult.win)
    .build();
```

---

## 5.9 Architecture Decision Records (ADRs)

### ADR-001: Why Clean Architecture?

**Decision**: Use Clean Architecture with domain/data/presentation layers

**Rationale:**
- Clear separation of concerns makes code easier to understand
- Business logic is isolated and testable without UI dependencies
- Flexibility to change UI framework or storage mechanism
- Industry standard pattern for Flutter apps
- Scales well as application grows

**Alternatives Considered:**
- Monolithic structure: Rejected due to poor testability
- MVVM: Too much logic can leak into ViewModels

### ADR-002: Why No DTOs?

**Decision**: Use domain models directly in repositories (no separate DTOs)

**Rationale:**
- Simpler codebase with less mapping boilerplate
- Models already have JSON serialization
- For small/medium apps, DTOs add complexity without benefit
- Domain models ARE our data contracts

**When to Reconsider:**
- If external API has vastly different structure than domain
- If domain models become very large
- If multiple external sources with conflicting formats

### ADR-003: Why Bloc over Cubit/Provider?

**Decision**: Use Bloc pattern for state management

**Rationale:**
- Explicit event-driven architecture
- Built-in state transition logging
- Strong separation between events and state
- Better for complex state flows
- Industry standard

**Alternatives:**
- Cubit: Simpler, but events provide better traceability
- Provider: Good for simple apps, harder to scale
- Riverpod: Great choice, but Bloc has more established patterns

### ADR-004: Why Put opponent in Player Enum?

**Decision**: `Player` enum includes `opponent` getter

**Rationale:**
- `opponent` is a core domain concept (business rule)
- Not a presentation concern
- Needed by GameService for game logic
- Simple, pure function with no side effects

**Not Allowed in Enums:**
- Display text (e.g., "Player X")
- Colors, icons
- Localization keys

---

## 5.10 Architecture Checklist

Before implementing any feature, verify:

### Models
- [ ] Model is immutable (all fields `final`)
- [ ] Model extends `Equatable` with correct props
- [ ] Model has `copyWith()` method
- [ ] Model has `toJson()` and `fromJson()`
- [ ] Model contains ZERO business logic
- [ ] Only simple calculated getters (if any)

### Services
- [ ] Service is stateless
- [ ] ALL business logic is in service (not model or bloc)
- [ ] Service methods are pure functions
- [ ] Service has no Flutter dependencies
- [ ] Service is covered by unit tests (90%+)

### Repositories
- [ ] Repository uses model `toJson()`/`fromJson()` directly
- [ ] Repository handles errors gracefully
- [ ] Repository returns domain models (not DTOs)
- [ ] Repository has integration tests

### Blocs
- [ ] Bloc contains ZERO business logic
- [ ] Bloc only coordinates services
- [ ] Bloc handles UI state (loading, error, success)
- [ ] Bloc is annotated with `@injectable`
- [ ] Events and states are well-defined
- [ ] Bloc tests use mocked services

### Extensions
- [ ] Display logic is in presentation extensions (not enums)
- [ ] Extensions are in `presentation/extensions/`
- [ ] Extensions have no business logic

### Tests
- [ ] Tests mirror `lib/` structure
- [ ] Coverage meets targets
- [ ] Tests use builders for test data
- [ ] Mocks are used for dependencies

---

## 5.11 Common Anti-Patterns to Avoid

### ❌ Business Logic in Models

```dart
// BAD
class GameState {
  bool checkWin() {
    // Checking win conditions in model
    for (int i = 0; i < 3; i++) {
      if (board[i][0] == board[i][1] && board[i][1] == board[i][2]) {
        return true;
      }
    }
  }
}

// GOOD
class GameService {
  WinResult? checkWinner(List<List<Player>> board) {
    // Win logic in service
  }
}
```

### ❌ Business Logic in Blocs

```dart
// BAD
void _onMakeMove(MakeMove event, Emitter emit) {
  // Implementing validation in bloc
  if (board[event.row][event.col] != Player.none) {
    return;
  }

  // Implementing game logic in bloc
  board[event.row][event.col] = currentPlayer;
}

// GOOD
void _onMakeMove(MakeMove event, Emitter emit) {
  // Delegate to service
  if (!_gameService.isValidMove(state, event.position)) {
    return;
  }
  final newState = _gameService.makeMove(state, event.position);
  emit(GameInProgress(newState));
}
```

### ❌ Display Logic in Domain

```dart
// BAD
enum DifficultyLevel {
  easy, medium, hard;

  String get displayName {  // Presentation concern in domain!
    switch (this) {
      case easy: return 'Easy';
      case medium: return 'Medium';
      case hard: return 'Hard';
    }
  }
}

// GOOD
// Domain enum stays pure
enum DifficultyLevel { easy, medium, hard; }

// Extension in presentation layer
extension DifficultyExtensions on DifficultyLevel {
  String get displayName { /* ... */ }
}
```

### ❌ Direct Repository Access from UI

```dart
// BAD
class GamePage extends StatelessWidget {
  final ScoreRepository _scoreRepository = getIt<ScoreRepository>();

  Future<void> _saveScore() {
    await _scoreRepository.saveScore(score);  // Direct access!
  }
}

// GOOD
class GamePage extends StatelessWidget {
  void _saveScore() {
    context.read<ScoreBloc>().add(UpdateScore(result));  // Via bloc
  }
}
```

---

## Summary

This architecture ensures:

1. **Clear Boundaries**: Each layer has one responsibility
2. **Testability**: Services and models are pure, easy to test
3. **Maintainability**: Changes are localized to specific layers
4. **Scalability**: Structure supports growth without refactoring
5. **Team Alignment**: Developers know exactly where code belongs

**Golden Rules:**
- Models = Data only
- Services = ALL business logic
- Blocs = UI state coordination only
- Extensions = Display logic only
- Tests = Mirror structure, meet coverage targets

Follow these specifications, and the codebase will remain clean, testable, and maintainable as it grows.
