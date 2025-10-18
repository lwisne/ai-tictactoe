import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// AI Difficulty Selection page with standard back button behavior
///
/// As specified in LWI-151, this page should have a back button that returns
/// to the previous screen (home) without confirmation.
/// As specified in LWI-168, Medium difficulty has a "Recommended" badge.
class AiDifficultyPage extends StatelessWidget {
  const AiDifficultyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select AI Difficulty'),
        // Standard back button - automatically provided by Flutter
        // Uses go_router's navigation when pressed
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology, size: 100, color: Colors.purple),
            const SizedBox(height: 24),
            const Text(
              'AI Difficulty Selection',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose your challenge level',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            // Difficulty selection buttons that will navigate to game
            ElevatedButton(
              onPressed: () {
                context.go('/game');
              },
              child: const Text('Easy'),
            ),
            const SizedBox(height: 16),
            // Medium difficulty with "Recommended" badge (LWI-168)
            _DifficultyButtonWithBadge(
              onPressed: () {
                context.go('/game');
              },
              label: 'Medium',
              showRecommendedBadge: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.go('/game');
              },
              child: const Text('Hard'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Difficulty button with optional "Recommended" badge
///
/// Displays an ElevatedButton with an optional chip badge positioned
/// at the top-right corner. The badge uses Material 3 design and
/// includes accessibility labels.
class _DifficultyButtonWithBadge extends StatelessWidget {
  const _DifficultyButtonWithBadge({
    required this.onPressed,
    required this.label,
    this.showRecommendedBadge = false,
  });

  final VoidCallback onPressed;
  final String label;
  final bool showRecommendedBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!showRecommendedBadge) {
      return ElevatedButton(onPressed: onPressed, child: Text(label));
    }

    // Button with badge - use Stack for positioning
    return Semantics(
      label: '$label difficulty (Recommended)',
      button: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ElevatedButton(onPressed: onPressed, child: Text(label)),
          // Badge positioned at top-right
          Positioned(
            top: -8,
            right: -8,
            child: Tooltip(
              message:
                  'Best balance of challenge and enjoyment for most players',
              child: Semantics(
                label: 'Recommended difficulty level',
                child: Chip(
                  label: const Text(
                    'Recommended',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: colorScheme.primaryContainer,
                  labelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
