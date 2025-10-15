import 'package:equatable/equatable.dart';

/// State for settings management
///
/// This is a placeholder implementation for the settings BLoC.
/// Future tasks will expand this with actual settings such as:
/// - Sound preferences (enabled/disabled, volume)
/// - Notification preferences
/// - Default AI difficulty
/// - Gameplay preferences (animation speed, etc.)
class SettingsState extends Equatable {
  final bool isInitialized;
  final bool isLoading;

  const SettingsState({this.isInitialized = false, this.isLoading = false});

  SettingsState copyWith({bool? isInitialized, bool? isLoading}) {
    return SettingsState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [isInitialized, isLoading];
}
