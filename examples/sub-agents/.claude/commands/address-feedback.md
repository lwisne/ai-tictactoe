---
description: Address PR feedback for a Linear task (Workflow Step 7)
args:
  - name: pr_number
    description: The PR number to address feedback for
    required: true
---

Address feedback for PR #$1 following Workflow Step 7:

1. **Fetch PR Comments:**
   - Use `gh pr view $1 --comments` to view all comments
   - Identify feedback that needs to be addressed
   - Summarize the feedback for the user

2. **If Feedback Requires Code Changes:**
   - Use linear-task-implementer agent to address the feedback
   - Run code-tester agent to verify tests still pass
   - Re-run code-reviewer agent if significant changes
   - Commit changes with clear message referencing PR feedback
   - Push updates to the PR branch

3. **If Feedback is Minor/Non-Code:**
   - Update PR description if needed: `gh pr edit $1 --body "..."`
   - Add clarifying comments: `gh pr comment $1 --body "..."`

4. **Verification:**
   - Run full test suite: `fvm flutter test`
   - Format code: `dart format lib test`
   - Verify all feedback addressed

5. **Report Status:**
   - Summarize what was addressed
   - Confirm PR is ready for re-review
   - Provide updated PR link

IMPORTANT: Always stay on the PR's feature branch. Do NOT merge or switch branches.
