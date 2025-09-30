# Flutter Development Configuration for Claude Code - Bloc with Service Layer

## Architecture Philosophy

**Core Principle**: Separation of business logic from UI state management within the Flutter app.

- **Models**: THIN data structures with only properties and basic helpers (NO business logic)
- **Services**: Handle ALL business logic, calculations, and complex rules
- **Blocs/Cubits**: ONLY handle UI state, user interactions, and coordinate service calls
- **Result**: Clean, testable, maintainable code with clear responsibilities

## Project Setup Instructions

### Initial Context

When starting a new Flutter project, provide Claude with:

- App name and description
- Target platforms (iOS, Android, Web, Desktop)
- **Architecture: Service Layer + Bloc for UI state only**
- Design system (Material 3, Cupertino, custom)
- Key features and functionality

### CRITICAL ARCHITECTURAL RULES

- **Services contain ALL business logic** within the Flutter app
- **Blocs ONLY handle UI state and user interactions**
- **Models are THIN data structures** - only properties and basic helpers
- **NEVER put business logic in Blocs OR Models**
- **NEVER use StatefulWidget** - All widgets must be StatelessWidget
- **NEVER use Provider, Riverpod, GetX, or setState**
- **Services handle complex logic** that would clutter Blocs or Models

### Project Structure

```
lib/
├── main.dart
├── app.dart
├── injection.dart
├── core/
│   ├── constants/
│   ├── errors/
│   └── utils/
├── data/
│   ├── models/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/          # Repository interfaces
│   └── services/              # Business logic services
│       ├── game_service.dart
│       ├── calculation_service.dart
│       ├── validation_service.dart
│       ├── auth_service.dart
│       ├── ai_service.dart
│       └── pricing_service.dart
├── presentation/
│   ├── blocs/                 # UI state management only
│   │   └── [feature]/
│   │       ├── [feature]_bloc.dart
│   │       ├── [feature]_event.dart
│   │       └── [feature]_state.dart
│   ├── cubits/
│   ├── pages/
│   └── widgets/
└── routes/
    └── app_router.dart
```

## Model Templates

### 1. Thin Entity Model (Domain Layer)

```dart
// domain/entities/game_state.dart
import 'package:equatable/equatable.dart';

class GameState extends Equatable {
  final Board board;
  final Player currentPlayer;
  final List<Move> moveHistory;
  final Duration elapsedTime;
  final GamePhase phase;

  const GameState({
    required this.board,
    required this.currentPlayer,
    required this.moveHistory,
    required this.elapsedTime,
    required this.phase,
  });

  // ONLY basic helper methods - NO business logic
  GameState copyWith({
    Board? board,
    Player? currentPlayer,
    List<Move>? moveHistory,
    Duration? elapsedTime,
    GamePhase? phase,
  }) {
    return GameState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      moveHistory: moveHistory ?? this.moveHistory,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      phase: phase ?? this.phase,
    );
  }

  // Simple property accessors - OK
  int get moveCount => moveHistory.length;
  bool get isEmpty => moveHistory.isEmpty;
  Move? get lastMove => moveHistory.isEmpty ? null : moveHistory.last;

  // ❌ NO business logic like this:
  // bool isValidMove(Move move) { ... }  // This belongs in GameService
  // Player getWinner() { ... }  // This belongs in GameService
  // Score calculateScore() { ... }  // This belongs in GameService

  @override
  List<Object?> get props => [board, currentPlayer, moveHistory, elapsedTime, phase];
}
```

### 2. Data Transfer Model (Data Layer)

**Purpose**: Data models live in `data/models/` and handle serialization/deserialization for persistence and API communication. They act as a bridge between external data sources and domain entities.

**Key Responsibilities**:
- JSON serialization (`toJson()`) and deserialization (`fromJson()`)
- Conversion to/from domain entities (`toEntity()`, `fromEntity()`)
- Data validation during deserialization
- Handling API response formats
- Managing persistence formats

**Architecture Flow**:
```
External Source (API/DB) → Model (data/models) → Entity (domain/entities)
                        ←                       ←
```

#### Example: Score Model (Simple Case)

```dart
// data/models/score_model.dart
import '../../domain/entities/score.dart';

/// Data Transfer Object for Score persistence
class ScoreModel {
  final int wins;
  final int losses;
  final int draws;

  const ScoreModel({
    required this.wins,
    required this.losses,
    required this.draws,
  });

  /// Deserialize from JSON
  factory ScoreModel.fromJson(Map<String, dynamic> json) {
    return ScoreModel(
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      draws: json['draws'] as int? ?? 0,
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'wins': wins,
      'losses': losses,
      'draws': draws,
    };
  }

  /// Convert from domain entity
  factory ScoreModel.fromEntity(Score score) {
    return ScoreModel(
      wins: score.wins,
      losses: score.losses,
      draws: score.draws,
    );
  }

  /// Convert to domain entity
  Score toEntity() {
    return Score(
      wins: wins,
      losses: losses,
      draws: draws,
    );
  }
}
```

#### Example: GameState Model (Complex with Nested Objects)

GameState is a perfect example of when you NEED a data model for serialization, even if the entity is complex:

```dart
// data/models/game_state_model.dart
import '../../domain/entities/game_state.dart';
import '../../domain/entities/game_config.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/position.dart';
import '../../domain/entities/game_result.dart';

/// Data Transfer Object for GameState persistence
///
/// Handles serialization of complex nested structures:
/// - 2D board array
/// - Enum conversions (Player, GameResult, GameMode, etc.)
/// - DateTime to ISO8601 strings
/// - Position lists to JSON-friendly format
class GameStateModel {
  final List<List<String>> board;
  final String currentPlayer;
  final String result;
  final String? winner;
  final List<Map<String, int>>? winningLine;
  final List<Map<String, int>> moveHistory;
  final GameConfigModel config;
  final String startTime;
  final int elapsedTimeMs;

  const GameStateModel({
    required this.board,
    required this.currentPlayer,
    required this.result,
    this.winner,
    this.winningLine,
    required this.moveHistory,
    required this.config,
    required this.startTime,
    required this.elapsedTimeMs,
  });

  /// Deserialize from JSON - handles nested structures
  factory GameStateModel.fromJson(Map<String, dynamic> json) {
    return GameStateModel(
      board: (json['board'] as List)
          .map((row) => (row as List).map((cell) => cell as String).toList())
          .toList(),
      currentPlayer: json['currentPlayer'] as String,
      result: json['result'] as String,
      winner: json['winner'] as String?,
      winningLine: json['winningLine'] != null
          ? (json['winningLine'] as List)
              .map((pos) => Map<String, int>.from(pos as Map))
              .toList()
          : null,
      moveHistory: (json['moveHistory'] as List)
          .map((pos) => Map<String, int>.from(pos as Map))
          .toList(),
      config: GameConfigModel.fromJson(json['config'] as Map<String, dynamic>),
      startTime: json['startTime'] as String,
      elapsedTimeMs: json['elapsedTimeMs'] as int,
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'board': board,
      'currentPlayer': currentPlayer,
      'result': result,
      'winner': winner,
      'winningLine': winningLine,
      'moveHistory': moveHistory,
      'config': config.toJson(),
      'startTime': startTime,
      'elapsedTimeMs': elapsedTimeMs,
    };
  }

  /// Convert from domain entity - handles enum and object conversions
  factory GameStateModel.fromEntity(GameState state) {
    return GameStateModel(
      board: state.board
          .map((row) => row.map((player) => _playerToString(player)).toList())
          .toList(),
      currentPlayer: _playerToString(state.currentPlayer),
      result: _resultToString(state.result),
      winner: state.winner != null ? _playerToString(state.winner!) : null,
      winningLine: state.winningLine
          ?.map((pos) => {'row': pos.row, 'col': pos.col})
          .toList(),
      moveHistory:
          state.moveHistory.map((pos) => {'row': pos.row, 'col': pos.col}).toList(),
      config: GameConfigModel.fromEntity(state.config),
      startTime: state.startTime.toIso8601String(),
      elapsedTimeMs: state.elapsedTime.inMilliseconds,
    );
  }

  /// Convert to domain entity
  GameState toEntity() {
    return GameState(
      board: board
          .map((row) => row.map((cell) => _stringToPlayer(cell)).toList())
          .toList(),
      currentPlayer: _stringToPlayer(currentPlayer),
      result: _stringToResult(result),
      winner: winner != null ? _stringToPlayer(winner!) : null,
      winningLine: winningLine
          ?.map((pos) => Position(row: pos['row']!, col: pos['col']!))
          .toList(),
      moveHistory: moveHistory
          .map((pos) => Position(row: pos['row']!, col: pos['col']!))
          .toList(),
      config: config.toEntity(),
      startTime: DateTime.parse(startTime),
      elapsedTime: Duration(milliseconds: elapsedTimeMs),
    );
  }

  // Helper methods for enum conversions
  static String _playerToString(Player player) {
    switch (player) {
      case Player.x: return 'x';
      case Player.o: return 'o';
      case Player.none: return 'none';
    }
  }

  static Player _stringToPlayer(String value) {
    switch (value) {
      case 'x': return Player.x;
      case 'o': return Player.o;
      case 'none': return Player.none;
      default: return Player.none;
    }
  }

  static String _resultToString(GameResult result) {
    switch (result) {
      case GameResult.ongoing: return 'ongoing';
      case GameResult.win: return 'win';
      case GameResult.loss: return 'loss';
      case GameResult.draw: return 'draw';
    }
  }

  static GameResult _stringToResult(String value) {
    switch (value) {
      case 'ongoing': return GameResult.ongoing;
      case 'win': return GameResult.win;
      case 'loss': return GameResult.loss;
      case 'draw': return GameResult.draw;
      default: return GameResult.ongoing;
    }
  }
}
```

