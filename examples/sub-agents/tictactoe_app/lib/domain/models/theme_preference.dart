import 'package:equatable/equatable.dart';

/// Represents the user's theme preference
/// Maps to Flutter's ThemeMode: system, light, dark
enum ThemePreference {
  system,
  light,
  dark;

  /// Convert to JSON string for persistence
  String toJson() => name;

  /// Create from JSON string
  static ThemePreference fromJson(String json) {
    return ThemePreference.values.firstWhere(
      (e) => e.name == json,
      orElse: () => ThemePreference.system,
    );
  }
}

/// Model for theme settings
class ThemeSettings extends Equatable {
  final ThemePreference preference;

  const ThemeSettings({this.preference = ThemePreference.system});

  ThemeSettings copyWith({ThemePreference? preference}) {
    return ThemeSettings(preference: preference ?? this.preference);
  }

  Map<String, dynamic> toJson() {
    return {'preference': preference.toJson()};
  }

  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    return ThemeSettings(
      preference: ThemePreference.fromJson(
        json['preference'] as String? ?? 'system',
      ),
    );
  }

  @override
  List<Object?> get props => [preference];
}
