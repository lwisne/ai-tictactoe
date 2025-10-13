import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/settings.dart';
import '../services/settings_service.dart';

/// Cubit for managing settings state
class SettingsCubit extends Cubit<Settings> {
  final SettingsService _settingsService;

  SettingsCubit(this._settingsService) : super(Settings.defaults()) {
    _loadSettings();
  }

  /// Load settings from storage
  void _loadSettings() {
    final settings = _settingsService.loadSettings();
    emit(settings);
  }

  /// Toggle sound enabled
  Future<void> toggleSound() async {
    final newSettings = state.copyWith(soundEnabled: !state.soundEnabled);
    emit(newSettings);
    await _settingsService.saveSettings(newSettings);
  }

  /// Update theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    final newSettings = state.copyWith(themeMode: mode);
    emit(newSettings);
    await _settingsService.saveSettings(newSettings);
  }

  /// Update AI difficulty
  Future<void> setAiDifficulty(AiDifficulty difficulty) async {
    final newSettings = state.copyWith(aiDifficulty: difficulty);
    emit(newSettings);
    await _settingsService.saveSettings(newSettings);
  }

  /// Reset settings to defaults
  Future<void> resetSettings() async {
    await _settingsService.clearSettings();
    emit(Settings.defaults());
  }
}