**Repository for GameState**:

```dart
// data/repositories/game_state_repository.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/game_state.dart';
import '../models/game_state_model.dart';

class GameStateRepository {
  static const String _savedGameKey = 'saved_game';

  /// Save game: Entity → Model → JSON → Storage
  Future<void> saveGame(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    final model = GameStateModel.fromEntity(state);
    final jsonString = jsonEncode(model.toJson());
    await prefs.setString(_savedGameKey, jsonString);
  }

  /// Load game: Storage → JSON → Model → Entity
  Future<GameState?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_savedGameKey);

    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final model = GameStateModel.fromJson(json);
      return model.toEntity();
    } catch (e) {
      await deleteSavedGame(); // Clean up corrupted data
      return null;
    }
  }

  Future<bool> hasSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_savedGameKey);
  }

  Future<void> deleteSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedGameKey);
  }
}
```

**Key Takeaways for Complex Models**:
1. **Nested objects**: Create separate models (e.g., `GameConfigModel`)
2. **Enums**: Convert to/from strings for JSON compatibility
3. **Collections**: Map complex objects (e.g., `List<Position>` → `List<Map<String, int>>`)
4. **DateTime**: Use ISO8601 strings for serialization
5. **Error handling**: Try-catch with fallback in repositories

#### Example: User Model (Complex Case with Freezed)

```dart
// data/models/user_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String username,
    required DateTime createdAt,
    String? avatarUrl,
    @Default(false) bool isVerified,
    @Default([]) List<String> roles,
  }) = _UserModel;

  // ONLY serialization helpers
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  // ❌ NO business logic like:
  // bool canPerformAction(Action action) { ... }  // Belongs in AuthService
  // int calculateAge() { ... }  // Belongs in UserService
  // bool hasPermission(Permission p) { ... }  // Belongs in PermissionService
}

// Extension for conversions
extension UserModelX on UserModel {
  // Simple computed properties - OK
  String get displayName => username.isEmpty ? email : username;

  // Convert to domain entity - OK
  User toEntity() => User(
    id: id,
    email: email,
    username: username,
    createdAt: createdAt,
    avatarUrl: avatarUrl,
    isVerified: isVerified,
    roles: roles,
  );
}
```

#### Repository Pattern with Models

```dart
// data/repositories/score_repository.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/score.dart';
import '../models/score_model.dart';

class ScoreRepository {
  /// Load score: Storage → Model → Entity
  Future<Score> loadScore() async {
    final prefs = await SharedPreferences.getInstance();
    final wins = prefs.getInt('wins') ?? 0;
    final losses = prefs.getInt('losses') ?? 0;
    final draws = prefs.getInt('draws') ?? 0;

    // Create model from raw data
    final model = ScoreModel(
      wins: wins,
      losses: losses,
      draws: draws,
    );

    // Convert to domain entity
    return model.toEntity();
  }

  /// Save score: Entity → Model → Storage
  Future<void> saveScore(Score score) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert domain entity to data model
    final model = ScoreModel.fromEntity(score);

    // Persist the model
    await prefs.setInt('wins', model.wins);
    await prefs.setInt('losses', model.losses);
    await prefs.setInt('draws', model.draws);
  }
}
```

**Why Separate Models from Entities?**
1. **Independence**: API changes don't affect domain logic
2. **Flexibility**: Different persistence formats (JSON, SQLite, etc.)
3. **Testability**: Mock data sources easily
4. **Evolution**: API v1 → v2 without touching domain
5. **Clean Architecture**: Clear layer boundaries

### 3. Value Object Model

```dart
// domain/entities/move.dart
class Move extends Equatable {
  final Position from;
  final Position to;
  final DateTime timestamp;
  final String? notation;

  const Move({
    required this.from,
    required this.to,
    required this.timestamp,
    this.notation,
  });

  // Simple formatting - OK
  String toNotation() => notation ?? '${from.toNotation()}-${to.toNotation()}';

  // Basic property check - OK
  bool get isDiagonal => (from.x - to.x).abs() == (from.y - to.y).abs();
  bool get isHorizontal => from.y == to.y;
  bool get isVertical => from.x == to.x;

  // ❌ NO business logic like:
  // bool isValidForPiece(Piece piece) { ... }  // Belongs in GameService
  // bool isCheck() { ... }  // Belongs in GameService
  // List<Position> getPath() { ... }  // Belongs in PathService

  @override
  List<Object?> get props => [from, to, timestamp, notation];
}

class Position extends Equatable {
  final int x;
  final int y;

  const Position(this.x, this.y);

  // Simple conversions - OK
  String toNotation() => '${String.fromCharCode(97 + x)}${8 - y}';

  // Basic calculations - OK
  Position offset(int dx, int dy) => Position(x + dx, y + dy);

  // ❌ NO business logic like:
  // bool isValidOnBoard(Board board) { ... }  // Belongs in GameService
  // bool isThreatened(GameState state) { ... }  // Belongs in GameService

  @override
  List<Object> get props => [x, y];
}
```

### 4. Configuration Model

