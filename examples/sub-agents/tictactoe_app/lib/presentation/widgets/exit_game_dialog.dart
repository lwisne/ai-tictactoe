import 'package:flutter/material.dart';

/// Material 3 confirmation dialog for exiting game
///
/// Displays a styled dialog asking user to confirm game exit.
/// This prevents accidental game exits and provides clear options.
///
/// Returns true if user confirms exit, false if user cancels.
class ExitGameDialog extends StatelessWidget {
  const ExitGameDialog({super.key});

  /// Shows the exit game dialog
  ///
  /// Returns Future<bool> - true if exit confirmed, false if cancelled
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must explicitly choose an option
      builder: (BuildContext dialogContext) => const ExitGameDialog(),
    );

    return result ?? false; // Default to false if dialog dismissed
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      icon: Icon(Icons.warning_rounded, color: colorScheme.error, size: 32),
      title: const Text('Exit Game?'),
      content: const Text(
        'Are you sure you want to exit the current game? '
        'Your progress will be lost.',
      ),
      actions: [
        // Cancel button - keep user in game
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        // Exit button - confirm exit and return to home
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          child: const Text('Exit'),
        ),
      ],
    );
  }
}
