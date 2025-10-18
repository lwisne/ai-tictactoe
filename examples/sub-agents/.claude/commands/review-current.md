Review the current branch changes following the standard review workflow:

1. **Run Tests First:**
   - Execute `fvm flutter test`
   - If ANY tests fail, STOP and report failures
   - Do NOT proceed to reviews if tests are failing

2. **Launch Reviewers in Parallel:**
   - ALWAYS launch code-reviewer agent to review code quality and correctness
   - Analyze the changes and conditionally launch:
     - architecture-guardian: if changes include new patterns, data models, or significant refactoring
     - ux-design-reviewer: if changes include user-facing UI or UX flows

3. **Aggregate Results:**
   - Collect findings from all reviewers
   - Categorize issues by severity
   - Provide actionable recommendations

4. **Report:**
   - Summary of all reviewer findings
   - List of required fixes (if any)
   - Approval status (ready to push / needs fixes)

Run all applicable reviewers in parallel for efficiency.