```dart
// domain/entities/game_config.dart
@immutable
class GameConfig {
  final BoardSize boardSize;
  final List<Player> players;
  final Duration timeLimit;
  final DifficultyLevel difficulty;
  final Map<String, dynamic> customRules;

  const GameConfig({
    required this.boardSize,
    required this.players,
    required this.timeLimit,
    required this.difficulty,
    this.customRules = const {},
  });

  // Factory constructors for common configurations - OK
  factory GameConfig.quickGame() => GameConfig(
    boardSize: BoardSize.standard,
    players: [Player.human(), Player.ai()],
    timeLimit: const Duration(minutes: 5),
    difficulty: DifficultyLevel.medium,
  );

  // Simple property accessors - OK
  bool get isSinglePlayer => players.where((p) => p.isHuman).length == 1;
  bool get hasTimeLimit => timeLimit != Duration.zero;

  // ❌ NO business logic like:
  // bool isValidConfiguration() { ... }  // Belongs in ConfigService
  // GameConfig applyHandicap(Player player) { ... }  // Belongs in GameService
  // int calculateStartingScore() { ... }  // Belongs in ScoringService

  GameConfig copyWith({...}) => GameConfig(...);
}
```

## Service Templates (Where Business Logic Lives)

### 1. Service with Clean Public API

```dart
// domain/services/game_service.dart
@LazySingleton()
class GameService {
  final RulesEngine _rulesEngine;
  final BoardAnalyzer _boardAnalyzer;

  GameService(this._rulesEngine, this._boardAnalyzer);

  // ===== PUBLIC API (Keep minimal - 3-5 methods) =====

  GameState startNewGame(GameConfig config) {
    final board = _createInitialBoard(config.boardSize);
    final players = _setupPlayers(config.players);

    return GameState(
      board: board,
      currentPlayer: players.first,
      moveHistory: const [],
      elapsedTime: Duration.zero,
      phase: GamePhase.playing,
    );
  }

  MoveResult makeMove(GameState state, Move move) {
    // Validate
    final validationError = _validateMove(state, move);
    if (validationError != null) {
      return MoveResult.invalid(reason: validationError);
    }

    // Apply move
    final newBoard = _applyMoveToBoard(state.board, move);
    final capturedPieces = _getCapturedPieces(state.board, newBoard);

    // Update state
    final newState = state.copyWith(
      board: newBoard,
      currentPlayer: _getNextPlayer(state),
      moveHistory: [...state.moveHistory, move],
    );

    // Check game end
    final gameResult = _checkGameEnd(newState);

    return MoveResult.success(
      newState: newState,
      gameResult: gameResult,
      capturedPieces: capturedPieces,
    );
  }

  List<Move> getValidMoves(GameState state) {
    final moves = <Move>[];
    final currentPlayerPieces = _getCurrentPlayerPieces(state);

    for (final piece in currentPlayerPieces) {
      final pieceMoves = _getValidMovesForPiece(state, piece);
      moves.addAll(pieceMoves);
    }

    return moves;
  }

  Future<Move> suggestBestMove(GameState state, DifficultyLevel level) async {
    final validMoves = getValidMoves(state);
    if (validMoves.isEmpty) return Move.invalid();

    return switch (level) {
      DifficultyLevel.easy => _selectRandomMove(validMoves),
      DifficultyLevel.medium => _selectTacticalMove(state, validMoves),
      DifficultyLevel.hard => await _calculateBestMove(state, validMoves),
    };
  }

  // ===== PRIVATE IMPLEMENTATION (Hidden complexity) =====

  Board _createInitialBoard(BoardSize size) {
    // Implementation details hidden
    final board = Board(size: size);
    _placePieces(board);
    return board;
  }

  List<Player> _setupPlayers(List<PlayerConfig> configs) {
    // Complex setup logic
    return configs.map(_createPlayer).toList();
  }

  String? _validateMove(GameState state, Move move) {
    if (!_isWithinBounds(state.board, move.from)) {
      return 'Starting position is out of bounds';
    }

    if (!_isWithinBounds(state.board, move.to)) {
      return 'Target position is out of bounds';
    }

    final piece = state.board.getPieceAt(move.from);
    if (piece == null) {
      return 'No piece at starting position';
    }

    if (piece.owner != state.currentPlayer) {
      return 'Cannot move opponent\'s piece';
    }

    if (!_isValidMovePattern(piece, move)) {
      return 'Invalid move pattern for ${piece.type}';
    }

    if (_wouldResultInCheck(state, move)) {
      return 'Move would leave king in check';
    }

    return null; // Move is valid
  }

  Board _applyMoveToBoard(Board board, Move move) {
    // Complex board manipulation
    final newBoard = board.copy();
    final piece = newBoard.removePieceAt(move.from);
    newBoard.placePieceAt(move.to, piece!);

    // Handle special moves
    _handleCastling(newBoard, move);
    _handleEnPassant(newBoard, move);
    _handlePromotion(newBoard, move);

    return newBoard;
  }

  List<Piece> _getCapturedPieces(Board oldBoard, Board newBoard) {
    // Logic to determine captured pieces
    final captured = <Piece>[];
    for (final position in oldBoard.allPositions) {
      final oldPiece = oldBoard.getPieceAt(position);
      final newPiece = newBoard.getPieceAt(position);
      if (oldPiece != null && newPiece == null) {
        captured.add(oldPiece);
      }
    }
    return captured;
  }

  Player _getNextPlayer(GameState state) {
    final currentIndex = state.players.indexOf(state.currentPlayer);
    final nextIndex = (currentIndex + 1) % state.players.length;
    return state.players[nextIndex];
  }

  GameResult? _checkGameEnd(GameState state) {
    if (_isCheckmate(state)) {
      return GameResult.checkmate(winner: _getOpponent(state.currentPlayer));
    }

    if (_isStalemate(state)) {
      return GameResult.stalemate();
    }

    if (_isInsufficientMaterial(state)) {
      return GameResult.draw(reason: DrawReason.insufficientMaterial);
    }

    return null;
  }

  // Many more private methods handling complex logic...
  bool _isCheckmate(GameState state) { /* ... */ }
  bool _isStalemate(GameState state) { /* ... */ }
  bool _isInsufficientMaterial(GameState state) { /* ... */ }
  bool _wouldResultInCheck(GameState state, Move move) { /* ... */ }
  void _handleCastling(Board board, Move move) { /* ... */ }
  void _handleEnPassant(Board board, Move move) { /* ... */ }
  void _handlePromotion(Board board, Move move) { /* ... */ }
  Move _selectRandomMove(List<Move> moves) { /* ... */ }
  Move _selectTacticalMove(GameState state, List<Move> moves) { /* ... */ }
  Future<Move> _calculateBestMove(GameState state, List<Move> moves) async { /* ... */ }
}
  final RulesEngine _rulesEngine;
  final AIEngine _aiEngine;

  GameService(this._rulesEngine, this._aiEngine);

  // Pure business logic methods
  GameState initializeGame(GameConfig config) {
    // Pure business logic
    final board = _createBoard(config.boardSize);
    final players = _setupPlayers(config.players);

    return GameState(
      board: board,
      currentPlayer: players.first,
      moveHistory: const [],
      elapsedTime: Duration.zero,
      phase: GamePhase.playing,
    );
  }

  MoveResult makeMove(GameState state, Move move) {
    // Validate move
    if (!isValidMove(state, move)) {
      return MoveResult.invalid(reason: 'Invalid move position');
    }

    // Apply move
    final newBoard = _applyMove(state.board, move);
    final newState = state.copyWith(
      board: newBoard,
      currentPlayer: _nextPlayer(state),
      moveHistory: [...state.moveHistory, move],
    );

    // Check win condition
    final result = checkGameEnd(newState);

    return MoveResult.success(
      newState: newState,
      gameResult: result,
      capturedPieces: _getCapturedPieces(state.board, newBoard),
    );
  }

  Future<Move> calculateBestMove(GameState state, DifficultyLevel level) async {
    // AI logic - can run completely headless
    return _aiEngine.calculateMove(
      state: state,
      depth: level.searchDepth,
      timeLimit: level.timeLimit,
    );
  }

  Future<List<GameEvent>> simulateGame(Player player1, Player player2) async {
    // Complete game simulation without UI
    final events = <GameEvent>[];
    var state = initializeGame(GameConfig.default());

    while (checkGameEnd(state) == null) {
      final move = await _getPlayerMove(state, state.currentPlayer);
      final result = makeMove(state, move);

      events.add(GameEvent.moveMade(
        player: state.currentPlayer,
        move: move,
        timestamp: DateTime.now(),
      ));

      if (result.isSuccess) {
        state = result.newState!;
      }
    }

    return events;
  }

  // Private helper methods
  bool _isValidPosition(Board board, Position pos) =>
    pos.x >= 0 && pos.x < board.width &&
    pos.y >= 0 && pos.y < board.height;
}
```

