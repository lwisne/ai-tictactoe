import 'package:flutter/material.dart';

/// Material 3 theme configuration following PRD design specifications
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Design Token Colors - Per PRD Specifications
  static const Color _primaryBlue = Color(0xFF1E88E5); // Blue 600
  static const Color _secondaryAmber = Color(0xFFFFB300); // Amber 600
  static const Color _surfaceLightBackground = Color(0xFFFAFAFA);
  static const Color _surfaceDarkBackground = Color(0xFF121212);
  static const Color _textPrimaryLight = Color(0xFF111111);

  // Spacing Constants - Base unit 8dp
  static const double spacingUnit = 8.0;
  static const double spacingXs = spacingUnit * 0.5; // 4dp
  static const double spacingS = spacingUnit; // 8dp
  static const double spacingM = spacingUnit * 2; // 16dp
  static const double spacingL = spacingUnit * 3; // 24dp
  static const double spacingXl = spacingUnit * 4; // 32dp

  // Light Color Scheme
  static ColorScheme get _lightColorScheme {
    return ColorScheme.light(
      primary: _primaryBlue,
      onPrimary: Colors.white,
      // Material 3 standard for container colors is 12% opacity
      primaryContainer: _primaryBlue.withOpacity(0.12),
      onPrimaryContainer: const Color(0xFF001D36),
      secondary: _secondaryAmber,
      onSecondary: Colors.black,
      // Material 3 standard for container colors is 12% opacity
      secondaryContainer: _secondaryAmber.withOpacity(0.12),
      onSecondaryContainer: const Color(0xFF2A1800),
      surface: _surfaceLightBackground,
      onSurface: _textPrimaryLight,
      error: const Color(0xFFB3261E),
      onError: Colors.white,
      errorContainer: const Color(0xFFF9DEDC),
      onErrorContainer: const Color(0xFF410E0B),
      outline: const Color(0xFF79747E),
      outlineVariant: const Color(0xFFCAC4D0),
      shadow: Colors.black,
      inverseSurface: const Color(0xFF313033),
      onInverseSurface: const Color(0xFFF4EFF4),
      inversePrimary: const Color(0xFF90CAF9),
    );
  }

  // Dark Color Scheme
  static ColorScheme get _darkColorScheme {
    return ColorScheme.dark(
      primary: const Color(0xFF90CAF9), // Lighter blue for dark mode
      onPrimary: const Color(0xFF003258),
      primaryContainer: const Color(0xFF004A77),
      onPrimaryContainer: const Color(0xFFCAE6FF),
      secondary: const Color(0xFFFFD54F), // Lighter amber for dark mode
      onSecondary: const Color(0xFF3E2D00),
      secondaryContainer: _secondaryAmber,
      onSecondaryContainer: const Color(0xFFFFECC2),
      surface: _surfaceDarkBackground,
      onSurface: const Color(0xFFE6E1E5),
      error: const Color(0xFFF2B8B5),
      onError: const Color(0xFF601410),
      errorContainer: const Color(0xFF8C1D18),
      onErrorContainer: const Color(0xFFF9DEDC),
      outline: const Color(0xFF938F99),
      outlineVariant: const Color(0xFF49454F),
      shadow: Colors.black,
      inverseSurface: const Color(0xFFE6E1E5),
      onInverseSurface: const Color(0xFF313033),
      inversePrimary: _primaryBlue,
    );
  }

  // Typography Theme - Per PRD Specifications
  static TextTheme get _textTheme {
    return const TextTheme(
      // Display Large - 32sp (Turn indicators, major headings)
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
        height: 1.25,
      ),
      // Display Medium - 28sp
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
        height: 1.29,
      ),
      // Display Small - 24sp
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
        height: 1.33,
      ),
      // Title Large - 24sp (Page titles)
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.33,
      ),
      // Title Medium - 18sp (Subtitles)
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.33,
      ),
      // Title Small - 16sp
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.5,
      ),
      // Body Large - 16sp (Main body text)
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.5,
        height: 1.5,
      ),
      // Body Medium - 14sp
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      // Body Small - 12sp
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.4,
        height: 1.33,
      ),
      // Label Large - 14sp (Caption text)
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      // Label Medium - 12sp
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      // Label Small - 11sp
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      textTheme: _textTheme,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: _surfaceLightBackground,
        foregroundColor: _textPrimaryLight,
        titleTextStyle: _textTheme.titleLarge?.copyWith(
          color: _textPrimaryLight,
        ),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.all(spacingS),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: _textTheme.labelLarge,
        ),
      ),

      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: _textTheme.labelLarge,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: spacingM,
            vertical: spacingS,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: _textTheme.labelLarge,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceLightBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF79747E)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF79747E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFB3261E)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFB3261E), width: 2),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        space: spacingM,
        thickness: 1,
        color: Color(0xFFCAC4D0),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: _textPrimaryLight, size: 24),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _darkColorScheme,
      textTheme: _textTheme,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: _surfaceDarkBackground,
        foregroundColor: const Color(0xFFE6E1E5),
        titleTextStyle: _textTheme.titleLarge?.copyWith(
          color: const Color(0xFFE6E1E5),
        ),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.all(spacingS),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: _textTheme.labelLarge,
        ),
      ),

      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: _textTheme.labelLarge,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: spacingM,
            vertical: spacingS,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: _textTheme.labelLarge,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1C1B1F),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF938F99)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF938F99)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF90CAF9), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFF2B8B5)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFF2B8B5), width: 2),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        space: spacingM,
        thickness: 1,
        color: Color(0xFF49454F),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: Color(0xFFE6E1E5), size: 24),
    );
  }
}
