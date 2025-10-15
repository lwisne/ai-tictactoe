import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/repositories/theme_repository.dart';
import '../../../domain/models/theme_preference.dart';
import 'theme_event.dart';
import 'theme_state.dart';

/// BLoC for managing theme preferences
/// Follows Clean Architecture - coordinates repository only, no business logic
/// Demonstrates the event/state pattern required by BLoC architecture
@injectable
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeRepository _themeRepository;

  ThemeBloc(this._themeRepository) : super(const ThemeState()) {
    // Register event handlers
    on<ThemeInitialized>(_onThemeInitialized);
    on<ThemeChanged>(_onThemeChanged);
    on<ThemeResetToSystem>(_onThemeResetToSystem);
  }

  /// Handle theme initialization
  Future<void> _onThemeInitialized(
    ThemeInitialized event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final settings = await _themeRepository.loadThemeSettings();
      emit(ThemeState(preference: settings.preference, isLoading: false));
    } catch (e) {
      // On error, use system default
      emit(const ThemeState(isLoading: false));
    }
  }

  /// Handle theme preference change
  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final settings = ThemeSettings(preference: event.preference);
      await _themeRepository.saveThemeSettings(settings);
      emit(ThemeState(preference: event.preference, isLoading: false));
    } catch (e) {
      // On error, revert to previous state
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Handle reset to system theme
  Future<void> _onThemeResetToSystem(
    ThemeResetToSystem event,
    Emitter<ThemeState> emit,
  ) async {
    // Delegate to ThemeChanged with system preference
    add(const ThemeChanged(ThemePreference.system));
  }
}
