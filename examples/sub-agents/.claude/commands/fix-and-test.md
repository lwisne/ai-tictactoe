Fix issues and verify with tests in a loop:

1. **Launch linear-task-implementer agent:**
   - Context: $1 (describe what needs fixing)
   - Fix the identified issues
   - Ensure code follows Clean Architecture
   - Return summary of changes made

2. **Launch code-tester agent:**
   - Run full test suite with `fvm flutter test`
   - Verify all tests pass
   - Check test coverage
   - Report results

3. **Evaluate:**
   - If tests pass: report success and ready for review
   - If tests fail: explain failures and ask if should loop again

This command implements a single fix-test cycle. Provide description of what needs fixing as $1.
