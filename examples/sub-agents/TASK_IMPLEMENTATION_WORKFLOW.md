# Task Implementation Workflow

This document describes the complete workflow for implementing Linear tasks in the AI Tic-Tac-Toe project.

---

## Table of Contents

1. [Overview](#overview)
2. [Initial Steps: Task Discovery & Analysis](#1-initial-steps-task-discovery--analysis)
3. [Understanding Requirements](#2-understanding-requirements)
4. [Architecture Review & Planning](#3-architecture-review--planning)
5. [Branch Management](#4-branch-management)
6. [Implementation Process](#5-implementation-process)
7. [Testing: Comprehensive Coverage](#6-testing-comprehensive-coverage)
8. [Code Quality & Formatting](#7-code-quality--formatting)
9. [Completion: Pre-Push Verification](#8-completion-pre-push-verification)
10. [Collaboration with Other Agents](#9-collaboration-with-other-agents)
11. [Complete Workflow Checklist](#complete-workflow-checklist)
12. [Example: Complete Implementation Flow](#example-complete-implementation-flow)

---

## Overview

Every Linear task follows a 9-phase workflow to ensure production-ready, well-tested, and architecturally compliant code:

1. **Discovery** (5-10 min)
2. **Planning** (10-15 min)
3. **Branch Setup** (2 min)
4. **Implementation** (30-120 min)
5. **Testing** (20-60 min)
6. **Quality Assurance** (10 min)
7. **Verification** (5 min)
8. **Commit & Push** (5 min)
9. **Handoff** (Variable)

**Total Time**: 1.5-4 hours per task (depending on complexity)

---

## 1. Initial Steps: Task Discovery & Analysis

### When given a task ID (e.g., `LWI-100`):

#### a) Fetch the Linear task details

Use Linear to get complete task information:
- Task title, description, and acceptance criteria
- Epic/project association
- Priority and labels
- Any linked dependencies or blockers
- Comments or additional context

#### b) Identify task scope

- Determine if it's a feature, bug fix, refactor, or test addition
- Check for related tasks or dependencies
- Verify the task is ready for implementation (not blocked)

#### c) Gather context from documentation

Review relevant sections in:
- `.claude/technical-architecture.md`
- `ARCHITECTURE_SPECIFICATIONS.md`
- `.claude/testing-requirements.md`
- PRD documents in Notion (if applicable)

---

## 2. Understanding Requirements

### a) Analyze Linear issue details

- Parse acceptance criteria into concrete implementation requirements
- Identify user stories or use cases
- Note any specific technical constraints mentioned

### b) Review Product Requirements (if available)

- Search Notion for related PRD documents
- Cross-reference PRD requirements with Linear acceptance criteria
- Clarify any ambiguities before proceeding

### c) Ask clarifying questions if needed

If acceptance criteria are vague or incomplete, ask questions like:
- "Should this feature support all game modes or just standard 3x3?"
- "Should this handle the offline mode mentioned in LWI-88?"
- "What should happen if the user's device has insufficient storage?"

---

## 3. Architecture Review & Planning

### a) Review existing codebase structure

Examine relevant directories:
```
lib/features/[feature_name]/
lib/core/
test/features/[feature_name]/
```

### b) Identify architectural patterns

- Locate similar existing implementations
- Understand the BLoC pattern usage in the feature area
- Review how routing is handled (go_router patterns)
- Check data persistence patterns (shared_preferences usage)

### c) Verify compliance requirements

- **BLoC pattern**: Events, States, and Bloc classes properly separated
- **Dependency injection**: Using GetIt for service registration
- **Routing**: Following go_router conventions
- **State management**: Immutable state classes with copyWith methods
- **Error handling**: Proper try-catch and error states

### d) Plan the implementation

- List files to create/modify
- Identify required tests (unit, widget, integration)
- Determine if any refactoring is needed first
- Map out feature interactions with existing code

---

## 4. Branch Management

### Branching Strategy

The project uses a hierarchical branching strategy:

```
main
├── Epic Branch (from main)
│   ├── Sub-task Branch (from epic)
│   ├── Sub-task Branch (from epic)
│   └── Sub-task Branch (from epic)
└── [Merge epic → main when complete]
```

### For Epic Tasks (LWI-86 to LWI-93)

**a) Check current branch status:**
```bash
git status
git branch --show-current
```

**b) Ensure on main and updated:**
```bash
git checkout main
git pull origin main
```

**c) Create epic feature branch:**
```bash
# Format: lwisne/[EPIC-ID]-[descriptive-name]
# Example for Epic LWI-87 "Core Game Mechanics"
git checkout -b lwisne/LWI-87-core-game-mechanics
```

**d) Verify branch creation:**
```bash
git branch --show-current
# Output should be: lwisne/LWI-87-core-game-mechanics
```

### For Sub-Task Tasks (under an Epic)

**a) Check out parent epic branch:**
```bash
# Example: Working on LWI-100 which is under Epic LWI-87
git checkout lwisne/LWI-87-core-game-mechanics
git pull origin lwisne/LWI-87-core-game-mechanics
```

**b) Create sub-task branch from epic:**
```bash
# Format: lwisne/[TASK-ID]-[descriptive-name]
# Example for task LWI-100 "Implement turn management"
git checkout -b lwisne/LWI-100-implement-turn-management
```

**c) Verify branch creation:**
```bash
git branch --show-current
# Output should be: lwisne/LWI-100-implement-turn-management
```

### Critical Branching Rules

- ✅ **Epic branches**: Created from `main`
- ✅ **Sub-task branches**: Created from their parent epic branch
- ✅ Branch name format: `lwisne/[TASK-ID]-[descriptive-kebab-case]`
- ✅ One Linear issue = One branch
- ❌ **NEVER** push directly to main
- ❌ **NEVER** create sub-task branches from main

### Merge Strategy

1. **Sub-task completion**: Merge sub-task branch → epic branch
2. **Epic completion**: Merge epic branch → main
3. **Flow**: `sub-task → epic branch → main`

---

## 5. Implementation Process

### a) Start with data models and types

```dart
// Example: lib/features/tournament/models/tournament.dart
class Tournament {
  final String id;
  final List<Player> participants;
  final TournamentStatus status;

  const Tournament({
    required this.id,
    required this.participants,
    required this.status,
  });

  Tournament copyWith({
    String? id,
    List<Player>? participants,
    TournamentStatus? status,
  }) => Tournament(
    id: id ?? this.id,
    participants: participants ?? this.participants,
    status: status ?? this.status,
  );
}
```

### b) Implement BLoC layer

```dart
// Events
abstract class TournamentEvent extends Equatable {}

class TournamentStarted extends TournamentEvent {
  final List<Player> participants;

  const TournamentStarted(this.participants);

  @override
  List<Object> get props => [participants];
}

// States
abstract class TournamentState extends Equatable {}

class TournamentInitial extends TournamentState {
  @override
  List<Object> get props => [];
}

class TournamentInProgress extends TournamentState {
  final Tournament tournament;

  const TournamentInProgress(this.tournament);

  @override
  List<Object> get props => [tournament];
}

// Bloc
class TournamentBloc extends Bloc<TournamentEvent, TournamentState> {
  TournamentBloc() : super(TournamentInitial()) {
    on<TournamentStarted>(_onTournamentStarted);
  }

  void _onTournamentStarted(
    TournamentStarted event,
    Emitter<TournamentState> emit,
  ) {
    // Business logic here
  }
}
```

### c) Add UI layer (widgets)

```dart
// lib/features/tournament/presentation/pages/tournament_page.dart
class TournamentPage extends StatelessWidget {
  const TournamentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TournamentBloc(),
      child: const TournamentView(),
    );
  }
}

class TournamentView extends StatelessWidget {
  const TournamentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tournament')),
      body: BlocBuilder<TournamentBloc, TournamentState>(
        builder: (context, state) {
          if (state is TournamentInitial) {
            return const Center(child: Text('Start Tournament'));
          }
          if (state is TournamentInProgress) {
            return TournamentBracketView(tournament: state.tournament);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

### d) Configure routing

```dart
// Update lib/core/routing/app_router.dart
GoRoute(
  path: '/tournament',
  name: 'tournament',
  builder: (context, state) => const TournamentPage(),
)
```

### e) Add dependency injection

```dart
// Update lib/core/di/injection.dart
void setupDependencies() {
  getIt.registerFactory<TournamentBloc>(() => TournamentBloc());
}
```

### Key Implementation Principles

- ✅ Match existing code style and patterns
- ✅ Use immutable data structures
- ✅ Implement proper error handling
- ✅ Add inline comments for complex logic
- ✅ Prefer self-documenting code over excessive comments
- ✅ Follow Material 3 design guidelines
- ✅ ALL widgets must be StatelessWidget (NO StatefulWidget)
- ✅ Business logic in Services, NOT in BLoCs or Models

---

## 6. Testing: Comprehensive Coverage

### a) Write unit tests for business logic

```dart
// test/features/tournament/bloc/tournament_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TournamentBloc', () {
    late TournamentBloc tournamentBloc;

    setUp(() {
      tournamentBloc = TournamentBloc();
    });

    tearDown(() {
      tournamentBloc.close();
    });

    test('initial state is TournamentInitial', () {
      expect(tournamentBloc.state, equals(TournamentInitial()));
    });

    blocTest<TournamentBloc, TournamentState>(
      'emits TournamentInProgress when TournamentStarted is added',
      build: () => tournamentBloc,
      act: (bloc) => bloc.add(TournamentStarted([])),
      expect: () => [isA<TournamentInProgress>()],
    );

    blocTest<TournamentBloc, TournamentState>(
      'handles empty participant list correctly',
      build: () => tournamentBloc,
      act: (bloc) => bloc.add(TournamentStarted([])),
      expect: () => [isA<TournamentError>()],
    );
  });
}
```

### b) Write widget tests for UI components

```dart
// test/features/tournament/presentation/pages/tournament_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('TournamentPage displays correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TournamentPage(),
      ),
    );

    expect(find.text('Tournament'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('TournamentPage shows tournament bracket when in progress',
    (tester) async {
    // Setup mock bloc with TournamentInProgress state
    // Verify bracket view is displayed
  });
}
```

### c) Add integration tests (if needed)

```dart
// test/integration/tournament_flow_test.dart
void main() {
  testWidgets('Complete tournament flow works', (tester) async {
    // Test full user journey from start to finish
    await tester.pumpWidget(const MyApp());

    // Navigate to tournament
    await tester.tap(find.text('Start Tournament'));
    await tester.pumpAndSettle();

    // Verify tournament screen displayed
    expect(find.text('Tournament'), findsOneWidget);
  });
}
```

### d) Ensure edge case coverage

Test for:
- Empty states
- Error conditions
- Boundary values
- Concurrent operations
- State transitions
- Null safety

### Testing Checklist

- ✅ Unit tests for all business logic (BLoCs, services, models)
- ✅ Widget tests for all UI components
- ✅ Integration tests for critical user flows
- ✅ Edge cases and error scenarios covered
- ✅ Minimum 80% code coverage (per testing-requirements.md)
- ✅ All tests must pass before pushing

---

## 7. Code Quality & Formatting

### a) Apply VSCode formatting

```bash
# Format all modified Dart files
dart format lib/features/tournament/
dart format test/features/tournament/
```

### b) Run static analysis

```bash
# Check for linting issues
flutter analyze

# Expected output: No issues found!
```

### c) Verify code standards

- ✅ No linting warnings or errors
- ✅ All imports properly organized
- ✅ No unused variables or imports
- ✅ Proper naming conventions (camelCase, PascalCase)
- ✅ Constants extracted where appropriate
- ✅ Magic numbers eliminated

### d) Self-review checklist

- [ ] Code follows BLoC pattern correctly
- [ ] Error handling implemented
- [ ] Loading states handled
- [ ] Navigation flows work correctly
- [ ] UI matches Material 3 guidelines
- [ ] Accessibility considerations addressed
- [ ] Performance optimizations applied (if needed)
- [ ] NO StatefulWidget usage
- [ ] Business logic in Services, NOT BLoCs

---

## 8. Completion: Pre-Push Verification

### a) Run the full test suite

```bash
# Run all tests
flutter test

# Expected output: All tests passed!
```

### b) Verify test coverage

```bash
# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Open coverage/html/index.html to verify coverage
```

### c) Build verification (if needed)

```bash
# Ensure app builds successfully
flutter build apk --debug  # Android
flutter build ios --debug   # iOS (if on macOS)
```

### d) Git commit with proper message

```bash
git add .
git commit -m "feat(tournament): implement tournament mode for LWI-100

- Add Tournament model with participants and status
- Implement TournamentBloc with events and states
- Create TournamentPage UI with Material 3 design
- Add routing configuration for tournament feature
- Implement comprehensive test coverage (12 tests, 95% coverage)

Resolves LWI-100"
```

### e) Push to feature branch

**For sub-task branches:**
```bash
# Push to sub-task branch (which is based on epic branch)
git push -u origin lwisne/LWI-100-implement-turn-management
```

**For epic branches:**
```bash
# Push to epic branch (which is based on main)
git push -u origin lwisne/LWI-87-core-game-mechanics
```

### Pre-push Verification Checklist

- ✅ All tests passing
- ✅ Code formatted with VSCode settings
- ✅ No linting errors
- ✅ Test coverage meets requirements (80%+)
- ✅ Proper commit message format
- ✅ Pushing to correct feature branch (NOT main)

---

## 9. Collaboration with Other Agents

### Agent Collaboration Flow

```
Project Manager → Task Implementer → Code Tester → Code Reviewer → Project Manager
                        ↕
                Architecture Guardian (when needed)
```

### When to Request Help

#### a) Code Tester (for additional test coverage)

**Scenario**: Initial tests written but coverage gaps identified

```
Task Implementer → Code Tester:
"Implementation of LWI-100 complete. Tests written covering:
- Basic tournament creation
- Player addition
- Status transitions

Please verify coverage and identify any missing test scenarios."
```

#### b) Architecture Guardian (for architecture questions)

**Scenario**: Unsure about architectural decision

```
Task Implementer → Architecture Guardian:
"Implementing LWI-100 tournament mode. Question about state management:
Should tournament state be:
1. Managed in a separate TournamentBloc
2. Integrated into existing GameBloc
3. Use a combined approach

Current game architecture uses isolated feature BLoCs."
```

#### c) Code Reviewer (after implementation)

**Scenario**: Implementation complete, ready for review

```
Task Implementer → Code Reviewer:
"LWI-100 implementation complete and pushed to:
Branch: lwisne/LWI-100-implement-turn-management

Summary:
- Files Created: 8
- Files Modified: 3
- Tests Added: 12 (95% coverage)
- All tests passing ✓
- Code formatted ✓

Ready for technical review."
```

### When Other Agents Request Your Help

#### a) From Project Manager (task assignment)

```
Project Manager → Task Implementer:
"Created LWI-100 for tournament mode feature.
Epic: LWI-87 (Core Game Mechanics)
Priority: High
Dependencies: None

Please implement per acceptance criteria in Linear."
```

#### b) From Code Reviewer (feedback incorporation)

```
Code Reviewer → Task Implementer:
"Review of LWI-100 complete. Changes requested:
1. Extract hardcoded strings to constants
2. Add error handling for player limit exceeded
3. Simplify TournamentBloc state transitions

Please address and re-push."
```

#### c) From Code Tester (test failures)

```
Code Tester → Task Implementer:
"Test suite failing on LWI-100 branch:
- test/features/tournament/bloc/tournament_bloc_test.dart
  Line 45: Expected TournamentComplete but got TournamentError

Please fix failing tests."
```

### Collaboration Triggers

| Trigger | Agent | Direction |
|---------|-------|-----------|
| Task ready for implementation | Project Manager | → Task Implementer |
| Architecture question | Task Implementer | → Architecture Guardian |
| Implementation complete | Task Implementer | → Code Tester |
| Tests verified | Code Tester | → Code Reviewer |
| Review feedback received | Code Reviewer | → Task Implementer |
| Tests failing | Code Tester | → Task Implementer |
| PR ready for merge | Task Implementer | → Project Manager |

---

## Complete Workflow Checklist

### Phase 1: Discovery (5-10 minutes)

- [ ] Fetch Linear task details (LWI-XXX)
- [ ] Read acceptance criteria thoroughly
- [ ] Review related PRD in Notion (if applicable)
- [ ] Identify dependencies and blockers
- [ ] Ask clarifying questions if needed

### Phase 2: Planning (10-15 minutes)

- [ ] Review architecture documentation
- [ ] Examine existing codebase patterns
- [ ] Identify files to create/modify
- [ ] Plan test coverage strategy
- [ ] Verify no architectural conflicts

### Phase 3: Branch Setup (2 minutes)

**For Epic Tasks:**
- [ ] Ensure on main branch and updated
- [ ] Create epic branch: `lwisne/LWI-XX-description`
- [ ] Verify branch name format correct

**For Sub-Task Tasks:**
- [ ] Check out parent epic branch
- [ ] Pull latest changes from epic branch
- [ ] Create sub-task branch: `lwisne/LWI-XXX-description`
- [ ] Verify branch name format correct

### Phase 4: Implementation (30-120 minutes)

- [ ] Create data models and types
- [ ] Implement BLoC layer (events, states, bloc)
- [ ] Build UI components (pages, widgets)
- [ ] Configure routing
- [ ] Add dependency injection
- [ ] Follow existing code patterns
- [ ] Add inline comments for complex logic

### Phase 5: Testing (20-60 minutes)

- [ ] Write unit tests for business logic
- [ ] Write widget tests for UI
- [ ] Add integration tests (if needed)
- [ ] Cover edge cases and errors
- [ ] Verify 80%+ code coverage

### Phase 6: Quality Assurance (10 minutes)

- [ ] Run `flutter analyze` (no errors)
- [ ] Run `dart format` on all modified files
- [ ] Self-review against code standards
- [ ] Check Material 3 compliance

### Phase 7: Verification (5 minutes)

- [ ] Run full test suite: `flutter test`
- [ ] All tests passing ✅
- [ ] Generate and review coverage report
- [ ] Verify build succeeds (if needed)

### Phase 8: Commit & Push (5 minutes)

- [ ] Stage all changes: `git add .`
- [ ] Commit with proper message format
- [ ] Push to correct feature branch (epic or sub-task)
- [ ] Verify push successful

### Phase 9: Handoff (Variable)

- [ ] Notify Code Tester for coverage verification
- [ ] Provide implementation summary
- [ ] Wait for Code Reviewer feedback
- [ ] Address any review comments
- [ ] Re-push if changes requested

---

## Example: Complete Implementation Flow

### Task: LWI-100 - Implement Turn Management System

**Epic**: LWI-87 (Core Game Mechanics)

#### Step 1: Fetch task from Linear

```
Title: Implement Turn Management System
Epic: LWI-87 (Core Game Mechanics)
Priority: High
Acceptance Criteria:
- Players alternate turns (X then O)
- Current player always clearly indicated
- Invalid moves rejected
- Turn state persists across game
```

#### Step 2: Review architecture

- Examined `lib/features/game/` structure
- Identified BLoC pattern usage
- Reviewed `ARCHITECTURE_SPECIFICATIONS.md` Section 5.5.2

#### Step 3: Create feature branch from epic

```bash
# First, checkout the parent epic branch
git checkout lwisne/LWI-87-core-game-mechanics
git pull origin lwisne/LWI-87-core-game-mechanics

# Then create sub-task branch from epic
git checkout -b lwisne/LWI-100-implement-turn-management
```

#### Step 4: Implement feature

Files Created:
```
lib/domain/services/turn_service.dart
lib/features/game/models/turn_state.dart
lib/features/game/bloc/game_event.dart (modified)
lib/features/game/bloc/game_state.dart (modified)
lib/features/game/bloc/game_bloc.dart (modified)
```

Files Modified:
```
lib/features/game/presentation/widgets/turn_indicator.dart
```

#### Step 5: Write tests

Tests Created:
```
test/domain/services/turn_service_test.dart (10 tests)
test/features/game/bloc/game_bloc_test.dart (8 new tests)
test/features/game/presentation/widgets/turn_indicator_test.dart (5 tests)
```

Coverage: 92% (exceeds 80% requirement)

#### Step 6: Format and analyze

```bash
dart format lib/domain/services/ lib/features/game/ test/
flutter analyze
# Output: No issues found!
```

#### Step 7: Run tests

```bash
flutter test
# Output: 23 tests passed!
```

#### Step 8: Commit and push

```bash
git add .
git commit -m "feat(game): implement turn management system for LWI-100

- Add TurnService with turn validation logic
- Update GameBloc to handle turn events
- Create TurnState model for turn tracking
- Add TurnIndicator widget with Material 3 styling
- Implement comprehensive test coverage (23 tests, 92% coverage)

Resolves LWI-100"

# Push to sub-task branch (which will merge into epic branch)
git push -u origin lwisne/LWI-100-implement-turn-management
```

#### Step 9: Provide summary

```
Implementation Summary:
Branch: lwisne/LWI-100-implement-turn-management
Base Branch: lwisne/LWI-87-core-game-mechanics
Status: Complete ✅

Files: 5 created, 1 modified
Tests: 23 tests, all passing
Coverage: 92%
Code formatted: Yes
Linting: No issues

Ready for:
1. Code Tester verification
2. Code Reviewer review
3. Merge into lwisne/LWI-87-core-game-mechanics
```

---

## Key Principles

1. **Never compromise on standards**: Every implementation must meet project standards
2. **Test-first mindset**: Tests are not optional, they're part of the implementation
3. **Branch discipline**: Use hierarchical branching (epic → sub-task → epic → main)
4. **Clear communication**: Provide detailed summaries and ask clarifying questions
5. **Architectural consistency**: Follow existing patterns from ARCHITECTURE_SPECIFICATIONS.md
6. **Quality over speed**: Better to implement correctly than quickly
7. **Collaboration**: Actively engage with other agents when needed
8. **No shortcuts**: Follow all 9 phases for every task

---

## Quick Reference

### Branch Commands

**Epic Branch:**
```bash
git checkout main
git pull origin main
git checkout -b lwisne/LWI-XX-epic-name
```

**Sub-Task Branch:**
```bash
git checkout lwisne/LWI-XX-epic-name
git pull origin lwisne/LWI-XX-epic-name
git checkout -b lwisne/LWI-XXX-task-name
```

### Testing Commands

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
```

### Quality Commands

```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Build (debug)
flutter build apk --debug
```

### Git Commands

```bash
# Commit
git add .
git commit -m "feat(feature): description"

# Push sub-task
git push -u origin lwisne/LWI-XXX-task-name

# Push epic
git push -u origin lwisne/LWI-XX-epic-name
```

---

**Last Updated**: October 14, 2025
**Project**: AI Tic-Tac-Toe
**Document Version**: 1.0
