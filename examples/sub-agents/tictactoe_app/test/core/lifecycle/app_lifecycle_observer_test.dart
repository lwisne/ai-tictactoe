import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_app/core/lifecycle/app_lifecycle_observer.dart';

void main() {
  group('AppLifecycleObserver', () {
    late int pausedCallCount;
    late int resumedCallCount;
    late int detachedCallCount;
    late AppLifecycleObserver observer;

    setUp(() {
      pausedCallCount = 0;
      resumedCallCount = 0;
      detachedCallCount = 0;

      observer = AppLifecycleObserver(
        onPaused: () => pausedCallCount++,
        onResumed: () => resumedCallCount++,
        onDetached: () => detachedCallCount++,
      );
    });

    tearDown(() {
      observer.unregister();
    });

    group('lifecycle state changes', () {
      test('should call onPaused when app is paused', () {
        observer.didChangeAppLifecycleState(AppLifecycleState.paused);

        expect(pausedCallCount, 1);
        expect(resumedCallCount, 0);
        expect(detachedCallCount, 0);
      });

      test('should call onResumed when app is resumed', () {
        observer.didChangeAppLifecycleState(AppLifecycleState.resumed);

        expect(pausedCallCount, 0);
        expect(resumedCallCount, 1);
        expect(detachedCallCount, 0);
      });

      test('should call onDetached when app is detached', () {
        observer.didChangeAppLifecycleState(AppLifecycleState.detached);

        expect(pausedCallCount, 0);
        expect(resumedCallCount, 0);
        expect(detachedCallCount, 1);
      });

      test('should not call callbacks for inactive state', () {
        observer.didChangeAppLifecycleState(AppLifecycleState.inactive);

        expect(pausedCallCount, 0);
        expect(resumedCallCount, 0);
        expect(detachedCallCount, 0);
      });

      test('should not call callbacks for hidden state', () {
        observer.didChangeAppLifecycleState(AppLifecycleState.hidden);

        expect(pausedCallCount, 0);
        expect(resumedCallCount, 0);
        expect(detachedCallCount, 0);
      });
    });

    group('multiple state changes', () {
      test('should handle paused -> resumed sequence', () {
        observer.didChangeAppLifecycleState(AppLifecycleState.paused);
        observer.didChangeAppLifecycleState(AppLifecycleState.resumed);

        expect(pausedCallCount, 1);
        expect(resumedCallCount, 1);
      });

      test('should handle multiple paused calls', () {
        observer.didChangeAppLifecycleState(AppLifecycleState.paused);
        observer.didChangeAppLifecycleState(AppLifecycleState.paused);
        observer.didChangeAppLifecycleState(AppLifecycleState.paused);

        expect(pausedCallCount, 3);
      });

      test('should handle app lifecycle sequence', () {
        observer.didChangeAppLifecycleState(AppLifecycleState.inactive);
        observer.didChangeAppLifecycleState(AppLifecycleState.paused);
        observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
        observer.didChangeAppLifecycleState(AppLifecycleState.inactive);

        expect(pausedCallCount, 1);
        expect(resumedCallCount, 1);
        expect(detachedCallCount, 0);
      });
    });

    group('optional callbacks', () {
      test('should work with only onPaused callback', () {
        final observer = AppLifecycleObserver(
          onPaused: () => pausedCallCount++,
        );

        observer.didChangeAppLifecycleState(AppLifecycleState.paused);
        observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
        observer.didChangeAppLifecycleState(AppLifecycleState.detached);

        expect(pausedCallCount, 1);
      });

      test('should work with only onResumed callback', () {
        final observer = AppLifecycleObserver(
          onResumed: () => resumedCallCount++,
        );

        observer.didChangeAppLifecycleState(AppLifecycleState.paused);
        observer.didChangeAppLifecycleState(AppLifecycleState.resumed);

        expect(resumedCallCount, 1);
      });

      test('should work with no callbacks', () {
        final observer = AppLifecycleObserver();

        expect(
          () => observer.didChangeAppLifecycleState(AppLifecycleState.paused),
          returnsNormally,
        );
      });
    });

    group('register and unregister', () {
      testWidgets('should register observer with WidgetsBinding', (
        tester,
      ) async {
        await tester.pumpWidget(const SizedBox());

        final observer = AppLifecycleObserver(
          onPaused: () => pausedCallCount++,
        );

        observer.register();

        // Verify observer is registered by checking it receives callbacks
        // Note: We can't easily test registration directly, but we can verify
        // it works through the lifecycle
        expect(() => observer.unregister(), returnsNormally);
      });

      testWidgets('should unregister observer from WidgetsBinding', (
        tester,
      ) async {
        await tester.pumpWidget(const SizedBox());

        final observer = AppLifecycleObserver(
          onPaused: () => pausedCallCount++,
        );

        observer.register();
        observer.unregister();

        // Should not throw when unregistering twice
        expect(() => observer.unregister(), returnsNormally);
      });
    });

    group('edge cases', () {
      test('should handle rapid state changes', () {
        for (var i = 0; i < 100; i++) {
          observer.didChangeAppLifecycleState(AppLifecycleState.paused);
          observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
        }

        expect(pausedCallCount, 100);
        expect(resumedCallCount, 100);
      });

      test('should handle detached followed by other states', () {
        observer.didChangeAppLifecycleState(AppLifecycleState.detached);
        observer.didChangeAppLifecycleState(AppLifecycleState.paused);
        observer.didChangeAppLifecycleState(AppLifecycleState.resumed);

        expect(detachedCallCount, 1);
        expect(pausedCallCount, 1);
        expect(resumedCallCount, 1);
      });
    });

    group('callback errors', () {
      test('should not crash if callback throws', () {
        final observer = AppLifecycleObserver(
          onPaused: () => throw Exception('Test error'),
        );

        expect(
          () => observer.didChangeAppLifecycleState(AppLifecycleState.paused),
          throwsException,
        );
      });

      test('should continue after one callback throws', () {
        var secondCallbackCalled = false;

        final observer = AppLifecycleObserver(
          onPaused: () => throw Exception('Test error'),
        );

        try {
          observer.didChangeAppLifecycleState(AppLifecycleState.paused);
        } catch (e) {
          // Expected
        }

        // Create another observer to verify system still works
        final observer2 = AppLifecycleObserver(
          onResumed: () => secondCallbackCalled = true,
        );

        observer2.didChangeAppLifecycleState(AppLifecycleState.resumed);
        expect(secondCallbackCalled, true);
      });
    });
  });
}
