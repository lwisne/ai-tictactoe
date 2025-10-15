import 'package:equatable/equatable.dart';

import '../../../domain/models/theme_preference.dart';

/// Base class for all Theme events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize theme from saved preferences
class ThemeInitialized extends ThemeEvent {
  const ThemeInitialized();
}

/// Event to change the theme preference
class ThemeChanged extends ThemeEvent {
  final ThemePreference preference;

  const ThemeChanged(this.preference);

  @override
  List<Object?> get props => [preference];
}

/// Event to reset theme to system default
class ThemeResetToSystem extends ThemeEvent {
  const ThemeResetToSystem();
}