### 2. Authentication Service with Minimal API

```dart
// domain/services/auth_service.dart
@injectable
class AuthService {
  final AuthRepository _repository;
  final TokenManager _tokenManager;
  final SessionValidator _validator;

  AuthService(this._repository, this._tokenManager, this._validator);

  // ===== PUBLIC API (Only 4 methods) =====

  Future<AuthResult> login(String email, String password) async {
    // Validate input
    final validationError = _validateCredentials(email, password);
    if (validationError != null) {
      return AuthResult.failure(validationError);
    }

    try {
      // Attempt login
      final response = await _repository.authenticate(email, password);

      // Process tokens
      await _storeTokens(response.accessToken, response.refreshToken);

      // Get user data
      final user = await _fetchUserProfile(response.userId);

      return AuthResult.success(user: user);
    } catch (e) {
      return AuthResult.failure(_mapError(e));
    }
  }

  Future<void> logout() async {
    await _clearLocalSession();
    await _repository.revokeToken();
    await _tokenManager.clearAll();
  }

  Future<User?> getCurrentUser() async {
    final token = await _tokenManager.getAccessToken();
    if (token == null) return null;

    if (!_isTokenValid(token)) {
      final refreshed = await _attemptTokenRefresh();
      if (!refreshed) return null;
    }

    return _getCachedUser() ?? await _fetchCurrentUser();
  }

  Future<bool> refreshSession() async {
    return _attemptTokenRefresh();
  }

  // ===== PRIVATE IMPLEMENTATION =====

  String? _validateCredentials(String email, String password) {
    if (email.isEmpty) return 'Email is required';
    if (!_isValidEmail(email)) return 'Invalid email format';
    if (password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Password too short';
    return null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}
```

## Bloc Templates (UI State Only)

### 1. UI-Focused Bloc

```dart
// presentation/blocs/game_ui/game_ui_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'game_ui_event.dart';
part 'game_ui_state.dart';

@injectable
class GameUIBloc extends Bloc<GameUIEvent, GameUIState> {
  final GameService _gameService;  // Service handles logic
  final AudioService _audioService;
  final HapticService _hapticService;

  Timer? _timer;

  GameUIBloc(
    this._gameService,
    this._audioService,
    this._hapticService,
  ) : super(const GameUIInitial()) {
    on<StartNewGame>(_onStartNewGame);
    on<MakeMove>(_onMakeMove);
    on<HighlightValidMoves>(_onHighlightValidMoves);
    on<ToggleSound>(_onToggleSound);
    on<UpdateTimer>(_onUpdateTimer);
    on<ShowHint>(_onShowHint);
  }

  Future<void> _onStartNewGame(
    StartNewGame event,
    Emitter<GameUIState> emit,
  ) async {
    // UI concerns: show loading, setup timer
    emit(const GameUILoading());

    // Service handles business logic
    final gameState = _gameService.initializeGame(event.config);

    // Start UI timer
    _startTimer();

    // UI state with presentation concerns
    emit(GameUIReady(
      gameState: gameState,
      highlightedCells: const [],
      soundEnabled: true,
      showMoveAnimation: true,
      selectedPiece: null,
      hintMove: null,
    ));
  }

  Future<void> _onMakeMove(
    MakeMove event,
    Emitter<GameUIState> emit,
  ) async {
    if (state is! GameUIReady) return;

    final currentState = state as GameUIReady;

    // Show move preview (UI concern)
    emit(currentState.copyWith(
      moveInProgress: true,
      animatingFrom: event.from,
      animatingTo: event.to,
    ));

    // Service handles the actual move logic
    final result = _gameService.makeMove(
      currentState.gameState,
      Move(from: event.from, to: event.to),
    );

    if (result.isSuccess) {
      // UI feedback
      if (currentState.soundEnabled) {
        await _audioService.playMoveSound();
      }
      await _hapticService.moveFeedback();

      // Update UI state
      emit(currentState.copyWith(
        gameState: result.newState,
        moveInProgress: false,
        lastMove: Move(from: event.from, to: event.to),
        animatingFrom: null,
        animatingTo: null,
      ));

      // Check if game ended (show UI dialog)
      if (result.gameResult != null) {
        emit(GameUIComplete(
          gameState: result.newState!,
          result: result.gameResult!,
          showCelebration: result.gameResult!.isWin,
        ));
      }
    } else {
      // Show error (UI concern)
      emit(currentState.copyWith(
        moveInProgress: false,
        errorMessage: result.reason,
        shakeInvalidMove: true,
      ));
    }
  }

  void _onHighlightValidMoves(
    HighlightValidMoves event,
    Emitter<GameUIState> emit,
  ) {
    if (state is! GameUIReady) return;

    final currentState = state as GameUIReady;

    // Service calculates valid moves
    final validMoves = _gameService.getValidMoves(currentState.gameState);

    // UI just displays them
    emit(currentState.copyWith(
      highlightedCells: validMoves.map((m) => m.to).toList(),
      selectedPiece: event.piece,
    ));
  }

  void _onToggleSound(
    ToggleSound event,
    Emitter<GameUIState> emit,
  ) {
    // Pure UI concern
    if (state is GameUIReady) {
      final currentState = state as GameUIReady;
      emit(currentState.copyWith(soundEnabled: !currentState.soundEnabled));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const UpdateTimer());
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
```

### 2. UI State (Presentation Concerns)

```dart
// game_ui_state.dart
part of 'game_ui_bloc.dart';

sealed class GameUIState extends Equatable {
  const GameUIState();

  @override
  List<Object?> get props => [];
}

final class GameUIInitial extends GameUIState {
  const GameUIInitial();
}

final class GameUILoading extends GameUIState {
  const GameUILoading();
}

final class GameUIReady extends GameUIState {
  // Business state from service
  final GameState gameState;

  // UI-specific state
  final List<Position> highlightedCells;
  final bool soundEnabled;
  final bool showMoveAnimation;
  final Piece? selectedPiece;
  final Move? lastMove;
  final Move? hintMove;
  final bool moveInProgress;
  final Position? animatingFrom;
  final Position? animatingTo;
  final String? errorMessage;
  final bool shakeInvalidMove;
  final Duration displayTime;

  const GameUIReady({
    required this.gameState,
    required this.highlightedCells,
    required this.soundEnabled,
    required this.showMoveAnimation,
    this.selectedPiece,
    this.lastMove,
    this.hintMove,
    this.moveInProgress = false,
    this.animatingFrom,
    this.animatingTo,
    this.errorMessage,
    this.shakeInvalidMove = false,
    this.displayTime = Duration.zero,
  });

  @override
  List<Object?> get props => [
    gameState,
    highlightedCells,
    soundEnabled,
    showMoveAnimation,
    selectedPiece,
    lastMove,
    hintMove,
    moveInProgress,
    animatingFrom,
    animatingTo,
    errorMessage,
    shakeInvalidMove,
    displayTime,
  ];

  GameUIReady copyWith({...});
}

final class GameUIComplete extends GameUIState {
  final GameState gameState;
  final GameResult result;
  final bool showCelebration;

  const GameUIComplete({
    required this.gameState,
    required this.result,
    required this.showCelebration,
  });

  @override
  List<Object?> get props => [gameState, result, showCelebration];
}
```

