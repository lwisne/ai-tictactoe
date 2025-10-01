import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cubits/settings_cubit.dart';
import 'models/settings.dart' as app_settings;
import 'pages/home_page.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final settingsService = SettingsService(prefs);

  runApp(TicTacToeApp(settingsService: settingsService));
}

class TicTacToeApp extends StatelessWidget {
  final SettingsService settingsService;

  const TicTacToeApp({
    super.key,
    required this.settingsService,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(settingsService),
      child: BlocBuilder<SettingsCubit, app_settings.Settings>(
        builder: (context, settings) {
          return MaterialApp(
            title: 'Tic-Tac-Toe',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: _mapThemeMode(settings.themeMode),
            home: const HomePage(),
          );
        },
      ),
    );
  }

  ThemeMode _mapThemeMode(app_settings.ThemeMode mode) {
    switch (mode) {
      case app_settings.ThemeMode.light:
        return ThemeMode.light;
      case app_settings.ThemeMode.dark:
        return ThemeMode.dark;
      case app_settings.ThemeMode.system:
        return ThemeMode.system;
    }
  }
}
