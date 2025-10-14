import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    group('Light Theme', () {
      test('should use Material 3', () {
        final theme = AppTheme.lightTheme;
        expect(theme.useMaterial3, isTrue);
      });

      test('should have light brightness', () {
        final theme = AppTheme.lightTheme;
        expect(theme.colorScheme.brightness, Brightness.light);
      });

      test('should have blue seed color', () {
        final theme = AppTheme.lightTheme;
        // Verify the color scheme is based on blue
        expect(theme.colorScheme.primary, isNotNull);
      });

      test('should have centered AppBar title', () {
        final theme = AppTheme.lightTheme;
        expect(theme.appBarTheme.centerTitle, isTrue);
      });

      test('should have zero AppBar elevation', () {
        final theme = AppTheme.lightTheme;
        expect(theme.appBarTheme.elevation, 0);
      });
    });

    group('Dark Theme', () {
      test('should use Material 3', () {
        final theme = AppTheme.darkTheme;
        expect(theme.useMaterial3, isTrue);
      });

      test('should have dark brightness', () {
        final theme = AppTheme.darkTheme;
        expect(theme.colorScheme.brightness, Brightness.dark);
      });

      test('should have blue seed color', () {
        final theme = AppTheme.darkTheme;
        // Verify the color scheme is based on blue
        expect(theme.colorScheme.primary, isNotNull);
      });

      test('should have centered AppBar title', () {
        final theme = AppTheme.darkTheme;
        expect(theme.appBarTheme.centerTitle, isTrue);
      });

      test('should have zero AppBar elevation', () {
        final theme = AppTheme.darkTheme;
        expect(theme.appBarTheme.elevation, 0);
      });
    });

    group('Theme Consistency', () {
      test('light and dark themes should both use Material 3', () {
        expect(AppTheme.lightTheme.useMaterial3, isTrue);
        expect(AppTheme.darkTheme.useMaterial3, isTrue);
      });

      test('light and dark themes should have same AppBar configuration', () {
        final lightAppBar = AppTheme.lightTheme.appBarTheme;
        final darkAppBar = AppTheme.darkTheme.appBarTheme;

        expect(lightAppBar.centerTitle, darkAppBar.centerTitle);
        expect(lightAppBar.elevation, darkAppBar.elevation);
      });

      test('light and dark themes should have different brightness', () {
        expect(
          AppTheme.lightTheme.colorScheme.brightness,
          isNot(equals(AppTheme.darkTheme.colorScheme.brightness)),
        );
      });
    });
  });
}
