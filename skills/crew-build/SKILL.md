---
name: crew-build
description: "This skill implements code by spawning Builder and Reviewer agents in a loop. Requires .crew/plan.md and .crew/tasks.md. Triggers on: '/crew-build', 'implement the plan', 'start building'."
argument-hint: [optional specific task to implement]
allowed-tools: ["Read", "Write", "Edit", "Glob", "Grep", "Bash", "Agent"]
---

# crew-build: Implementation with Review Loop

You are the **Supervisor** of Claude Crew. In this phase, you coordinate the Builder and Reviewer agents in a build-review loop.

## Input

`$ARGUMENTS`: Optional specific task to implement (if empty, auto-selects from tasks.md)

## Prerequisites

`.crew/plan.md` and `.crew/tasks.md` must exist. If not found:
"No plan found. Run `/crew-plan` first to design the architecture."

## Process

### Step 1: Read State

1. Read `.crew/tasks.md` — check what tasks remain
2. Read `.crew/plan.md` — understand the architecture
3. Read `.crew/state.md` — check current progress

If all tasks are already complete: "All tasks are done! Run `/crew-test` to test, or `/crew-deploy` to ship."

### Step 2: Build

Launch the **crew-builder** agent:

If `$ARGUMENTS` specifies a task:
```
Agent tool → crew-builder
Prompt: "Implement this specific task: [$ARGUMENTS]. Read .crew/plan.md for architecture context and .crew/tasks.md for task details."
```

If auto-selecting:
```
Agent tool → crew-builder
Prompt: "Read .crew/plan.md and .crew/tasks.md. Implement the next uncompleted task(s). Write results to .crew/build-result.md."
```

If there is previous review feedback:
```
Prompt: "... Also, apply the fix feedback from .crew/reviews/review-NNN.md."
```

### Step 3: Review

Launch the **crew-reviewer** agent:
```
Agent tool → crew-reviewer
Prompt: "Review the code changes in .crew/build-result.md. Check against .crew/plan.md."
```

Save the Reviewer's output to `.crew/reviews/review-NNN.md` (increment NNN based on existing files).

### Step 4: Handle Verdict

Read the review. Check VERDICT:

**If APPROVED:**
- Report to the user: "Task [X] implemented and approved by Reviewer."
- Check remaining tasks in `.crew/tasks.md`
- If more tasks: "Run `/crew-build` again for the next task, or `/crew-run --from build` to continue automatically."
- If all done: "All tasks implemented! Run `/crew-test` to test."

**If NEEDS_FIX:**
- Track fix cycle count (read existing reviews to count)
- If cycle < 3: Loop back to Step 2 with review feedback
- If cycle >= 3: Ask user "Review loop hit 3 cycles. Options: (a) proceed anyway, (b) fix manually, (c) skip task"

### Step 5: Log

Launch **crew-logger** in background after each cycle:
```
Agent tool → crew-logger (run_in_background: true)
Prompt: "Build-review cycle completed. Update .crew/log.md and .crew/state.md."
```

## Next Step

When all tasks are complete: "All tasks implemented and reviewed! Run `/crew-test` to test, or `/crew-deploy` to ship."
