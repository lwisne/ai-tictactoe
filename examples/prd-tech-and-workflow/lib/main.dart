import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cubits/score_cubit.dart';
import 'cubits/settings_cubit.dart';
import 'models/settings.dart' as app_settings;
import 'pages/home_page.dart';
import 'services/score_service.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final settingsService = SettingsService(prefs);
  final scoreService = ScoreService(prefs);

  runApp(
    TicTacToeApp(settingsService: settingsService, scoreService: scoreService),
  );
}

class TicTacToeApp extends StatelessWidget {
  final SettingsService settingsService;
  final ScoreService scoreService;

  const TicTacToeApp({
    super.key,
    required this.settingsService,
    required this.scoreService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit(settingsService)),
        BlocProvider(create: (_) => ScoreCubit(scoreService)),
      ],
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
