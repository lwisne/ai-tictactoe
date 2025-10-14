# Testing Best Practices

## Critical Rules

### NEVER Use Arbitrary Delays in Tests

**WRONG:**
```dart
await tester.pump(const Duration(milliseconds: 100));  // ❌ NEVER DO THIS
```

**Why this is bad:**
- Creates flaky tests that may pass/fail randomly based on system speed
- Makes tests slower than necessary
- Hides underlying timing issues
- Makes tests non-deterministic

**CORRECT Approaches:**

#### 1. Use `pump()` without delay for synchronous operations
```dart
// Good for simple widget rendering
await tester.pumpWidget(widget);
await tester.pump();  // Single pump to rebuild
```

#### 2. Use `pumpAndSettle()` for animations and async operations
```dart
// Good for animations and async state changes
await tester.pumpWidget(widget);
await tester.pumpAndSettle();  // Waits for all animations/futures to complete
```

**Note**: If `pumpAndSettle()` times out, it indicates an infinite animation loop or uncompleted async operation - this is a real bug that needs fixing, not masking with delays.

#### 3. Use specific pump counts when you know the exact frame count needed
```dart
// Good when you know exactly how many frames an animation takes
await tester.pump();
await tester.pump();  // 2 frames for this specific animation
```

#### 4. Mock async dependencies to avoid waiting
```dart
// Best: Mock slow operations so tests don't need to wait
when(() => mockRepository.loadData()).thenAnswer((_) async => mockData);
```

## Widget Testing Patterns

### Testing Pages with BLoC/Cubit

**Pattern**: Mock the cubit and provide it directly to the widget under test

```dart
testWidgets('page displays content', (tester) async {
  final mockCubit = MockMyCubit();
  when(() => mockCubit.state).thenReturn(MyState.initial());

  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<MyCubit>.value(
        value: mockCubit,
        child: MyPage(),
      ),
    ),
  );

  await tester.pump();  // One pump to build

  // Now test the widget
  expect(find.text('Content'), findsOneWidget);
});
```

### Testing Navigation

**Pattern**: Use `pump()` immediately after navigation, no delays. Test widget types or router state, NOT specific text.

```dart
testWidgets('navigates to page', (tester) async {
  await tester.pumpWidget(
    MaterialApp.router(routerConfig: AppRouter.router),
  );

  await tester.pump();  // Initial build

  // Navigate
  AppRouter.router.go('/other-page');
  await tester.pump();  // Rebuild after navigation

  // Verify by widget type (GOOD - resilient to text changes)
  expect(find.byType(OtherPage), findsOneWidget);

  // Or verify by router state (BETTER for navigation tests)
  expect(AppRouter.router.routerDelegate.currentConfiguration.uri.path,
      equals('/other-page'));
});
```

**Why test widget types instead of text:**
- Text can change during UI updates without breaking functionality
- Widget types represent the actual structure of the app
- Text-based tests are brittle and require updates for cosmetic changes
- Specific text should only be tested in dedicated view/widget tests

```dart
// ❌ BAD: Testing specific text in navigation tests
expect(find.text('Welcome to Other Page'), findsOneWidget);

// ✅ GOOD: Testing widget type
expect(find.byType(OtherPage), findsOneWidget);

// ✅ BETTER: Testing router state
expect(router.currentRoute.path, equals('/other-page'));
```

### Testing Async State Changes

**Pattern**: Use `pumpAndSettle()` for state that changes asynchronously

```dart
testWidgets('handles async data', (tester) async {
  final mockCubit = MockCubit();
  when(() => mockCubit.stream).thenAnswer(
    (_) => Stream.fromIterable([LoadingState(), LoadedState(data)]),
  );

  await tester.pumpWidget(/* ... */);
  await tester.pumpAndSettle();  // Wait for all async operations

  expect(find.text(data), findsOneWidget);
});
```

## Common Anti-Patterns to Avoid

### ❌ Arbitrary Waits
```dart
await tester.pump(const Duration(milliseconds: 100));  // NEVER
await Future.delayed(Duration(milliseconds: 100));      // NEVER
```

### ❌ Excessive pumpAndSettle() Calls
```dart
// Don't overuse pumpAndSettle - use pump() when possible
await tester.pump();
await tester.pumpAndSettle();  // Only if you actually have animations/async
```

### ❌ Not Mocking Async Dependencies
```dart
// Don't test with real async operations
await realRepository.loadData();  // SLOW and flaky

// Do mock them
when(() => mockRepository.loadData()).thenAnswer((_) async => data);  // FAST
```

## Debugging Test Failures

### If `pumpAndSettle()` Times Out

This indicates a real problem:
1. **Infinite animation loop** - check for continuously running animations
2. **Uncompleted Future** - check for futures that never complete
3. **Circular state updates** - check for state changes that trigger themselves

**Fix the underlying issue, don't add delays!**

### If Widget Not Found After Navigation

```dart
// Don't add delays
await tester.pump(const Duration(milliseconds: 100));  // ❌

// Do check if you need more frames
await tester.pump();  // Build frame 1
await tester.pump();  // Build frame 2 (if needed)

// Or use pumpAndSettle if there are animations
await tester.pumpAndSettle();
```

## Test Performance

- Use `pump()` instead of `pumpAndSettle()` when possible (faster)
- Mock all async operations (faster, more reliable)
- Don't use real timers or delays (slower, flaky)
- Use `setUp()` and `tearDown()` to avoid repeated initialization

## Summary

**Golden Rule**: Tests should be fast, deterministic, and never use arbitrary time delays.

If a test needs a delay to pass, it's hiding a problem that should be fixed instead.
