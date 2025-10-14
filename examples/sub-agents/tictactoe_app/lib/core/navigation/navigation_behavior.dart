import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navigation behavior utilities for consistent back button handling
///
/// Provides centralized logic for navigation patterns including:
/// - Standard back navigation
/// - Conditional back navigation with confirmations
/// - Home navigation
class NavigationBehavior {
  // Private constructor to prevent instantiation
  NavigationBehavior._();

  /// Handles standard back navigation
  ///
  /// Uses go_router's context.pop() for proper navigation stack management
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }

  /// Navigates to the home screen
  ///
  /// Uses go_router's context.go() to replace current route
  static void goHome(BuildContext context) {
    context.go('/');
  }

  /// Determines if back navigation is allowed
  ///
  /// Checks if there are routes to pop in the navigation stack
  static bool canNavigateBack(BuildContext context) {
    return context.canPop();
  }

  /// Shows a Material 3 confirmation dialog
  ///
  /// Returns true if user confirms, false if user cancels
  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required String cancelText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(cancelText),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  /// Shows exit game confirmation dialog
  ///
  /// Returns true if user wants to exit, false to stay in game
  static Future<bool> showExitGameConfirmation(BuildContext context) async {
    return showConfirmationDialog(
      context: context,
      title: 'Exit Game?',
      content:
          'Are you sure you want to exit the current game? '
          'Your progress will be lost.',
      confirmText: 'Exit',
      cancelText: 'Cancel',
    );
  }
}
