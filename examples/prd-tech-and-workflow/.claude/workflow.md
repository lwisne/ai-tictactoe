# Claude Code Workflow: PRD to Implementation

## Overview

This document defines a systematic workflow for implementing software features from a Product Requirements Document (PRD) using Claude Code. Follow these steps sequentially to ensure proper task decomposition and implementation order.

## Prerequisites

- Access to Linear API/MCP integration
- A complete PRD document
- Project repository initialized with main/master branch
- Technical architecture documentation available
- Linear project created for the implementation

## Workflow Steps

### Step 0: Initialize Project in Linear

**Input:** PRD document title/name
**Output:** Linear Project ID

1. Create a new Linear project:

   - Name: [PRD Title/Product Name]
   - Description: Link to PRD document
   - Lead: Assign if applicable
   - Status: Active

2. Store the Project ID for all subsequent task creation

### Step 1: Extract High-Level Features from PRD

**Input:** PRD document
**Output:** List of high-level features

1. Read the entire PRD document
2. Identify major functional areas described in the requirements
3. Create a feature list where each feature:
   - Has a clear, descriptive name
   - Maps directly to PRD sections or requirements
   - Represents a coherent unit of functionality
   - Is described in 1-2 sentences

**Format for feature list:**

```
FEATURE_001: [Feature Name]
Description: [Brief description]
PRD Reference: [Section/requirement numbers]
```

### Step 2: Create Linear Tasks for Features

**Input:** Feature list from Step 1, Project ID from Step 0
**Output:** Linear task IDs

For each feature identified:

1. Create a Linear task with:
   - Title: Feature name from Step 1
   - Description: Include PRD reference and brief description
   - Labels: "feature", "pending-analysis"
   - Project: [Project ID from Step 0]
   - Team: Appropriate team
2. Store the Linear task ID with the feature reference

**Task creation template:**

```
Title: [FEATURE_XXX] [Feature Name]
Description:
- PRD Reference: [section]
- Summary: [description]
- Status: Pending dependency analysis
Project: [Project ID]
```

### Step 3: Prioritize Features by Dependencies

**Input:** All pending Linear tasks
**Output:** Prioritized task queue

