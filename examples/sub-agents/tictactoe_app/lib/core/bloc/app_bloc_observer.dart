import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

/// Custom BlocObserver for debugging and logging BLoC events and state changes
///
/// This observer provides comprehensive logging for:
/// - BLoC creation and closure
/// - Event dispatching
/// - State transitions
/// - Error handling
///
/// Logs are sent to the developer console for debugging purposes.
class AppBlocObserver extends BlocObserver {
  /// Whether to enable verbose logging (useful for debugging)
  final bool enableVerboseLogging;

  const AppBlocObserver({this.enableVerboseLogging = true});

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    if (enableVerboseLogging) {
      developer.log('onCreate -- ${bloc.runtimeType}', name: 'BlocObserver');
    }
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (enableVerboseLogging) {
      developer.log(
        'onEvent -- ${bloc.runtimeType}\n'
        'Event: ${event.runtimeType}\n'
        'Details: $event',
        name: 'BlocObserver',
      );
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (enableVerboseLogging) {
      developer.log(
        'onChange -- ${bloc.runtimeType}\n'
        'CurrentState: ${change.currentState.runtimeType}\n'
        'NextState: ${change.nextState.runtimeType}',
        name: 'BlocObserver',
      );
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (enableVerboseLogging) {
      developer.log(
        'onTransition -- ${bloc.runtimeType}\n'
        'Event: ${transition.event.runtimeType}\n'
        'CurrentState: ${transition.currentState.runtimeType}\n'
        'NextState: ${transition.nextState.runtimeType}',
        name: 'BlocObserver',
      );
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    developer.log(
      'onError -- ${bloc.runtimeType}\n'
      'Error: $error\n'
      'StackTrace: $stackTrace',
      name: 'BlocObserver',
      error: error,
      stackTrace: stackTrace,
      level: 1000, // Error level
    );
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    if (enableVerboseLogging) {
      developer.log('onClose -- ${bloc.runtimeType}', name: 'BlocObserver');
    }
  }
}
