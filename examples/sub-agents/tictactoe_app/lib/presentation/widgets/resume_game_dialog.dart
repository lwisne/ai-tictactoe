import 'package:flutter/material.dart';

/// Dialog shown when app detects a saved in-progress game
///
/// Gives user choice to resume the saved game or start fresh.
/// Returns true if user wants to resume, false if they want new game.
class ResumeGameDialog extends StatelessWidget {
  const ResumeGameDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Resume Game?'),
      content: const Text(
        'You have an in-progress game. Would you like to resume where you left off?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('New Game'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Resume'),
        ),
      ],
    );
  }

  /// Shows the resume game dialog
  ///
  /// Returns true if user wants to resume, false if they want new game.
  /// Returns false if dialog is dismissed without selection.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Force user to make a choice
      builder: (context) => const ResumeGameDialog(),
    );
    return result ?? false; // Default to new game if somehow dismissed
  }
}