## Service Usage Examples

### 1. Service with Flutter-specific features

```dart
// domain/services/game_service.dart
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class GameService extends ChangeNotifier {
  GameState _currentState = GameState.initial();

  GameState get currentState => _currentState;

  void initializeGame(GameConfig config) {
    _currentState = GameState(
      board: _createBoard(config.boardSize),
      currentPlayer: config.players.first,
      moveHistory: const [],
      elapsedTime: Duration.zero,
      phase: GamePhase.playing,
    );
    notifyListeners();
  }

  MoveResult makeMove(Move move) {
    if (!isValidMove(_currentState, move)) {
      return MoveResult.invalid(reason: 'Invalid move position');
    }

    final newBoard = _applyMove(_currentState.board, move);
    _currentState = _currentState.copyWith(
      board: newBoard,
      currentPlayer: _nextPlayer(_currentState),
      moveHistory: [..._currentState.moveHistory, move],
    );

    final result = checkGameEnd(_currentState);

    if (kDebugMode) {
      print('Move made: ${move.toString()}');
    }

    notifyListeners();

    return MoveResult.success(
      newState: _currentState,
      gameResult: result,
    );
  }

  Future<Move> calculateBestMove(DifficultyLevel level) async {
    // Can use compute for heavy calculations
    if (level == DifficultyLevel.hard) {
      return compute(_calculateMoveInIsolate, _currentState);
    }

    return _calculateSimpleMove(_currentState);
  }

  static Move _calculateMoveInIsolate(GameState state) {
    // Heavy computation in isolate
    return Move(from: Position(0, 0), to: Position(1, 1));
  }
}
```

### 2. Testing Services

```dart
// test/services/game_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late GameService gameService;

  setUp(() {
    gameService = GameService();
  });

  group('GameService', () {
    test('initializes game correctly', () {
      final config = GameConfig.default();
      gameService.initializeGame(config);

      expect(gameService.currentState.board.isEmpty, isTrue);
      expect(gameService.currentState.currentPlayer.id, equals('player1'));
      expect(gameService.currentState.moveHistory, isEmpty);
    });

    test('validates moves correctly', () {
      gameService.initializeGame(GameConfig.default());

      final validMove = Move(from: Position(0, 0), to: Position(1, 1));
      expect(gameService.isValidMove(gameService.currentState, validMove), isTrue);

      final invalidMove = Move(from: Position(0, 0), to: Position(10, 10));
      expect(gameService.isValidMove(gameService.currentState, invalidMove), isFalse);
    });

    test('notifies listeners on state change', () {
      var notificationCount = 0;
      gameService.addListener(() {
        notificationCount++;
      });

      gameService.initializeGame(GameConfig.default());
      expect(notificationCount, equals(1));

      gameService.makeMove(Move(from: Position(0, 0), to: Position(1, 1)));
      expect(notificationCount, equals(2));
    });
  });
}
```

### 3. Checkout Service with Focused API

````dart
// domain/services/checkout_service.dart
@injectable
class CheckoutService {
  final InventoryService _inventory;
  final PricingService _pricing;
  final PaymentService _payment;
  final OrderRepository _orderRepo;

  CheckoutService(
    this._inventory,
    this._pricing,
    this._payment,
    this._orderRepo,
  );

  // ===== PUBLIC API (Only 3 methods) =====

  Future<CheckoutValidation> validateCart(Cart cart) async {
    final availability = await _checkInventory(cart);
    final pricing = await _calculateTotals(cart);
    final issues = _identifyIssues(availability, pricing);

    return CheckoutValidation(
      isValid: issues.isEmpty,
      issues: issues,
      availability: availability,
      pricing: pricing,
    );
  }

  Future<CheckoutResult> processCheckout({
    required Cart cart,
    required PaymentMethod paymentMethod,
    required ShippingAddress address,
  }) async {
    // Validate everything
    final validation = await validateCart(cart);
    if (!validation.isValid) {
      return CheckoutResult.validationFailed(validation.issues);
    }

    // Reserve inventory
    final reservationId = await _reserveInventory(cart);

    try {
      // Process payment
      final paymentResult = await _processPayment(
        validation.pricing!,
        paymentMethod,
      );

      if (!paymentResult.success) {
        await _releaseInventory(reservationId);
        return CheckoutResult.paymentFailed(paymentResult.error);
      }

      // Create order
      final order = await _createOrder(
        cart: cart,
        payment: paymentResult,
        address: address,
      );

      // Commit inventory
      await _commitInventory(reservationId);

      return CheckoutResult.success(order: order);

    } catch (e) {
      await _releaseInventory(reservationId);
      await _refundPaymentIfNeeded(cart.id);
      return CheckoutResult.systemError(_mapError(e));
    }
  }

  Future<Order?> retryFailedOrder(String orderId) async {
    final order = await _orderRepo.getById(orderId);
    if (order == null || order.status != OrderStatus.paymentFailed) {
      return null;
    }

    // Attempt to recover
    return _retryOrderProcessing(order);
  }

  // ===== PRIVATE IMPLEMENTATION (All complexity hidden) =====

  Future<InventoryAvailability> _checkInventory(Cart cart) async {
    final results = await Future.wait(
      cart.items.map((item) => _inventory.checkAvailability(
        productId: item.productId,
        quantity: item.quantity,
      )),
    );

    return InventoryAvailability(
      items: Map.fromIterables(cart.items, results),
      allAvailable: results.every((r) => r.isAvailable),
    );
  }

  Future<PricingBreakdown> _calculateTotals(Cart cart) async {
    // Complex pricing logic delegated to PricingService
    final itemPrices = await Future.wait(
      cart.items.map((item) => _pricing.calculateItemPrice(item)),
    );

    final subtotal = itemPrices.fold(0.0, (sum, price) => sum + price);
    final shipping = await _calculateShipping(cart);
    final tax = await _calculateTax(subtotal + shipping);

    return PricingBreakdown(
      items: itemPrices,
      subtotal: subtotal,
      shipping: shipping,
      tax: tax,
      total: subtotal + shipping + tax,
    );
  }

  List<CheckoutIssue> _identifyIssues(
    InventoryAvailability availability,
    PricingBreakdown pricing,
  ) {
    final issues = <CheckoutIssue>[];

    // Check inventory issues
    for (final entry in availability.items.entries) {
      if (!entry.value.isAvailable) {
        issues.add(CheckoutIssue.outOfStock(entry.key.productId));
      }
    }

    // Check pricing issues
    if (pricing.total <= 0) {
      issues.add(CheckoutIssue.invalidTotal());
    }

    return issues;
  }

  // Many more private helper methods...
  Future<String> _reserveInventory(Cart cart) async { /* ... */ }
  Future<void> _releaseInventory(String reservationId) async { /* ... */ }
  Future<void> _commitInventory(String reservationId) async { /* ... */ }
  Future<PaymentResult> _processPayment(
    PricingBreakdown pricing,
    PaymentMethod method,
  ) async { /* ... */ }
  Future<Order> _createOrder({
    required Cart cart,
    required PaymentResult payment,
    required ShippingAddress address,
  }) async { /* ... */ }
  Future<void> _refundPaymentIfNeeded(String cartId) async { /* ... */ }
  Future<Order> _retryOrderProcessing(Order order) async { /* ... */ }
  Future<double> _calculateShipping(Cart cart) async { /* ... */ }
  Future<double> _calculateTax(double amount) async { /* ... */ }
  String _mapError(dynamic error) { /* ... */ }
}

