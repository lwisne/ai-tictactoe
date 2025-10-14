import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/repositories/theme_repository.dart';
import '../../domain/models/theme_preference.dart';

/// State for theme management
class ThemeState extends Equatable {
  final ThemePreference preference;
  final bool isLoading;

  const ThemeState({
    this.preference = ThemePreference.system,
    this.isLoading = false,
  });

  /// Convert ThemePreference to Flutter's ThemeMode
  ThemeMode get themeMode {
    switch (preference) {
      case ThemePreference.system:
        return ThemeMode.system;
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
    }
  }

  ThemeState copyWith({ThemePreference? preference, bool? isLoading}) {
    return ThemeState(
      preference: preference ?? this.preference,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [preference, isLoading];
}

/// Cubit for managing theme preferences
/// Follows Clean Architecture - coordinates repository only, no business logic
@injectable
class ThemeCubit extends Cubit<ThemeState> {
  final ThemeRepository _themeRepository;

  ThemeCubit(this._themeRepository) : super(const ThemeState());

  /// Initialize theme from saved preferences
  Future<void> initializeTheme() async {
    emit(state.copyWith(isLoading: true));

    try {
      final settings = await _themeRepository.loadThemeSettings();
      emit(ThemeState(preference: settings.preference, isLoading: false));
    } catch (e) {
      // On error, use system default
      emit(const ThemeState(isLoading: false));
    }
  }

  /// Change theme preference and persist it
  Future<void> setThemePreference(ThemePreference preference) async {
    emit(state.copyWith(isLoading: true));

    try {
      final settings = ThemeSettings(preference: preference);
      await _themeRepository.saveThemeSettings(settings);
      emit(ThemeState(preference: preference, isLoading: false));
    } catch (e) {
      // On error, revert to previous state
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Reset theme to system default
  Future<void> resetToSystem() async {
    await setThemePreference(ThemePreference.system);
  }
}
