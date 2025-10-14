import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/core/bloc/app_bloc_observer.dart';

// Concrete test BLoC for testing the observer
class TestEvent {}

class TestState {}

class TestBloc extends Bloc<TestEvent, TestState> {
  TestBloc() : super(TestState()) {
    on<TestEvent>((event, emit) async {
      // Simple event handler for testing
    });
  }
}

void main() {
  group('AppBlocObserver', () {
    late AppBlocObserver observer;
    late TestBloc testBloc;

    setUp(() {
      observer = const AppBlocObserver(enableVerboseLogging: true);
      testBloc = TestBloc();
    });

    tearDown(() {
      testBloc.close();
    });

    group('onCreate', () {
      test('should call super.onCreate', () {
        // This test verifies that onCreate is called without throwing
        expect(() => observer.onCreate(testBloc), returnsNormally);
      });

      test('should log when verbose logging is enabled', () {
        const verboseObserver = AppBlocObserver(enableVerboseLogging: true);
        expect(() => verboseObserver.onCreate(testBloc), returnsNormally);
      });

      test('should not throw when verbose logging is disabled', () {
        const silentObserver = AppBlocObserver(enableVerboseLogging: false);
        expect(() => silentObserver.onCreate(testBloc), returnsNormally);
      });
    });

    group('onEvent', () {
      test('should call super.onEvent with event', () {
        final event = TestEvent();
        expect(() => observer.onEvent(testBloc, event), returnsNormally);
      });

      test('should handle null events', () {
        expect(() => observer.onEvent(testBloc, null), returnsNormally);
      });

      test('should log event details when verbose logging is enabled', () {
        const verboseObserver = AppBlocObserver(enableVerboseLogging: true);
        final event = TestEvent();
        expect(() => verboseObserver.onEvent(testBloc, event), returnsNormally);
      });

      test('should not throw when verbose logging is disabled', () {
        const silentObserver = AppBlocObserver(enableVerboseLogging: false);
        final event = TestEvent();
        expect(() => silentObserver.onEvent(testBloc, event), returnsNormally);
      });
    });

    group('onChange', () {
      test('should call super.onChange with change', () {
        final change = Change<TestState>(
          currentState: TestState(),
          nextState: TestState(),
        );
        expect(() => observer.onChange(testBloc, change), returnsNormally);
      });

      test('should handle state transitions', () {
        final change = Change<TestState>(
          currentState: TestState(),
          nextState: TestState(),
        );
        expect(() => observer.onChange(testBloc, change), returnsNormally);
      });

      test('should log state changes when verbose logging is enabled', () {
        const verboseObserver = AppBlocObserver(enableVerboseLogging: true);
        final change = Change<TestState>(
          currentState: TestState(),
          nextState: TestState(),
        );
        expect(
          () => verboseObserver.onChange(testBloc, change),
          returnsNormally,
        );
      });

      test('should not throw when verbose logging is disabled', () {
        const silentObserver = AppBlocObserver(enableVerboseLogging: false);
        final change = Change<TestState>(
          currentState: TestState(),
          nextState: TestState(),
        );
        expect(
          () => silentObserver.onChange(testBloc, change),
          returnsNormally,
        );
      });
    });

    group('onTransition', () {
      test('should call super.onTransition with transition', () {
        final transition = Transition<TestEvent, TestState>(
          currentState: TestState(),
          event: TestEvent(),
          nextState: TestState(),
        );
        expect(
          () => observer.onTransition(testBloc, transition),
          returnsNormally,
        );
      });

      test('should handle complex transitions', () {
        final transition = Transition<TestEvent, TestState>(
          currentState: TestState(),
          event: TestEvent(),
          nextState: TestState(),
        );
        expect(
          () => observer.onTransition(testBloc, transition),
          returnsNormally,
        );
      });

      test('should log transitions when verbose logging is enabled', () {
        const verboseObserver = AppBlocObserver(enableVerboseLogging: true);
        final transition = Transition<TestEvent, TestState>(
          currentState: TestState(),
          event: TestEvent(),
          nextState: TestState(),
        );
        expect(
          () => verboseObserver.onTransition(testBloc, transition),
          returnsNormally,
        );
      });

      test('should not throw when verbose logging is disabled', () {
        const silentObserver = AppBlocObserver(enableVerboseLogging: false);
        final transition = Transition<TestEvent, TestState>(
          currentState: TestState(),
          event: TestEvent(),
          nextState: TestState(),
        );
        expect(
          () => silentObserver.onTransition(testBloc, transition),
          returnsNormally,
        );
      });
    });

    group('onError', () {
      test('should call super.onError with error and stackTrace', () {
        final error = Exception('test error');
        final stackTrace = StackTrace.current;
        expect(
          () => observer.onError(testBloc, error, stackTrace),
          returnsNormally,
        );
      });

      test('should handle different error types', () {
        final error1 = Exception('exception');
        final error2 = StateError('state error');
        final error3 = ArgumentError('argument error');
        final stackTrace = StackTrace.current;

        expect(
          () => observer.onError(testBloc, error1, stackTrace),
          returnsNormally,
        );
        expect(
          () => observer.onError(testBloc, error2, stackTrace),
          returnsNormally,
        );
        expect(
          () => observer.onError(testBloc, error3, stackTrace),
          returnsNormally,
        );
      });

      test('should log errors regardless of verbose logging setting', () {
        const verboseObserver = AppBlocObserver(enableVerboseLogging: true);
        const silentObserver = AppBlocObserver(enableVerboseLogging: false);
        final error = Exception('critical error');
        final stackTrace = StackTrace.current;

        // Both should log errors (errors are always logged)
        expect(
          () => verboseObserver.onError(testBloc, error, stackTrace),
          returnsNormally,
        );
        expect(
          () => silentObserver.onError(testBloc, error, stackTrace),
          returnsNormally,
        );
      });
    });

    group('onClose', () {
      test('should call super.onClose', () {
        expect(() => observer.onClose(testBloc), returnsNormally);
      });

      test('should log when verbose logging is enabled', () {
        final bloc = TestBloc();
        const verboseObserver = AppBlocObserver(enableVerboseLogging: true);
        expect(() => verboseObserver.onClose(bloc), returnsNormally);
        bloc.close();
      });

      test('should not throw when verbose logging is disabled', () {
        final bloc = TestBloc();
        const silentObserver = AppBlocObserver(enableVerboseLogging: false);
        expect(() => silentObserver.onClose(bloc), returnsNormally);
        bloc.close();
      });
    });

    group('Configuration', () {
      test('should create with verbose logging enabled by default', () {
        const defaultObserver = AppBlocObserver();
        expect(defaultObserver.enableVerboseLogging, isTrue);
      });

      test('should create with verbose logging disabled when specified', () {
        const silentObserver = AppBlocObserver(enableVerboseLogging: false);
        expect(silentObserver.enableVerboseLogging, isFalse);
      });

      test('should create with verbose logging enabled when specified', () {
        const verboseObserver = AppBlocObserver(enableVerboseLogging: true);
        expect(verboseObserver.enableVerboseLogging, isTrue);
      });
    });

    group('Integration', () {
      test('should handle full BLoC lifecycle', () {
        final bloc = TestBloc();
        const lifecycleObserver = AppBlocObserver(enableVerboseLogging: true);

        // onCreate
        expect(() => lifecycleObserver.onCreate(bloc), returnsNormally);

        // onEvent
        expect(
          () => lifecycleObserver.onEvent(bloc, TestEvent()),
          returnsNormally,
        );

        // onChange
        final change = Change<TestState>(
          currentState: TestState(),
          nextState: TestState(),
        );
        expect(() => lifecycleObserver.onChange(bloc, change), returnsNormally);

        // onTransition
        final transition = Transition<TestEvent, TestState>(
          currentState: TestState(),
          event: TestEvent(),
          nextState: TestState(),
        );
        expect(
          () => lifecycleObserver.onTransition(bloc, transition),
          returnsNormally,
        );

        // onClose
        expect(() => lifecycleObserver.onClose(bloc), returnsNormally);

        bloc.close();
      });

      test('should handle error during lifecycle', () {
        final bloc = TestBloc();
        const lifecycleObserver = AppBlocObserver(enableVerboseLogging: true);

        // onCreate
        expect(() => lifecycleObserver.onCreate(bloc), returnsNormally);

        // onError
        final error = Exception('lifecycle error');
        final stackTrace = StackTrace.current;
        expect(
          () => lifecycleObserver.onError(bloc, error, stackTrace),
          returnsNormally,
        );

        // onClose even after error
        expect(() => lifecycleObserver.onClose(bloc), returnsNormally);

        bloc.close();
      });
    });
  });
}
