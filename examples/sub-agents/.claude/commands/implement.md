Implement Linear task $1 following the complete workflow:

1. **Setup Phase:**
   - Fetch Linear task $1 details (team: "Lwisne")
   - Identify parent epic branch from task description
   - Checkout parent epic branch and pull latest
   - Create feature branch: lwisne/$1-{description-from-linear}

2. **Implementation Phase:**
   - Launch linear-task-implementer agent to:
     - Implement ALL acceptance criteria from Linear task
     - Follow Clean Architecture patterns
     - Create all necessary files and tests
     - Return summary of changes

3. **Testing Phase:**
   - Launch code-tester agent to:
     - Run full test suite with `fvm flutter test`
     - Verify test coverage meets standards
     - Report any failures or coverage gaps
   - If tests fail: re-run linear-task-implementer to fix, then re-test
   - Do NOT proceed until all tests pass

4. **Review Phase (run in parallel):**
   - ALWAYS launch code-reviewer agent
   - Conditionally launch based on task:
     - architecture-guardian: if new patterns, data models, or significant refactoring
     - ux-design-reviewer: if user-facing UI or PRD-specified UX requirements
   - If ANY reviewer finds issues: fix with linear-task-implementer, re-test, then re-run ONLY failing reviewers

5. **Pre-Push Phase:**
   - Merge parent epic branch: `git merge origin/{parent-epic-branch}`
   - Run full test suite again: `fvm flutter test`
   - Format code: `dart format lib test`
   - Report readiness status

Report progress at each phase and stop if any phase fails. Provide clear next steps.
