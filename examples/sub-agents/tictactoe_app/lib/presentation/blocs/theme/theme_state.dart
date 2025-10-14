import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../domain/models/theme_preference.dart';

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
