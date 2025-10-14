import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/game_mode.dart';

/// A reusable Material 3 button widget for game mode selection
///
/// Displays a large, tappable button with:
/// - Icon representing the game mode
/// - Title text (mode display name)
/// - Subtitle text (mode description)
/// - Optional highlight indicator for last played mode
/// - Minimum 56dp height for accessibility
///
/// Follows Material 3 design guidelines with proper touch targets,
/// visual hierarchy, and responsive layout.
class ModeSelectionButton extends StatelessWidget {
  /// The game mode this button represents
  final GameMode mode;

  /// Callback invoked when the button is tapped
  final VoidCallback onTap;

  /// Whether this mode was the last played mode (shows highlight)
  final bool isLastPlayed;

  const ModeSelectionButton({
    super.key,
    required this.mode,
    required this.onTap,
    this.isLastPlayed = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get icon based on mode
    final IconData icon = _getIconForMode(mode);

    return Semantics(
      button: true,
      label: '${mode.displayName} mode: ${mode.subtitle}',
      hint: isLastPlayed ? 'Last played mode' : null,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 80),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingL,
            vertical: AppTheme.spacingM,
          ),
          backgroundColor: isLastPlayed
              ? colorScheme.primaryContainer
              : colorScheme.secondaryContainer,
          foregroundColor: isLastPlayed
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSecondaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isLastPlayed
                ? BorderSide(color: colorScheme.primary, width: 2)
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: isLastPlayed
                    ? colorScheme.primary.withOpacity(0.1)
                    : colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isLastPlayed
                    ? colorScheme.primary
                    : colorScheme.secondary,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    mode.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isLastPlayed
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXs),

                  // Subtitle
                  Text(
                    mode.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isLastPlayed
                          ? colorScheme.onPrimaryContainer.withOpacity(0.8)
                          : colorScheme.onSecondaryContainer.withOpacity(0.8),
                    ),
                  ),

                  // Last played indicator
                  if (isLastPlayed) ...[
                    const SizedBox(height: AppTheme.spacingXs),
                    Row(
                      children: [
                        Icon(
                          Icons.history,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Last played',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: isLastPlayed
                  ? colorScheme.onPrimaryContainer.withOpacity(0.6)
                  : colorScheme.onSecondaryContainer.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns the appropriate icon for the given game mode
  IconData _getIconForMode(GameMode mode) {
    switch (mode) {
      case GameMode.vsAi:
        return Icons.smart_toy;
      case GameMode.twoPlayer:
        return Icons.people;
    }
  }
}
