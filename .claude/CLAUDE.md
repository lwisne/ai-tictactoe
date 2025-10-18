# AI Tic-Tac-Toe Project Instructions

## CRITICAL: Task Workflow - READ THIS FIRST

**BEFORE STARTING ANY LINEAR TASK**, you MUST read and follow the workflow defined in:
`/Users/lwisne/code/ai-tictactoe/examples/sub-agents/TASK_WORKFLOW_STEPS.md`

### Mandatory Workflow Steps (in order):

1. **Branch Setup**
   - Checkout parent epic branch (e.g., `lwisne/LWI-86-epic-1-project-setup-foundation`)
   - Pull latest: `git pull origin <parent-epic-branch>`
   - Create task branch: `git checkout -b lwisne/LWI-{number}-{description}`

2. **Implementation**
   - Use `linear-task-implementer` agent to implement the feature
   - Follow Clean Architecture principles
   - Implement ALL acceptance criteria from Linear task

3. **Testing**
   - Use `code-tester` agent to verify tests pass and coverage meets standards
   - If tests fail or coverage insufficient: fix with linear-task-implementer and re-test
   - NEVER proceed until all tests pass

4. **Reviews** (run in parallel after tests pass)
   - **ALWAYS run:** `code-reviewer` agent
   - **Conditionally run:**
     - `architecture-guardian`: if new patterns, data models, or significant refactoring
     - `ux-design-reviewer`: if user-facing UI, user flows, or PRD-specified UX requirements
   - If ANY reviewer finds issues: fix with linear-task-implementer, re-test, re-run ONLY reviewers that found issues

5. **Pre-Push Steps**
   - Merge parent epic branch: `git merge origin/<parent-epic-branch>`
   - Run FULL test suite: `flutter test` (ALL tests MUST pass)
   - Format code: `dart format lib test`

6. **Push and Create PR**
   - Push: `git push origin lwisne/LWI-{number}-{description}`
   - Create PR with **base branch = parent epic branch** (NOT main)
   - Include: implementation summary, test coverage, review outcomes, Linear task link

7. **Post-PR**
   - Monitor PR comments: `gh pr view <pr-number> --comments`
   - Address feedback and push updates to PR branch

## Important Rules

### DO NOT:
- ❌ Manually update Linear task status (it uses git hooks based on branch names)
- ❌ Create PR to main branch (always to parent epic branch)
- ❌ Push code with failing tests (even pre-existing failures)
- ❌ Skip reviewers (always run code-reviewer minimum)
- ❌ Work on multiple tasks in same branch (one task = one branch)

### ALWAYS:
- ✅ Read TASK_WORKFLOW_STEPS.md before each new task
- ✅ Branch from parent epic branch
- ✅ Run all required workflow steps in order
- ✅ Merge parent epic before pushing
- ✅ Ensure ALL tests pass before pushing
- ✅ Create PR to parent epic branch

## Linear Task Lookup

When looking up Linear issues, ALWAYS use:
```
team: "Lwisne"  (NOT "LWI")
```

The team name is "Lwisne" - "LWI" is just the issue identifier prefix.

## Project Structure

This project uses Clean Architecture with:
- **Domain layer**: Models, repositories (interfaces)
- **Data layer**: Repository implementations, data sources
- **Presentation layer**: BLoCs/Cubits, Pages, Widgets
- **Core layer**: DI, theming, navigation, utilities

See `/Users/lwisne/code/ai-tictactoe/examples/sub-agents/tictactoe_app/ARCHITECTURE.md` for full details.
