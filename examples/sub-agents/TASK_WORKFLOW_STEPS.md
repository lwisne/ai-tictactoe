# Task Implementation Workflow

## Branch Setup

When working on task LWI-2-my-task with parent epic LWI-1-my-epic:

1. Checkout parent epic branch: `lwisne/LWI-1-my-epic`
2. Pull latest changes: `git pull origin lwisne/LWI-1-my-epic`
3. Create task branch: `git checkout -b lwisne/LWI-2-my-task`

**Note:** Branch naming format is `lwisne/LWI-{issue-number}-{brief-description}`

## Implementation Flow

**NOTE:** You do not have to update the Linear task. It has hooks to respond to status changes based on the branch name.

### Step 1: Implementation
- **linear-task-implementer** implements the feature
  - Follows Clean Architecture principles
  - Adheres to project coding standards
  - Implements all acceptance criteria from Linear task

### Step 2: Testing
Run after implementation completes.

- **code-tester** ensures tests pass with proper coverage
  - Verifies all tests pass
  - Checks coverage meets project standards (typically 80%+)
  - Identifies any gaps in test coverage

**If tests fail or coverage is insufficient:**
- Fix issues with linear-task-implementer
- Restart from Step 2

### Step 3: Reviews
Run in parallel after tests pass. Each reviewer can execute concurrently.

#### code-reviewer (Always Required)
- Reviews technical correctness and code quality
- Checks adherence to best practices
- Validates requirements implementation

#### architecture-guardian (Conditionally Required)
**Required if task involves:**
- New architectural patterns or decisions
- Data model changes
- New domain services or repositories
- Significant refactoring

**Skip if:**
- Following existing patterns without modifications
- Only minor implementation changes
- Pure UI or styling work

#### ux-design-reviewer (Conditionally Required)
**Required if task involves:**
- User-facing UI components
- User flows or interactions
- Accessibility requirements
- PRD-specified UX requirements

**Skip if:**
- Backend-only work
- Infrastructure or configuration
- No user-facing components

### Review Resolution
**If ANY reviewer finds issues:**
1. Fix issues with linear-task-implementer
2. Restart from Step 2 (re-run tests to ensure fixes don't break anything)
3. Re-run ONLY the reviewers that found issues
   - Exception: If fixes affect other areas, re-run all relevant reviewers

**Continue until all required reviewers approve.**

## Branch Push and Pull Request

### Pre-Push Steps

1. **Merge parent epic branch into task branch:**
   ```bash
   git fetch origin
   git merge origin/lwisne/LWI-1-my-epic
   ```
   - Resolve any merge conflicts
   - Keep changes from both branches where appropriate

2. **Run full test suite:**
   ```bash
   flutter test
   ```
   - **CRITICAL**: ALL tests must pass before pushing
   - If ANY tests fail (including pre-existing failures): fix issues and re-run until passing
   - NEVER push code with failing tests, even if they existed before your changes
   - Ensure no regressions from merge

3. **Format code:**
   ```bash
   dart format lib test
   ```

### Push and Create PR

1. **Push branch to origin:**
   ```bash
   git push origin lwisne/LWI-2-my-task
   ```

2. **Create Pull Request:**
   - **Base branch:** Parent epic branch (`lwisne/LWI-1-my-epic`)
   - **NOT** main branch

3. **PR Description should include:**
   - Summary of implementation
   - Test coverage metrics
   - Review outcomes (which reviewers ran, any issues found/resolved)
   - Any architectural or UX decisions made
   - Link to Linear task

### Post-PR Steps

1. **Monitor and respond to PR comments:**
   ```bash
   gh pr view <pr-number> --comments
   ```
   - Check for comments from reviewers (human and automated like Copilot)
   - Respond to all comments within 24 hours
   - For code suggestions:
     - If valid: acknowledge and create follow-up commits or issues
     - If unclear: ask for clarification
     - If disagree: provide technical justification

2. **Address PR feedback:**
   - **For minor fixes** (typos, documentation, small refactors):
     - Make changes directly in the PR branch
     - Commit with clear message referencing the comment
     - Push to update the PR

   - **For major changes** (logic changes, new features):
     - Discuss with reviewer first
     - May need to re-run code-reviewer or other agents
     - Ensure all tests still pass after changes

3. **Update PR after addressing feedback:**
   ```bash
   git add .
   git commit -m "Address PR feedback: <brief description>"
   git push origin lwisne/LWI-2-my-task
   ```
   - Reply to comments indicating changes made
   - Request re-review if significant changes

## Common Issues

### Merge Conflicts
- Carefully review conflicts
- Preserve intent from both branches
- Re-run tests after resolving
- Consider re-running reviewers if significant changes

### Test Failures After Merge
- Isolate which tests are failing
- Check if parent branch changes conflict with task implementation
- Fix and re-test
- May need to re-run reviewers if fixes are substantial

### Multiple Review Cycles
- Normal for complex tasks
- Each cycle: implementer → tester → reviewers
- Track changes between cycles
- Document decisions made during iterations
