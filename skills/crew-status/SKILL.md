---
name: crew-status
description: "This skill shows the current Claude Crew pipeline status and development progress. Triggers on: '/crew-status', 'what is the status', 'where are we', 'show progress'."
allowed-tools: ["Read", "Glob"]
---

# crew-status: Status Dashboard

Display the current state of the Claude Crew pipeline.

## Process

### Step 1: Check for Crew State

If `.crew/` directory doesn't exist:
"No Claude Crew pipeline found in this project. Run `/crew-run` or `/crew-idea` to start."

### Step 2: Read State Files

Read these files (skip if they don't exist):
1. `.crew/state.md` — pipeline status
2. `.crew/tasks.md` — task completion
3. `.crew/log.md` — last 5 entries only (tail)
4. Use Glob to check `.crew/reviews/` — count review files
5. Use Glob to check `.crew/feedback/` — count feedback files
6. Use Glob to check `.crew/tests/` — count test files

### Step 3: Display Dashboard

Present a clean dashboard:

```text
== Claude Crew Status ==

Project: [name]
Goal: [goal]
Stack: [stack]
Started: [date]

Pipeline:
  [x] Idea       — Requirements crystallized
  [x] Plan       — N phases, M tasks
  [>] Build      — 5/12 tasks complete
  [ ] Review     — N review cycles so far
  [ ] Feedback   — N feedback cycles so far
  [ ] Test
  [ ] Deploy

Current: Building — [current task description]
Blocker: [none or description]

Metrics:
  Review cycles: [N]
  Feedback cycles: [N]
  Fix cycles: [N]

Recent Activity:
  [timestamp] Builder — Implemented auth module
  [timestamp] Reviewer — APPROVED with 0 issues
  [timestamp] Critic — APPROVED, all requirements met
  [timestamp] Builder — Implemented user API
```

Use `[x]` for completed, `[>]` for in-progress, `[ ]` for pending.

### Step 4: Suggest Next Action

Based on current stage, suggest what to do next:
- If in idea: "Run `/crew-plan` to design architecture"
- If in plan: "Run `/crew-build` to start implementing"
- If in build: "Run `/crew-build` to continue, or `/crew-test` if all tasks done"
- If in test: "Run `/crew-deploy` to ship"
- If all done: "Pipeline complete! Check `.crew/report.md` for the full report."
