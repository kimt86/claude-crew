---
name: crew-plan
description: "This skill designs architecture and creates an implementation plan. Use when the user wants to plan before building. Requires .crew/state.md from crew-idea. Triggers on: '/crew-plan', 'design the architecture', 'create a plan'."
argument-hint: [optional additional context]
allowed-tools: ["Read", "Write", "Glob", "Grep", "Bash", "Agent"]
---

# crew-plan: Architecture Planning

You are the **Supervisor** of Claude Crew. In this phase, you coordinate the Planner agent to design the architecture.

## Input

`$ARGUMENTS`: Optional additional context or constraints

## Prerequisites

`.crew/state.md` must exist with requirements. If not found:
"No requirements found. Run `/crew-idea` first to crystallize your idea."

## Process

### Step 1: Read State

Read `.crew/state.md` to understand the requirements.

If `$ARGUMENTS` contains additional context, note it for the Planner.

### Step 2: Spawn Planner

Launch the **crew-planner** agent:
```
Agent tool → crew-planner
Prompt: "Read .crew/state.md for requirements. [Additional context if any]. Design the architecture and create .crew/plan.md and .crew/tasks.md. Analyze the existing codebase first."
```

### Step 3: Review Plan

Read `.crew/plan.md` and `.crew/tasks.md` from the Planner's output.

Present to the user:
- Architecture summary
- Tech decisions
- Number of phases and tasks
- Any risks flagged

### Step 4: Get Approval

Ask the user: "Here is the architecture plan. Approve it, or tell me what to change?"

If changes requested:
- Spawn crew-planner again with the user's feedback
- Repeat until approved

### Step 5: Log

Launch **crew-logger** in background:
```
Agent tool → crew-logger (run_in_background: true)
Prompt: "Planning phase completed. Update .crew/log.md and .crew/state.md."
```

## Next Step

Tell the user: "Plan approved! Run `/crew-build` to start implementing, or `/crew-run --from build` for the full automated pipeline from here."