## Service Testing Patterns

```dart
// Integration tests with Flutter
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRepository extends Mock implements GameRepository {}
class MockRulesEngine extends Mock implements RulesEngine {}

void main() {
  group('GameService - Business Logic Tests', () {
    late GameService service;
    late MockRepository mockRepository;
    late MockRulesEngine mockRules;

    setUp(() {
      mockRepository = MockRepository();
      mockRules = MockRulesEngine();
      service = GameServiceImpl(mockRepository, mockRules);
    });

    test('business rule: cannot move twice in a row', () {
      final state = GameState(
        currentPlayer: Player(id: 'p1'),
        lastMoveBy: 'p1',
      );

      final move = Move(player: 'p1', position: Position(0, 0));
      final result = service.makeMove(state, move);

      expect(result.isSuccess, isFalse);
      expect(result.reason, contains('cannot move twice'));
    });

    test('complex scoring calculation', () {
      final state = createTestGameState();
      final score = service.calculateScore(state);

      expect(score.player1, equals(42));
      expect(score.player2, equals(38));
      expect(score.bonus, equals(5));
    });
  });
}
````

## Dependency Injection Setup

```dart
// injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> init() async {
  await getIt.init();

  // Initialize services that need setup
  await getIt<StorageService>().init();
  await getIt<AuthService>().initialize();
}

// Services are registered with @LazySingleton or @Singleton decorators
```

## Best Practices & Rules

### ✅ Model Layer DO's:

- Keep models as simple data containers
- Only include basic helper methods (copyWith, toJson, fromJson)
- Use simple computed properties (getters for derived values)
- Implement equality (Equatable or freezed)
- Keep serialization logic in models
- Use extensions for simple formatting helpers

### ✅ Service Layer DO's:

- Keep public API minimal - only expose what's needed
- Prefix all private methods with underscore (\_)
- Most services should have 3-5 public methods maximum
- Keep services focused on a single responsibility
- Make services testable with dependency injection
- Return immutable results when possible
- Handle all business rules in services
- Use Flutter features when helpful (compute, platform channels)

### ✅ Bloc Layer DO's:

- Use Blocs ONLY for UI state management
- Handle user interactions and UI events
- Coordinate service calls
- Manage UI-specific state (animations, selections, etc.)
- Handle loading/error states for UI
- Manage form state and validation display

### ❌ DON'Ts:

- **NEVER put business logic in Blocs**
- **NEVER put business logic in Models**
- **NEVER use StatefulWidget**
- Don't make Blocs dependent on each other
- Don't access services directly from widgets (go through Blocs)
- Don't mix UI concerns with business logic
- Don't create "God services" - keep them focused
- Don't put UI state in services
- Don't add complex methods to models - use services instead

## Common Claude Code Commands

```bash
# Model creation (thin)
"Create a User model with properties and basic helpers only - no business logic"

# Service creation (business logic)
"Create a UserService that handles user validation, permissions, and business rules"

# Bloc for UI coordination
"Create a UserProfileBloc that uses UserService and handles UI state"

# Refactoring
"Extract business logic from this model into a service"
"Move validation logic from this Bloc into appropriate service"

# Testing
"Write tests for UserService business logic"
"Test the User model's serialization and equality"

# Architecture check
"Review this code and identify any business logic that should be moved to services"
```

## Example: Complete Feature Implementation

```dart
// 1. Service (Pure Business Logic)
@injectable
class CheckoutService {
  final InventoryService _inventory;
  final PricingService _pricing;
  final PaymentService _payment;

  CheckoutService(this._inventory, this._pricing, this._payment);

  CheckoutResult processCheckout(Cart cart, PaymentMethod method) {
    // Check inventory
    final availability = _inventory.checkAvailability(cart.items);
    if (!availability.allAvailable) {
      return CheckoutResult.unavailable(availability.unavailableItems);
    }

    // Calculate pricing
    final pricing = _pricing.calculateTotal(cart);

    // Process payment
    final paymentResult = _payment.process(pricing.total, method);

    if (paymentResult.success) {
      _inventory.reduceStock(cart.items);
      return CheckoutResult.success(
        orderId: generateOrderId(),
        total: pricing.total,
      );
    }

    return CheckoutResult.paymentFailed(paymentResult.error);
  }
}

// 2. Bloc (UI Coordination Only)
@injectable
class CheckoutUIBloc extends Bloc<CheckoutUIEvent, CheckoutUIState> {
  final CheckoutService _checkoutService;

  CheckoutUIBloc(this._checkoutService) : super(CheckoutUIInitial()) {
    on<StartCheckout>(_onStartCheckout);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
    on<ConfirmCheckout>(_onConfirmCheckout);
  }

  void _onStartCheckout(StartCheckout event, Emitter<CheckoutUIState> emit) {
    emit(CheckoutUIReady(
      cart: event.cart,
      selectedPayment: null,
      isProcessing: false,
      showPaymentOptions: true,
    ));
  }

  void _onConfirmCheckout(
    ConfirmCheckout event,
    Emitter<CheckoutUIState> emit
  ) async {
    final current = state as CheckoutUIReady;

    // Show loading UI
    emit(current.copyWith(isProcessing: true));

    // Service handles business logic
    final result = _checkoutService.processCheckout(
      current.cart,
      current.selectedPayment!,
    );

    // Update UI based on result
    if (result.success) {
      emit(CheckoutUISuccess(orderId: result.orderId));
    } else {
      emit(current.copyWith(
        isProcessing: false,
        errorMessage: result.error,
        showErrorDialog: true,
      ));
    }
  }
}

// 3. Can run without UI
void main() {
  final service = CheckoutService(...);
  final result = service.processCheckout(testCart, PaymentMethod.card);
  print('Checkout result: ${result.success}');
}
```

## Resources

- [Bloc Library Documentation](https://bloclibrary.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Domain-Driven Design](https://martinfowler.com/bliki/DomainDrivenDesign.html)
- [Hexagonal Architecture](https://alistair.cockburn.us/hexagonal-architecture/)
- [Flutter Clean Architecture Examples](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)).hasMatch(email);
  }

  Future<void> \_storeTokens(String accessToken, String refreshToken) async {
  await \_tokenManager.saveAccessToken(accessToken);
  await \_tokenManager.saveRefreshToken(refreshToken);
  }

  Future<User> \_fetchUserProfile(String userId) async {
  final userData = await \_repository.getUserProfile(userId);
  await \_cacheUser(userData);
  return userData;
  }

  Future<bool> \_attemptTokenRefresh() async {
  final refreshToken = await \_tokenManager.getRefreshToken();
  if (refreshToken == null) return false;

      try {
        final response = await _repository.refreshToken(refreshToken);
        await _storeTokens(response.accessToken, response.refreshToken);
        return true;
      } catch (_) {
        await logout();
        return false;
      }

  }

  bool \_isTokenValid(String token) {
  return \_validator.isValid(token) && !\_validator.isExpired(token);
  }

  // Additional private methods...
  Future<void> \_clearLocalSession() async { /_ ... _/ }
  User? \_getCachedUser() { /_ ... _/ }
  Future<User?> \_fetchCurrentUser() async { /_ ... _/ }
  Future<void> \_cacheUser(User user) async { /_ ... _/ }
  String \_mapError(dynamic error) { /_ ... _/ }
  }

````

## Bloc Templates (UI State Only)

### 1. UI-Focused Bloc
```dart
// presentation/blocs/game_ui/game_ui_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'game_ui_event.dart';
part 'game_ui_state.dart';

