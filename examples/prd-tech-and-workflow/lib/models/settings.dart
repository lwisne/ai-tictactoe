import 'package:equatable/equatable.dart';

/// Application settings including sound, theme, and AI difficulty
class Settings extends Equatable {
  final bool soundEnabled;
  final ThemeMode themeMode;
  final AiDifficulty aiDifficulty;

  const Settings({
    required this.soundEnabled,
    required this.themeMode,
    required this.aiDifficulty,
  });

  /// Default settings
  factory Settings.defaults() {
    return const Settings(
      soundEnabled: true,
      themeMode: ThemeMode.system,
      aiDifficulty: AiDifficulty.medium,
    );
  }

  /// Create settings from JSON map
  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      aiDifficulty: AiDifficulty.values.firstWhere(
        (difficulty) => difficulty.name == json['aiDifficulty'],
        orElse: () => AiDifficulty.medium,
      ),
    );
  }

  /// Convert settings to JSON map
  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'themeMode': themeMode.name,
      'aiDifficulty': aiDifficulty.name,
    };
  }

  /// Create a copy with updated fields
  Settings copyWith({
    bool? soundEnabled,
    ThemeMode? themeMode,
    AiDifficulty? aiDifficulty,
  }) {
    return Settings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      themeMode: themeMode ?? this.themeMode,
      aiDifficulty: aiDifficulty ?? this.aiDifficulty,
    );
  }

  @override
  List<Object?> get props => [soundEnabled, themeMode, aiDifficulty];
}

/// Theme mode options
enum ThemeMode {
  light,
  dark,
  system,
}

/// AI difficulty levels
enum AiDifficulty {
  easy,
  medium,
  hard,
}
