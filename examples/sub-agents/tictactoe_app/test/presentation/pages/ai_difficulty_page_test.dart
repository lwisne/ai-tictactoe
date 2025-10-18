import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tictactoe_app/core/theme/app_theme.dart';
import 'package:tictactoe_app/presentation/pages/ai_difficulty_page.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late GoRouter mockRouter;

  setUpAll(() {
    registerFallbackValue(Uri.parse('/'));
  });

  setUp(() {
    mockRouter = MockGoRouter();
  });

  Widget createTestWidget() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: InheritedGoRouter(
        goRouter: mockRouter,
        child: const AiDifficultyPage(),
      ),
    );
  }

  group('AiDifficultyPage Widget Tests', () {
    testWidgets('should display page title and description', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Select AI Difficulty'), findsOneWidget);
      expect(find.text('AI Difficulty Selection'), findsOneWidget);
      expect(find.text('Choose your challenge level'), findsOneWidget);
    });

    testWidgets('should display AI icon', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.psychology), findsOneWidget);
    });

    testWidgets('should display all three difficulty buttons', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
    });

    testWidgets('should navigate to game on Easy button tap', (tester) async {
      when(() => mockRouter.go(any())).thenAnswer((_) {});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Easy'));
      await tester.pumpAndSettle();

      verify(() => mockRouter.go('/game')).called(1);
    });

    testWidgets('should navigate to game on Medium button tap', (tester) async {
      when(() => mockRouter.go(any())).thenAnswer((_) {});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Medium'));
      await tester.pumpAndSettle();

      verify(() => mockRouter.go('/game')).called(1);
    });

    testWidgets('should navigate to game on Hard button tap', (tester) async {
      when(() => mockRouter.go(any())).thenAnswer((_) {});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hard'));
      await tester.pumpAndSettle();

      verify(() => mockRouter.go('/game')).called(1);
    });
  });

  group('Recommended Badge Tests (LWI-168)', () {
    testWidgets('should display "Recommended" badge on Medium difficulty', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Badge text should be visible
      expect(find.text('Recommended'), findsOneWidget);
    });

    testWidgets('should display badge using Material 3 Chip component', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Chip widget should exist
      expect(find.byType(Chip), findsOneWidget);

      // Chip should contain "Recommended" text
      final chip = tester.widget<Chip>(find.byType(Chip));
      final chipLabel = chip.label as Text;
      expect(chipLabel.data, 'Recommended');
    });

    testWidgets('should not display badge on Easy difficulty', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find Easy button
      final easyButton = find.ancestor(
        of: find.text('Easy'),
        matching: find.byType(ElevatedButton),
      );
      expect(easyButton, findsOneWidget);

      // Easy button should not have a Stack (which is used for badge)
      final easyButtonWidget = tester.widget<ElevatedButton>(easyButton);
      expect(easyButtonWidget.child, isA<Text>());
    });

    testWidgets('should not display badge on Hard difficulty', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find Hard button
      final hardButton = find.ancestor(
        of: find.text('Hard'),
        matching: find.byType(ElevatedButton),
      );
      expect(hardButton, findsOneWidget);

      // Hard button should not have a Stack (which is used for badge)
      final hardButtonWidget = tester.widget<ElevatedButton>(hardButton);
      expect(hardButtonWidget.child, isA<Text>());
    });

    testWidgets('should display tooltip with explanation on badge hover', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the Tooltip widget
      expect(find.byType(Tooltip), findsOneWidget);

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(
        tooltip.message,
        'Best balance of challenge and enjoyment for most players',
      );
    });

    testWidgets('should use Material 3 color scheme for badge', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final chip = tester.widget<Chip>(find.byType(Chip));

      // Badge should use primaryContainer color from theme
      final theme = AppTheme.lightTheme;
      expect(chip.backgroundColor, theme.colorScheme.primaryContainer);

      // Label should use onPrimaryContainer color
      expect(chip.labelStyle?.color, theme.colorScheme.onPrimaryContainer);
    });

    testWidgets('should position badge at top-right of button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the Positioned widget containing the badge
      final positioned = tester.widget<Positioned>(
        find.ancestor(of: find.byType(Chip), matching: find.byType(Positioned)),
      );

      // Badge should be positioned at top-right
      expect(positioned.top, -8);
      expect(positioned.right, -8);
    });

    testWidgets('should not obscure button label with badge', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Medium button text should be visible
      expect(find.text('Medium'), findsOneWidget);

      // Badge should be visible
      expect(find.text('Recommended'), findsOneWidget);

      // Both should be rendered (no overflow or clipping issues)
      expect(tester.takeException(), isNull);
    });

    testWidgets('should have proper accessibility label for badge', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the Semantics widget wrapping the Chip
      final semantics = tester.widgetList<Semantics>(
        find.ancestor(of: find.byType(Chip), matching: find.byType(Semantics)),
      );

      // Should have a Semantics widget with proper label for the badge
      final badgeSemantics = semantics.firstWhere(
        (s) => s.properties.label == 'Recommended difficulty level',
        orElse: () => throw StateError('Badge semantics label not found'),
      );

      expect(badgeSemantics.properties.label, 'Recommended difficulty level');
    });

    testWidgets('should have proper accessibility label for Medium button', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the Semantics widget wrapping the Medium button with badge
      final semantics = tester.widgetList<Semantics>(
        find.ancestor(
          of: find.text('Medium'),
          matching: find.byType(Semantics),
        ),
      );

      // Should have a Semantics widget with proper label
      final outerSemantics = semantics.firstWhere(
        (s) => s.properties.label == 'Medium difficulty (Recommended)',
        orElse: () => throw StateError('Semantics label not found'),
      );

      expect(
        outerSemantics.properties.label,
        'Medium difficulty (Recommended)',
      );
      expect(outerSemantics.properties.button, true);
    });

    testWidgets('should use compact visual density for badge', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final chip = tester.widget<Chip>(find.byType(Chip));

      expect(chip.visualDensity, VisualDensity.compact);
      expect(chip.materialTapTargetSize, MaterialTapTargetSize.shrinkWrap);
    });

    testWidgets('should use appropriate font size and weight for badge text', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final chip = tester.widget<Chip>(find.byType(Chip));
      final chipLabel = chip.label as Text;

      expect(chipLabel.style?.fontSize, 10);
      expect(chipLabel.style?.fontWeight, FontWeight.w600);
    });
  });

  group('Responsive Layout Tests (LWI-168)', () {
    testWidgets('should not overflow on small screens with badge', (
      tester,
    ) async {
      // Set a small screen size
      tester.view.physicalSize = const Size(400, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Page should render without overflow
      expect(tester.takeException(), isNull);

      // All buttons should still be visible
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
      expect(find.text('Recommended'), findsOneWidget);
    });

    testWidgets('should display properly on large screens with badge', (
      tester,
    ) async {
      // Set a large screen size
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // All elements should be visible
      expect(find.text('AI Difficulty Selection'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
      expect(find.text('Recommended'), findsOneWidget);
    });

    testWidgets('should maintain badge position on different screen sizes', (
      tester,
    ) async {
      // Test on tablet size
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Badge should still be positioned correctly
      final positioned = tester.widget<Positioned>(
        find.ancestor(of: find.byType(Chip), matching: find.byType(Positioned)),
      );

      expect(positioned.top, -8);
      expect(positioned.right, -8);
    });
  });

  group('AppBar and Navigation Tests', () {
    testWidgets('should have AppBar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display title in AppBar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final title = appBar.title as Text;
      expect(title.data, 'Select AI Difficulty');
    });
  });
}