@injectable
class GameUIBloc extends Bloc<GameUIEvent, GameUIState> {
  final GameService _gameService;  // Service handles logic
  final AudioService _audioService;
  final HapticService _hapticService;

  Timer? _timer;

  GameUIBloc(
    this._gameService,
    this._audioService,
    this._hapticService,
  ) : super(const GameUIInitial()) {
    on<StartNewGame>(_onStartNewGame);
    on<MakeMove>(_onMakeMove);
    on<HighlightValidMoves>(_onHighlightValidMoves);
    on<ToggleSound>(_onToggleSound);
    on<UpdateTimer>(_onUpdateTimer);
    on<ShowHint>(_onShowHint);
  }

  Future<void> _onStartNewGame(
    StartNewGame event,
    Emitter<GameUIState> emit,
  ) async {
    // UI concerns: show loading, setup timer
    emit(const GameUILoading());

    // Service handles business logic
    final gameState = _gameService.initializeGame(event.config);

    // Start UI timer
    _startTimer();

    // UI state with presentation concerns
    emit(GameUIReady(
      gameState: gameState,
      highlightedCells: const [],
      soundEnabled: true,
      showMoveAnimation: true,
      selectedPiece: null,
      hintMove: null,
    ));
  }

  Future<void> _onMakeMove(
    MakeMove event,
    Emitter<GameUIState> emit,
  ) async {
    if (state is! GameUIReady) return;

    final currentState = state as GameUIReady;

    // Show move preview (UI concern)
    emit(currentState.copyWith(
      moveInProgress: true,
      animatingFrom: event.from,
      animatingTo: event.to,
    ));

    // Service handles the actual move logic
    final result = _gameService.makeMove(
      currentState.gameState,
      Move(from: event.from, to: event.to),
    );

    if (result.isSuccess) {
      // UI feedback
      if (currentState.soundEnabled) {
        await _audioService.playMoveSound();
      }
      await _hapticService.moveFeedback();

      // Update UI state
      emit(currentState.copyWith(
        gameState: result.newState,
        moveInProgress: false,
        lastMove: Move(from: event.from, to: event.to),
        animatingFrom: null,
        animatingTo: null,
      ));

      // Check if game ended (show UI dialog)
      if (result.gameResult != null) {
        emit(GameUIComplete(
          gameState: result.newState!,
          result: result.gameResult!,
          showCelebration: result.gameResult!.isWin,
        ));
      }
    } else {
      // Show error (UI concern)
      emit(currentState.copyWith(
        moveInProgress: false,
        errorMessage: result.reason,
        shakeInvalidMove: true,
      ));
    }
  }

  void _onHighlightValidMoves(
    HighlightValidMoves event,
    Emitter<GameUIState> emit,
  ) {
    if (state is! GameUIReady) return;

    final currentState = state as GameUIReady;

    // Service calculates valid moves
    final validMoves = _gameService.getValidMoves(currentState.gameState);

    // UI just displays them
    emit(currentState.copyWith(
      highlightedCells: validMoves.map((m) => m.to).toList(),
      selectedPiece: event.piece,
    ));
  }

