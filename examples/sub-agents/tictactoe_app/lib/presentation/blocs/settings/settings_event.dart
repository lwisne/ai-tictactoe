import 'package:equatable/equatable.dart';

/// Base class for all Settings events
///
/// This is a placeholder implementation for the settings BLoC.
/// Future tasks will expand this with actual settings events such as:
/// - SoundSettingsChanged
/// - DifficultyPreferenceChanged
/// - NotificationSettingsChanged
/// - GameplaySettingsChanged
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize settings from saved preferences
class SettingsInitialized extends SettingsEvent {
  const SettingsInitialized();
}

/// Placeholder event for future settings logic
/// This demonstrates the event pattern and will be expanded in future tasks
class SettingsPlaceholderEvent extends SettingsEvent {
  const SettingsPlaceholderEvent();
}
