Complete the current task and prepare for push:

1. **Pre-Push Checks:**
   - Identify parent epic branch from current branch name
   - Merge parent epic: `git merge origin/{parent-epic-branch}`
   - Resolve any merge conflicts if needed

2. **Final Testing:**
   - Run full test suite: `fvm flutter test`
   - If ANY test fails, STOP and report failures
   - Must have 100% passing tests to continue

3. **Code Formatting:**
   - Format all code: `dart format lib test`
   - Show any files that were reformatted

4. **Push and PR:**
   - Push to origin: `git push origin {current-branch}`
   - Create PR using: `gh pr create --base {parent-epic-branch}`
   - PR body should include:
     - Implementation summary
     - Test coverage confirmation
     - Review outcomes (if reviews were done)
     - Link to Linear task

5. **Report:**
   - PR URL
   - Summary of what was pushed
   - Next steps (monitor PR comments)

STOP immediately if tests fail or merge conflicts occur.
