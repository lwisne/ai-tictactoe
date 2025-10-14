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

      test('should have PRD-specified primary color (Blue 600)', () {
        final theme = AppTheme.lightTheme;
        expect(theme.colorScheme.primary, const Color(0xFF1E88E5));
      });

      test('should have PRD-specified secondary color (Amber 600)', () {
        final theme = AppTheme.lightTheme;
        expect(theme.colorScheme.secondary, const Color(0xFFFFB300));
      });

      test('should have PRD-specified surface background', () {
        final theme = AppTheme.lightTheme;
        expect(theme.colorScheme.surface, const Color(0xFFFAFAFA));
      });

      test('should have PRD-specified text color', () {
        final theme = AppTheme.lightTheme;
        expect(theme.colorScheme.onSurface, const Color(0xFF111111));
      });

      test('should have centered AppBar title', () {
        final theme = AppTheme.lightTheme;
        expect(theme.appBarTheme.centerTitle, isTrue);
      });

      test('should have zero AppBar elevation', () {
        final theme = AppTheme.lightTheme;
        expect(theme.appBarTheme.elevation, 0);
      });

      test('should have proper AppBar colors', () {
        final theme = AppTheme.lightTheme;
        expect(theme.appBarTheme.backgroundColor, const Color(0xFFFAFAFA));
        expect(theme.appBarTheme.foregroundColor, const Color(0xFF111111));
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

      test('should have lighter primary color for dark mode', () {
        final theme = AppTheme.darkTheme;
        expect(theme.colorScheme.primary, const Color(0xFF90CAF9));
      });

      test('should have lighter secondary color for dark mode', () {
        final theme = AppTheme.darkTheme;
        expect(theme.colorScheme.secondary, const Color(0xFFFFD54F));
      });

      test('should have PRD-specified dark surface background', () {
        final theme = AppTheme.darkTheme;
        expect(theme.colorScheme.surface, const Color(0xFF121212));
      });

      test('should have light text on dark background', () {
        final theme = AppTheme.darkTheme;
        expect(theme.colorScheme.onSurface, const Color(0xFFE6E1E5));
      });

      test('should have centered AppBar title', () {
        final theme = AppTheme.darkTheme;
        expect(theme.appBarTheme.centerTitle, isTrue);
      });

      test('should have zero AppBar elevation', () {
        final theme = AppTheme.darkTheme;
        expect(theme.appBarTheme.elevation, 0);
      });

      test('should have proper AppBar colors', () {
        final theme = AppTheme.darkTheme;
        expect(theme.appBarTheme.backgroundColor, const Color(0xFF121212));
        expect(theme.appBarTheme.foregroundColor, const Color(0xFFE6E1E5));
      });
    });

    group('Typography', () {
      test('should have Display Large at 32sp (PRD requirement)', () {
        final theme = AppTheme.lightTheme;
        expect(theme.textTheme.displayLarge?.fontSize, 32);
        expect(theme.textTheme.displayLarge?.fontWeight, FontWeight.bold);
      });

      test('should have Title Large at 24sp', () {
        final theme = AppTheme.lightTheme;
        expect(theme.textTheme.titleLarge?.fontSize, 24);
        expect(theme.textTheme.titleLarge?.fontWeight, FontWeight.w600);
      });

      test('should have Title Medium at 18sp (Subtitle)', () {
        final theme = AppTheme.lightTheme;
        expect(theme.textTheme.titleMedium?.fontSize, 18);
        expect(theme.textTheme.titleMedium?.fontWeight, FontWeight.w600);
      });

      test('should have Body Large at 16sp', () {
        final theme = AppTheme.lightTheme;
        expect(theme.textTheme.bodyLarge?.fontSize, 16);
        expect(theme.textTheme.bodyLarge?.fontWeight, FontWeight.normal);
      });

      test('should have Label Large at 14sp (Caption)', () {
        final theme = AppTheme.lightTheme;
        expect(theme.textTheme.labelLarge?.fontSize, 14);
        expect(theme.textTheme.labelLarge?.fontWeight, FontWeight.w500);
      });

      test('should have consistent typography across themes', () {
        final lightTheme = AppTheme.lightTheme;
        final darkTheme = AppTheme.darkTheme;

        expect(
          lightTheme.textTheme.displayLarge?.fontSize,
          darkTheme.textTheme.displayLarge?.fontSize,
        );
        expect(
          lightTheme.textTheme.titleLarge?.fontSize,
          darkTheme.textTheme.titleLarge?.fontSize,
        );
        expect(
          lightTheme.textTheme.bodyLarge?.fontSize,
          darkTheme.textTheme.bodyLarge?.fontSize,
        );
      });
    });

    group('Component Themes', () {
      test('should have Card theme configured', () {
        final theme = AppTheme.lightTheme;
        expect(theme.cardTheme.elevation, 1);
        expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
        expect(theme.cardTheme.margin, const EdgeInsets.all(8));
      });

      test('should have Button themes configured', () {
        final theme = AppTheme.lightTheme;
        expect(theme.elevatedButtonTheme, isNotNull);
        expect(theme.filledButtonTheme, isNotNull);
        expect(theme.textButtonTheme, isNotNull);
      });

      test('should have Input Decoration theme configured', () {
        final theme = AppTheme.lightTheme;
        expect(theme.inputDecorationTheme.filled, isTrue);
        expect(theme.inputDecorationTheme.border, isA<OutlineInputBorder>());
      });

      test('should have Icon theme configured', () {
        final theme = AppTheme.lightTheme;
        expect(theme.iconTheme.size, 24);
        expect(theme.iconTheme.color, const Color(0xFF111111));
      });

      test('should have Divider theme configured', () {
        final theme = AppTheme.lightTheme;
        expect(theme.dividerTheme.thickness, 1);
        expect(theme.dividerTheme.space, 16);
      });
    });

    group('Accessibility & Contrast', () {
      test('light theme primary color should contrast with onPrimary', () {
        final theme = AppTheme.lightTheme;
        // Primary is blue, onPrimary should be white for good contrast
        expect(theme.colorScheme.onPrimary, Colors.white);
      });

      test('light theme secondary color should contrast with onSecondary', () {
        final theme = AppTheme.lightTheme;
        // Secondary is amber, onSecondary should be black for good contrast
        expect(theme.colorScheme.onSecondary, Colors.black);
      });

      test('dark theme should have appropriate contrast', () {
        final theme = AppTheme.darkTheme;
        // Dark primary (light blue) should have dark onPrimary
        expect(theme.colorScheme.onPrimary, const Color(0xFF003258));
      });

      test('error colors should have proper contrast', () {
        final lightTheme = AppTheme.lightTheme;
        expect(lightTheme.colorScheme.onError, Colors.white);

        final darkTheme = AppTheme.darkTheme;
        expect(darkTheme.colorScheme.onError, isNotNull);
      });
    });

    group('Spacing Constants', () {
      test('should have base spacing unit of 8dp', () {
        expect(AppTheme.spacingUnit, 8.0);
      });

      test('should have correct spacing multiples', () {
        expect(AppTheme.spacingXs, 4.0);
        expect(AppTheme.spacingS, 8.0);
        expect(AppTheme.spacingM, 16.0);
        expect(AppTheme.spacingL, 24.0);
        expect(AppTheme.spacingXl, 32.0);
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

      test('both themes should have complete color schemes', () {
        final lightColors = AppTheme.lightTheme.colorScheme;
        final darkColors = AppTheme.darkTheme.colorScheme;

        // Verify all critical colors are defined
        expect(lightColors.primary, isNotNull);
        expect(lightColors.secondary, isNotNull);
        expect(lightColors.error, isNotNull);
        expect(lightColors.surface, isNotNull);

        expect(darkColors.primary, isNotNull);
        expect(darkColors.secondary, isNotNull);
        expect(darkColors.error, isNotNull);
        expect(darkColors.surface, isNotNull);
      });
    });

    group('Material 3 Color System', () {
      test('should have primary container colors', () {
        final lightTheme = AppTheme.lightTheme;
        expect(lightTheme.colorScheme.primaryContainer, isNotNull);
        expect(lightTheme.colorScheme.onPrimaryContainer, isNotNull);
      });

      test('should have secondary container colors', () {
        final lightTheme = AppTheme.lightTheme;
        expect(lightTheme.colorScheme.secondaryContainer, isNotNull);
        expect(lightTheme.colorScheme.onSecondaryContainer, isNotNull);
      });

      test('should have error container colors', () {
        final lightTheme = AppTheme.lightTheme;
        expect(lightTheme.colorScheme.errorContainer, isNotNull);
        expect(lightTheme.colorScheme.onErrorContainer, isNotNull);
      });

      test('should have outline colors', () {
        final lightTheme = AppTheme.lightTheme;
        expect(lightTheme.colorScheme.outline, isNotNull);
        expect(lightTheme.colorScheme.outlineVariant, isNotNull);
      });

      test('should have inverse colors', () {
        final lightTheme = AppTheme.lightTheme;
        expect(lightTheme.colorScheme.inverseSurface, isNotNull);
        expect(lightTheme.colorScheme.onInverseSurface, isNotNull);
        expect(lightTheme.colorScheme.inversePrimary, isNotNull);
      });
    });
  });
}
