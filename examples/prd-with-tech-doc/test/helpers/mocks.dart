import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_tac_toe/data/repositories/score_repository.dart';
import 'package:tic_tac_toe/domain/services/ai_service.dart';
import 'package:tic_tac_toe/domain/services/game_service.dart';

// Service mocks
class MockGameService extends Mock implements GameService {}

class MockAiService extends Mock implements AiService {}

// Repository mocks
class MockScoreRepository extends Mock implements ScoreRepository {}

// External dependency mocks
class MockSharedPreferences extends Mock implements SharedPreferences {}

// Register fallback values for custom types
void registerFallbackValues() {
  // This ensures mocktail can handle our custom types when using any()
  // Add any custom types here as needed
}
