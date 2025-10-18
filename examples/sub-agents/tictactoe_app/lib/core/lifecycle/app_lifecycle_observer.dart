import 'package:flutter/material.dart';

/// Observer for app lifecycle state changes
///
/// Monitors when app is paused, resumed, detached, etc.
/// and triggers callbacks for persistence logic.
///
/// This is a core utility with no business logic.
class AppLifecycleObserver extends WidgetsBindingObserver {
  /// Callback when app is paused (backgrounded)
  final VoidCallback? onPaused;

  /// Callback when app is resumed (foregrounded)
  final VoidCallback? onResumed;

  /// Callback when app is detached (about to be killed)
  final VoidCallback? onDetached;

  AppLifecycleObserver({this.onPaused, this.onResumed, this.onDetached});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        // App moved to background - save state
        onPaused?.call();
        break;
      case AppLifecycleState.resumed:
        // App returned to foreground
        onResumed?.call();
        break;
      case AppLifecycleState.detached:
        // App is about to be killed - final save
        onDetached?.call();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // Transitional states - no action needed
        break;
    }
  }

  /// Registers this observer with the WidgetsBinding
  void register() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Unregisters this observer from the WidgetsBinding
  void unregister() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
