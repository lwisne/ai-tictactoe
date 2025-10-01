import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/settings_cubit.dart';
import '../models/settings.dart' as app_settings;

/// Settings page for configuring app preferences
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: BlocBuilder<SettingsCubit, app_settings.Settings>(
        builder: (context, settings) {
          return ListView(
            children: [
              _buildSectionHeader('Audio'),
              SwitchListTile(
                title: const Text('Sound Effects'),
                subtitle: const Text('Enable game sound effects'),
                value: settings.soundEnabled,
                onChanged: (_) =>
                    context.read<SettingsCubit>().toggleSound(),
              ),
              const Divider(),
              _buildSectionHeader('Appearance'),
              ListTile(
                title: const Text('Theme'),
                subtitle: Text(_getThemeModeText(settings.themeMode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeDialog(context, settings.themeMode),
              ),
              const Divider(),
              _buildSectionHeader('Gameplay'),
              ListTile(
                title: const Text('AI Difficulty'),
                subtitle: Text(_getAiDifficultyText(settings.aiDifficulty)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    _showAiDifficultyDialog(context, settings.aiDifficulty),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton(
                  onPressed: () => _showResetDialog(context),
                  child: const Text('Reset to Defaults'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  String _getThemeModeText(app_settings.ThemeMode mode) {
    switch (mode) {
      case app_settings.ThemeMode.light:
        return 'Light';
      case app_settings.ThemeMode.dark:
        return 'Dark';
      case app_settings.ThemeMode.system:
        return 'System Default';
    }
  }

  String _getAiDifficultyText(app_settings.AiDifficulty difficulty) {
    switch (difficulty) {
      case app_settings.AiDifficulty.easy:
        return 'Easy';
      case app_settings.AiDifficulty.medium:
        return 'Medium';
      case app_settings.AiDifficulty.hard:
        return 'Hard';
    }
  }

  void _showThemeDialog(
      BuildContext context, app_settings.ThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<app_settings.ThemeMode>(
              title: const Text('Light'),
              value: app_settings.ThemeMode.light,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsCubit>().setThemeMode(value);
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
            RadioListTile<app_settings.ThemeMode>(
              title: const Text('Dark'),
              value: app_settings.ThemeMode.dark,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsCubit>().setThemeMode(value);
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
            RadioListTile<app_settings.ThemeMode>(
              title: const Text('System Default'),
              value: app_settings.ThemeMode.system,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsCubit>().setThemeMode(value);
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAiDifficultyDialog(
      BuildContext context, app_settings.AiDifficulty currentDifficulty) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Choose AI Difficulty'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<app_settings.AiDifficulty>(
              title: const Text('Easy'),
              subtitle: const Text('AI makes frequent mistakes'),
              value: app_settings.AiDifficulty.easy,
              groupValue: currentDifficulty,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsCubit>().setAiDifficulty(value);
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
            RadioListTile<app_settings.AiDifficulty>(
              title: const Text('Medium'),
              subtitle: const Text('Balanced gameplay'),
              value: app_settings.AiDifficulty.medium,
              groupValue: currentDifficulty,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsCubit>().setAiDifficulty(value);
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
            RadioListTile<app_settings.AiDifficulty>(
              title: const Text('Hard'),
              subtitle: const Text('Unbeatable AI'),
              value: app_settings.AiDifficulty.hard,
              groupValue: currentDifficulty,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsCubit>().setAiDifficulty(value);
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to their default values?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<SettingsCubit>().resetSettings();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
