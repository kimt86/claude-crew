---
name: crew-test
description: "This skill tests the implementation by spawning the Tester agent. Handles test failures with Planner→Builder fix loops. Triggers on: '/crew-test', 'run tests', 'test the implementation'."
argument-hint: [optional specific test focus]
allowed-tools: ["Read", "Write", "Glob", "Grep", "Bash", "Agent"]
---

# crew-test: Testing with Fix Loop

You are the **Supervisor** of Claude Crew. In this phase, you coordinate testing and fix loops if tests fail.

## Input

`$ARGUMENTS`: Optional specific area to focus testing on

## Prerequisites

`.crew/build-result.md` should exist (something was built). If not found:
"No build results found. Run `/crew-build` first."

## Process

### Step 1: Spawn Tester

Launch the **crew-tester** agent:
```
Agent tool → crew-tester
Prompt: "Test the implementation. Read .crew/plan.md for expected behavior and .crew/build-result.md for what was built. [Focus on: $ARGUMENTS if provided]. Run existing tests and generate missing ones. Write results to .crew/tests/test-NNN.md."
```

### Step 2: Read Results

Read the test result file. Check status:

**If PASS:**
- Report to user: "All tests pass! [N] tests total, [M] new tests written."
- "Run `/crew-deploy` to ship, or `/crew-run --from deploy` to deploy."

**If FAIL:**
- Report failures to user: "[N] tests failed. Starting fix loop..."
- Proceed to Step 3

### Step 3: Fix Loop (max 3 cycles)

**3a. Analyze**: Launch **crew-planner**:
```
Agent tool → crew-planner
Prompt: "Tests failed. Read .crew/tests/test-NNN.md for failure details. Determine if these are code bugs or plan issues. If code bugs, add fix tasks to .crew/tasks.md. If plan issues, update .crew/plan.md."
```

**3b. Fix**: Launch **crew-builder**:
```
Agent tool → crew-builder
Prompt: "Fix the test failures. Read the latest .crew/tests/test-NNN.md and .crew/tasks.md for fix tasks."
```

**3c. Re-test**: Launch **crew-tester** again:
```
Agent tool → crew-tester
Prompt: "Re-test after fixes. Run all tests. Write results to .crew/tests/test-NNN.md."
```

**3d. Check result**:
- If PASS: report success, proceed
- If FAIL and cycle < 3: loop back to 3a
- If FAIL and cycle >= 3: Ask user "Tests still failing after 3 fix cycles. Options: (a) I'll fix manually, (b) deploy anyway (not recommended), (c) show me the failures"

### Step 4: Log

Launch **crew-logger** in background:
```
Agent tool → crew-logger (run_in_background: true)
Prompt: "Test phase completed. Update .crew/log.md and .crew/state.md."
```

## Next Step

"Tests passing! Run `/crew-deploy` to commit and ship."
