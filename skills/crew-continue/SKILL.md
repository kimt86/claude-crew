---
name: crew-continue
description: "This skill resumes an interrupted Claude Crew pipeline. Use when context was reset, session restarted, or work was interrupted. Triggers on: '/crew-continue', 'resume work', 'continue where we left off'."
argument-hint: [optional specific instructions]
allowed-tools: ["Read", "Write", "Glob", "Grep", "Bash", "Agent"]
---

# crew-continue: Resume Interrupted Work

You are the **Supervisor** of Claude Crew. Resume the pipeline from where it was interrupted.

## Input

`$ARGUMENTS`: Optional specific instructions for what to do next

## Prerequisites

`.crew/state.md` must exist. If not found:
"No Crew state found. Nothing to resume. Run `/crew-run` or `/crew-idea` to start a new pipeline."

## Process

### Step 1: Read State (in order)

1. `.crew/state.md` — Overall progress, current stage
2. Based on current stage, read relevant files:
   - **idea**: state.md is sufficient
   - **plan**: `.crew/plan.md`, `.crew/tasks.md`
   - **build**: `.crew/plan.md`, `.crew/tasks.md`, `.crew/build-result.md`, latest review in `.crew/reviews/`
   - **test**: `.crew/tasks.md`, latest test in `.crew/tests/`
   - **deploy**: `.crew/deploy-result.md`
3. `.crew/log.md` — Last 10 entries only (recent context)
4. `.crew/decisions.md` — Last 5 entries (if exists)

### Step 2: Status Report

Report to user:
- Current stage
- What's completed vs remaining
- What was last worked on (from log.md)
- Any blockers

### Step 3: Resume

If `$ARGUMENTS` provides specific instructions, follow them.

Otherwise, auto-resume based on current stage:

| Current Stage | Action |
|---------------|--------|
| idea (incomplete) | Continue idea discussion with user |
| plan | Spawn crew-planner |
| build | Spawn crew-builder for next task, then crew-reviewer |
| review (NEEDS_FIX pending) | Spawn crew-builder with fix feedback |
| test | Spawn crew-tester |
| test (FAIL pending) | Spawn crew-planner for analysis, then crew-builder, then crew-tester |
| deploy | Spawn crew-deployer |

Follow the same gate and loop logic as `/crew-run` for the resumed phase.

### Step 4: Log

Launch **crew-logger** in background:
```
Agent tool → crew-logger (run_in_background: true)
Prompt: "Pipeline resumed from [stage]. Update .crew/log.md."
```