  void _onToggleSound(
    ToggleSound event,
    Emitter<GameUIState> emit,
  ) {
    // Pure UI concern
    if (state is GameUIReady) {
      final currentState = state as GameUIReady;
      emit(currentState.copyWith(soundEnabled: !currentState.soundEnabled));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const UpdateTimer());
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
````

### 2. UI State (Presentation Concerns)

```dart
// game_ui_state.dart
part of 'game_ui_bloc.dart';

sealed class GameUIState extends Equatable {
  const GameUIState();

  @override
  List<Object?> get props => [];
}

final class GameUIInitial extends GameUIState {
  const GameUIInitial();
}

final class GameUILoading extends GameUIState {
  const GameUILoading();
}

final class GameUIReady extends GameUIState {
  // Business state from service
  final GameState gameState;

  // UI-specific state
  final List<Position> highlightedCells;
  final bool soundEnabled;
  final bool showMoveAnimation;
  final Piece? selectedPiece;
  final Move? lastMove;
  final Move? hintMove;
  final bool moveInProgress;
  final Position? animatingFrom;
  final Position? animatingTo;
  final String? errorMessage;
  final bool shakeInvalidMove;
  final Duration displayTime;

  const GameUIReady({
    required this.gameState,
    required this.highlightedCells,
    required this.soundEnabled,
    required this.showMoveAnimation,
    this.selectedPiece,
    this.lastMove,
    this.hintMove,
    this.moveInProgress = false,
    this.animatingFrom,
    this.animatingTo,
    this.errorMessage,
    this.shakeInvalidMove = false,
    this.displayTime = Duration.zero,
  });

  @override
  List<Object?> get props => [
    gameState,
    highlightedCells,
    soundEnabled,
    showMoveAnimation,
    selectedPiece,
    lastMove,
    hintMove,
    moveInProgress,
    animatingFrom,
    animatingTo,
    errorMessage,
    shakeInvalidMove,
    displayTime,
  ];

  GameUIReady copyWith({...});
}

final class GameUIComplete extends GameUIState {
  final GameState gameState;
  final GameResult result;
  final bool showCelebration;

  const GameUIComplete({
    required this.gameState,
    required this.result,
    required this.showCelebration,
  });

  @override
  List<Object?> get props => [gameState, result, showCelebration];
}
```

## Service Usage Examples

### 1. Service with Flutter-specific features

```dart
// domain/services/game_service.dart
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class GameService extends ChangeNotifier {
  GameState _currentState = GameState.initial();

  GameState get currentState => _currentState;

  void initializeGame(GameConfig config) {
    _currentState = GameState(
      board: _createBoard(config.boardSize),
      currentPlayer: config.players.first,
      moveHistory: const [],
      elapsedTime: Duration.zero,
      phase: GamePhase.playing,
    );
    notifyListeners();
  }

  MoveResult makeMove(Move move) {
    if (!isValidMove(_currentState, move)) {
      return MoveResult.invalid(reason: 'Invalid move position');
    }

    final newBoard = _applyMove(_currentState.board, move);
    _currentState = _currentState.copyWith(
      board: newBoard,
      currentPlayer: _nextPlayer(_currentState),
      moveHistory: [..._currentState.moveHistory, move],
    );

    final result = checkGameEnd(_currentState);

    if (kDebugMode) {
      print('Move made: ${move.toString()}');
    }

    notifyListeners();

    return MoveResult.success(
      newState: _currentState,
      gameResult: result,
    );
  }

  Future<Move> calculateBestMove(DifficultyLevel level) async {
    // Can use compute for heavy calculations
    if (level == DifficultyLevel.hard) {
      return compute(_calculateMoveInIsolate, _currentState);
    }

    return _calculateSimpleMove(_currentState);
  }

  static Move _calculateMoveInIsolate(GameState state) {
    // Heavy computation in isolate
    return Move(from: Position(0, 0), to: Position(1, 1));
  }
}
```

### 2. Testing Services

```dart
// test/services/game_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late GameService gameService;

  setUp(() {
    gameService = GameService();
  });

  group('GameService', () {
    test('initializes game correctly', () {
      final config = GameConfig.default();
      gameService.initializeGame(config);

      expect(gameService.currentState.board.isEmpty, isTrue);
      expect(gameService.currentState.currentPlayer.id, equals('player1'));
      expect(gameService.currentState.moveHistory, isEmpty);
    });

    test('validates moves correctly', () {
      gameService.initializeGame(GameConfig.default());

      final validMove = Move(from: Position(0, 0), to: Position(1, 1));
      expect(gameService.isValidMove(gameService.currentState, validMove), isTrue);

      final invalidMove = Move(from: Position(0, 0), to: Position(10, 10));
      expect(gameService.isValidMove(gameService.currentState, invalidMove), isFalse);
    });

    test('notifies listeners on state change', () {
      var notificationCount = 0;
      gameService.addListener(() {
        notificationCount++;
      });

      gameService.initializeGame(GameConfig.default());
      expect(notificationCount, equals(1));

      gameService.makeMove(Move(from: Position(0, 0), to: Position(1, 1)));
      expect(notificationCount, equals(2));
    });
  });
}
```

### 3. Service with Platform-specific code

````dart
// domain/services/storage_service.dart
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class StorageService {
  late final SharedPreferences _prefs;
  static const _platform = MethodChannel('com.example/native_storage');

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Business logic for data persistence
  Future<void> saveGameState(GameState state) async {
    final json = state.toJson();
    await _prefs.setString('game_state', jsonEncode(json));

    // Also save to platform-specific storage if needed
    if (Platform.isIOS) {
      await _platform.invokeMethod('saveToKeychain', json);
    }
  }

  Future<GameState?> loadGameState() async {
    final jsonString = _prefs.getString('game_state');
    if (jsonString == null) return null;

    return GameState.fromJson(jsonDecode(jsonString));
  }

  Future<List<GameRecord>> getGameHistory() async {
    // Complex business logic for retrieving and processing game history
    final records = <GameRecord>[];

    for (int i = 0; i < 10; i++) {
      final record = _prefs.getString('game_$i');
      if (record != null) {
        records.add(GameRecord.fromJson(jsonDecode(record)));
      }
    }

    // Sort by score and date
    records.sort((a, b) => b.score.compareTo(a.score));

    return records;
  }
}

## Service Testing Patterns

```dart
// Integration tests with Flutter
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRepository extends Mock implements GameRepository {}
class MockRulesEngine extends Mock implements RulesEngine {}

void main() {
  group('GameService - Business Logic Tests', () {
    late GameService service;
    late MockRepository mockRepository;
    late MockRulesEngine mockRules;

    setUp(() {
      mockRepository = MockRepository();
      mockRules = MockRulesEngine();
      service = GameServiceImpl(mockRepository, mockRules);
    });

    test('business rule: cannot move twice in a row', () {
      final state = GameState(
        currentPlayer: Player(id: 'p1'),
        lastMoveBy: 'p1',
      );

      final move = Move(player: 'p1', position: Position(0, 0));
      final result = service.makeMove(state, move);

      expect(result.isSuccess, isFalse);
      expect(result.reason, contains('cannot move twice'));
    });

    test('complex scoring calculation', () {
      final state = createTestGameState();
      final score = service.calculateScore(state);

      expect(score.player1, equals(42));
      expect(score.player2, equals(38));
      expect(score.bonus, equals(5));
    });
  });
}
````

## Dependency Injection Setup

```dart
// injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> init() async {
  await getIt.init();

  // Initialize services that need setup
  await getIt<StorageService>().init();
  await getIt<AuthService>().initialize();
}

// Services are registered with @LazySingleton or @Singleton decorators
```

## Best Practices & Rules

### ✅ Model Layer DO's:

- Keep models as simple data containers
- Only include basic helper methods (copyWith, toJson, fromJson)
- Use simple computed properties (getters for derived values)
- Implement equality (Equatable or freezed)
- Keep serialization logic in models
- Use extensions for simple formatting helpers

### ✅ Service Layer DO's:

- Keep public API minimal - only expose what's needed
- Prefix all private methods with underscore (\_)
- Most services should have 3-5 public methods maximum
- Keep services focused on a single responsibility
- Make services testable with dependency injection
- Return immutable results when possible
- Handle all business rules in services
- Use Flutter features when helpful (compute, platform channels)

### ✅ Bloc Layer DO's:

- Use Blocs ONLY for UI state management
- Handle user interactions and UI events
- Coordinate service calls
- Manage UI-specific state (animations, selections, etc.)
- Handle loading/error states for UI
- Manage form state and validation display

### ❌ DON'Ts:

- **NEVER put business logic in Blocs**
- **NEVER put business logic in Models**
- **NEVER use StatefulWidget**
- Don't make Blocs dependent on each other
- Don't access services directly from widgets (go through Blocs)
- Don't mix UI concerns with business logic
- Don't create "God services" - keep them focused
- Don't put UI state in services
- Don't add complex methods to models - use services instead

## Common Claude Code Commands

```bash
# Model creation (thin)
"Create a User model with properties and basic helpers only - no business logic"

# Service creation (business logic)
"Create a UserService that handles user validation, permissions, and business rules"

# Bloc for UI coordination
"Create a UserProfileBloc that uses UserService and handles UI state"

# Refactoring
"Extract business logic from this model into a service"
"Move validation logic from this Bloc into appropriate service"

# Testing
"Write tests for UserService business logic"
"Test the User model's serialization and equality"

# Architecture check
"Review this code and identify any business logic that should be moved to services"
```

## Example: Complete Feature Implementation

```dart
// 1. Service (Pure Business Logic)
@injectable
class CheckoutService {
  final InventoryService _inventory;
  final PricingService _pricing;
  final PaymentService _payment;

  CheckoutService(this._inventory, this._pricing, this._payment);

  CheckoutResult processCheckout(Cart cart, PaymentMethod method) {
    // Check inventory
    final availability = _inventory.checkAvailability(cart.items);
    if (!availability.allAvailable) {
      return CheckoutResult.unavailable(availability.unavailableItems);
    }

    // Calculate pricing
    final pricing = _pricing.calculateTotal(cart);

    // Process payment
    final paymentResult = _payment.process(pricing.total, method);

    if (paymentResult.success) {
      _inventory.reduceStock(cart.items);
      return CheckoutResult.success(
        orderId: generateOrderId(),
        total: pricing.total,
      );
    }

    return CheckoutResult.paymentFailed(paymentResult.error);
  }
}

// 2. Bloc (UI Coordination Only)
@injectable
class CheckoutUIBloc extends Bloc<CheckoutUIEvent, CheckoutUIState> {
  final CheckoutService _checkoutService;

  CheckoutUIBloc(this._checkoutService) : super(CheckoutUIInitial()) {
    on<StartCheckout>(_onStartCheckout);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
    on<ConfirmCheckout>(_onConfirmCheckout);
  }

  void _onStartCheckout(StartCheckout event, Emitter<CheckoutUIState> emit) {
    emit(CheckoutUIReady(
      cart: event.cart,
      selectedPayment: null,
      isProcessing: false,
      showPaymentOptions: true,
    ));
  }

  void _onConfirmCheckout(
    ConfirmCheckout event,
    Emitter<CheckoutUIState> emit
  ) async {
    final current = state as CheckoutUIReady;

    // Show loading UI
    emit(current.copyWith(isProcessing: true));

    // Service handles business logic
    final result = _checkoutService.processCheckout(
      current.cart,
      current.selectedPayment!,
    );

    // Update UI based on result
    if (result.success) {
      emit(CheckoutUISuccess(orderId: result.orderId));
    } else {
      emit(current.copyWith(
        isProcessing: false,
        errorMessage: result.error,
        showErrorDialog: true,
      ));
    }
  }
}

// 3. Can run without UI
void main() {
  final service = CheckoutService(...);
  final result = service.processCheckout(testCart, PaymentMethod.card);
  print('Checkout result: ${result.success}');
}
```

## Resources

- [Bloc Library Documentation](https://bloclibrary.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Domain-Driven Design](https://martinfowler.com/bliki/DomainDrivenDesign.html)
- [Hexagonal Architecture](https://alistair.cockburn.us/hexagonal-architecture/)
- [Flutter Clean Architecture Examples](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)