1. Analyze each feature for dependencies:

   - Technical dependencies (requires another feature's code)
   - Data dependencies (needs data/state from another feature)
   - UI dependencies (builds on another UI component)

2. Create dependency map:

```
FEATURE_001 → depends on → [none]
FEATURE_002 → depends on → [FEATURE_001]
FEATURE_003 → depends on → [FEATURE_001, FEATURE_002]
```

3. Assign priority scores:

   - Priority 1: No dependencies
   - Priority 2: Dependencies are all Priority 1
   - Priority 3: Dependencies include Priority 2
   - Continue incrementally

4. Update Linear tasks with:
   - Priority field
   - Blocking/blocked by relationships
   - Add label "ready-for-development" to Priority 1 tasks

### Step 4: Select Highest-Priority Task

**Input:** Prioritized task queue
**Output:** Selected task for implementation

1. Query Linear for tasks with:

   - Project: [Current Project ID]
   - Label: "ready-for-development"
   - Status: Not started
   - Lowest priority number (highest priority)

2. If multiple tasks have same priority:

   - Choose the one with fewer estimated subtasks
   - If still tied, choose alphabetically by title

3. Update selected task:

   - Status: In Progress
   - Assignee: Claude Code

4. Create feature branch:
   - Get Linear task identifier (e.g., "LWI-73")
   - Get feature slug from task title (e.g., "feature_004-score-tracking-system")
   - Create branch: `git checkout -b lwisne/[task-id]-[feature-slug]`
   - Example: `git checkout -b lwisne/lwi-73-feature_004-score-tracking-system`
   - Push branch: `git push -u origin [branch-name]`

### Step 5: Evaluate Task Complexity

**Input:** Selected task
**Output:** Decision to implement or subdivide

Ask yourself these questions in order:

1. **Context Window Assessment:**

   - Can I see all relevant code files in one context?
   - Do I need to hold more than 5 files in memory?
   - Will the implementation span more than 3 different modules?

2. **Implementation Confidence:**

   - Do I understand all technical requirements?
   - Can I implement this following all architecture patterns?
   - Will this require less than 500 lines of new code?
   - Can I complete this without losing context mid-task?

3. **Testing Scope:**
   - Can I write all necessary tests in one session?
   - Are there fewer than 5 test scenarios to cover?

**Decision Matrix:**

- All answers "Yes" → Proceed to implementation (Step 6A)
- Any answer "No" → Subdivide task (Step 6B)

### Step 6A: Implement Task (No Subdivision Needed)

**Input:** Task ready for implementation
**Output:** Completed implementation

1. Ensure on correct feature branch:

   - Verify: `git branch --show-current`
   - Should match: `lwisne/[task-id]-[feature-slug]`

2. Implementation checklist:

   - [ ] Review technical architecture document
   - [ ] Review existing codebase patterns
   - [ ] Implement feature following established patterns
   - [ ] Write unit tests
   - [ ] Write integration tests if applicable
   - [ ] Update documentation
   - [ ] Verify no regressions

3. Commit and push changes:

   - Stage changes: `git add .`
   - Commit: `git commit -m "[task-id] Implement [feature-name]"`
   - Push: `git push`

4. Pre-PR Validation:

   - Run full test suite: `npm test` or `flutter test` (as appropriate)
   - Verify no regression from base branch:
     ```bash
     git fetch origin
     git diff origin/[base-branch]..HEAD --stat
     # Review that only expected files changed
     ```
   - Validate implementation matches task requirements:
     - [ ] All acceptance criteria from Linear task met
     - [ ] No unintended side effects
     - [ ] Code follows established patterns
   - If any validation fails:
     - Document failure in Linear task comments
     - Fix issues and return to step 3
     - If fixes require significant rework, consider if task needs subdivision

5. Create Pull Request:

   - Push final changes: `git push origin [current-branch]`
   - Determine base branch:
     - If this is the first feature (Priority 1, no dependencies): base = `main` or `master`
     - Otherwise: base = branch of the last completed dependency
   - Create PR using GitHub CLI:

     ```bash
     gh pr create \
       --base [base-branch] \
       --head [current-branch] \
       --title "[task-id] [feature-name]" \
       --body "Implements [feature-name] as specified in Linear task [task-id]

       ## Changes
       - [List key changes]

       ## Testing
       - [List test coverage]

       ## Validation
       - ✅ All tests passing
       - ✅ No regressions detected
       - ✅ Acceptance criteria met

       Linear: [Linear task URL]"
     ```

   - Alternative: Note PR URL for manual creation if CLI unavailable

6. Update Linear task:

   - Status: Completed
   - Add implementation notes
   - Link to branch: `lwisne/[task-id]-[feature-slug]`
   - Link to PR URL
   - Note base branch for future dependencies

7. Return to Step 4

### Step 6B: Subdivide Task

**Input:** Task requiring subdivision
**Output:** Subtasks in Linear

1. Identify logical subdivisions:

   - Separate backend from frontend
   - Split by architectural layers (model, view, controller)
   - Isolate complex algorithms
   - Separate test implementation

2. Create subtask criteria:

   - Each subtask should be completable in one context
   - Subtasks should have clear interfaces between them
   - Each should produce testable output

3. For each subtask, create Linear task:

```
Title: [PARENT_ID]-SUB-[N]: [Subtask Description]
Description:
- Parent: [Parent task ID]
- Scope: [Specific scope]
- Acceptance criteria: [Clear completion definition]
Labels: "subtask", "ready-for-development"
Project: [Same Project ID as parent]
```

4. Note: Subtasks will use the same feature branch as parent task

5. Update parent task:

   - Add label "has-subtasks"
   - Status: In Progress (Subdivided)
   - Link all subtasks

6. Return to Step 3 (re-prioritize with new subtasks)

### Step 7: Task Completion and Iteration

**Input:** Completed task
**Output:** Next task selection

Upon task completion:

1. Verify completion criteria:

   - All code implemented and tested
   - No blocking issues
   - Documentation updated
   - PR created against appropriate base branch

2. Update Linear:

   - Mark task as Done
   - Document PR URL
   - Document branch name for dependent features
   - If parent task exists, check if all siblings complete
   - If all subtasks done, mark parent as Done

3. Track branch dependencies:

   - Store completed branch name for future PRs
   - Update dependency map with branch information:
     ```
     FEATURE_001 → branch: lwisne/lwi-101-feature_001-user-authentication
     FEATURE_002 → depends on: FEATURE_001 branch
     ```

4. Update dependency map:

   - Remove completed task from blocking lists
   - Update priorities for unblocked tasks
   - Add "ready-for-development" label to newly unblocked tasks
   - Note base branch for newly unblocked tasks

5. Return to Step 4

## Context Management Guidelines

### When to Access External Context

- Beginning of each task: Re-read technical architecture
- Before implementation: Review existing patterns in codebase
- After subdivision: Refresh understanding of parent task

### What to Document in Linear

- Implementation decisions
- Interface definitions between subtasks
- Any deviations from architecture patterns
- Blocking issues or questions
- Feature branch name for reference
- PR URL once created
- Base branch used for PR (important for dependencies)

### Signs You're Losing Context

- Forgetting the task's original purpose
- Unsure about architectural patterns
- Cannot remember parent task requirements
- Contradicting earlier decisions

**If context is lost:** Stop, document current state in Linear, and restart from Step 4.

## Error Recovery

### If a task fails:

1. Document failure reason in Linear
2. Assess if it's a subdivision issue
3. If yes, mark as "needs-subdivision" and return to Step 6B
4. If no, add "blocked" label with explanation

### If dependencies were incorrect:

1. Update dependency map
2. Re-run Step 3 for all pending tasks
3. May need to rollback completed work

## Success Metrics

Track these in Linear for process improvement:

- Average subdivisions per feature
- Features completed without subdivision
- Context losses per feature
- Dependency corrections needed

## Example Execution

```
PRD: "Build a task management system"

Step 0: Create Linear Project
- Name: "Task Management System"
- ID: PROJ-789

Step 1 Output:
FEATURE_001: User Authentication
FEATURE_002: Task CRUD Operations
FEATURE_003: Task Assignment System

Step 2: Create Linear tasks in Project PROJ-789
[Created: LWI-101, LWI-102, LWI-103]

Step 3: Dependency Analysis:
- FEATURE_002 depends on FEATURE_001 (need users to own tasks)
- FEATURE_003 depends on FEATURE_001, FEATURE_002

Priority: FEATURE_001 (Priority 1)

Step 4: Selected FEATURE_001 (LWI-101)
Created branch: lwisne/lwi-101-feature_001-user-authentication

Step 5: Evaluation → Decision: Implement directly

Step 6A: Implementation
- Completed feature on branch lwisne/lwi-101-feature_001-user-authentication
- Created PR: lwisne/lwi-101-feature_001-user-authentication → main
- PR URL: https://github.com/owner/repo/pull/123

Step 7: Update dependencies
- FEATURE_001 complete, branch documented
- FEATURE_002 now ready (will PR against lwi-101 branch)

Step 4: Selected FEATURE_002 (LWI-102)
Created branch: lwisne/lwi-102-feature_002-task-crud-operations

Step 6A: Implementation
- Completed feature on branch lwisne/lwi-102-feature_002-task-crud-operations
- Created PR: lwisne/lwi-102-feature_002-task-crud-operations → lwisne/lwi-101-feature_001-user-authentication
- PR URL: https://github.com/owner/repo/pull/124

Continue...
```

## Branch Strategy Diagram

```
main
  ↑
  | PR #123
  |
lwisne/lwi-101-feature_001-user-authentication
  ↑
  | PR #124
  |
lwisne/lwi-102-feature_002-task-crud-operations
  ↑
  | PR #125
  |
lwisne/lwi-103-feature_003-task-assignment-system
```

Each feature branch builds upon its dependencies, creating a chain of PRs that can be reviewed and merged in sequence.

---

_Note: This workflow is designed to work within Claude Code's context limitations. Always prioritize maintaining context over speed of implementation._
