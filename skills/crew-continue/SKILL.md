---
name: crew-continue
description: "This skill resumes an interrupted Claude Crew pipeline. Use when context was reset, session restarted, or work was interrupted. Triggers on: '/crew-continue', 'resume work', 'continue where we left off'."
argument-hint: [optional specific instructions]
allowed-tools: ["Read", "Write", "Glob", "Grep", "Bash", "Agent", "TodoWrite"]
---

# crew-continue: Resume Interrupted Work

You are the **Supervisor** of Claude Crew. Resume the pipeline from where it was interrupted.

---

## CRITICAL RULES

1. **You NEVER write code yourself.** ALWAYS spawn the appropriate agent via the Agent tool.
2. **Each agent is a separate Agent tool call** — real multi-agent, not role-playing.
3. **ALWAYS read state files first** to understand exactly where things left off.
4. **Resume with the SAME multi-agent flow** as crew-run (Builder → Reviewer → Critic loop).
5. **ALWAYS output progress messages** before spawning each agent and after reading results.
6. **ALWAYS restore TodoWrite** based on current pipeline state.

---

## Input

`$ARGUMENTS`: Optional specific instructions for what to do next

## Prerequisites

`.crew/state.md` must exist. If not found:
"No Crew state found. Nothing to resume. Run `/crew-run` or `/crew-idea` to start a new pipeline."

---

## Process

### Step 1: Read State (in order)

1. Read `.crew/state.md` — overall progress, current stage, blocker
2. Based on the current stage, read relevant files:

| Stage | Files to Read |
|-------|---------------|
| idea | state.md only |
| plan | state.md, plan.md (if exists), tasks.md (if exists) |
| build | state.md, plan.md, tasks.md, build-result.md, latest review in reviews/, latest feedback in feedback/ |
| test | state.md, tasks.md, latest test in tests/ |
| deploy | state.md, deploy-result.md |

3. Read `.crew/log.md` — last 10 entries only (for recent context)
4. Read `.crew/decisions.md` — last 5 entries (if exists)

### Step 2: Restore TodoWrite

**Call TodoWrite** based on current pipeline state. Read `.crew/state.md` pipeline checklist. For each stage, set the appropriate status:

- If `[x]` in state.md → status: `completed`
- If currently active stage → status: `in_progress`
- If not yet reached → status: `pending`

Use these labels (matching crew-run's structure):

Call TodoWrite with todos:
- { content: "Crystallize idea and requirements", activeForm: "Crystallizing idea and requirements", status: [based on state] }
- { content: "Design architecture and create task plan", activeForm: "Designing architecture and creating task plan", status: [based on state] }
- { content: "Build, review, and validate all tasks ([C]/[M] complete)", activeForm: "Building, reviewing, and validating tasks", status: [based on state] }
- { content: "Run tests and fix failures", activeForm: "Running tests and fixing failures", status: [based on state] }
- { content: "Deploy to production", activeForm: "Deploying to production", status: [based on state] }
- { content: "Generate final report", activeForm: "Generating final report", status: [based on state] }

For the build item, read tasks.md and count completed [x] vs total tasks to fill in [C]/[M].

### Step 3: Status Report

**Output to user:**

> 🔄 **Resuming Claude Crew Pipeline**
>
> | Status | Detail |
> |--------|--------|
> | Current stage | [stage] |
> | Completed | [list of completed stages] |
> | Remaining | [list of remaining stages] |
> | Last activity | [from log.md] |
> | Blocker | [any blocker, or "none"] |

### Step 4: Resume

If `$ARGUMENTS` provides specific instructions, follow them.

Otherwise, auto-resume based on current stage:

**idea (incomplete):**
- Continue idea discussion with user directly

**plan:**

**Output to user:**

> ▶️ **Planner** — Designing architecture...

- description: "Plan architecture"
- prompt: "You are the Planner of Claude Crew. Read .crew/state.md for requirements. Analyze the existing codebase. Design architecture and write .crew/plan.md and .crew/tasks.md. Report: summary, phase/task counts, decisions, risks."

**build:**
- Check tasks.md for remaining tasks
- Check latest review/feedback for pending NEEDS_FIX/NEEDS_IMPROVEMENT

If fix pending:

**Output to user:**

> ▶️ **Builder** — Fixing issues from previous review...

- description: "Fix review issues"
- prompt: "You are the Builder of Claude Crew. Fix issues from the previous review. Read the latest .crew/reviews/review-NNN.md and latest .crew/feedback/feedback-NNN.md for issues. Read .crew/plan.md and .crew/tasks.md for context. Fix all CRITICAL/HIGH issues. Run verification. Update .crew/build-result.md."

Then continue with Reviewer → Critic (same flow as crew-build).

If no fix pending:

**Output to user:**

> ▶️ **Builder** — Implementing next task...

Spawn Builder for next uncompleted task, then follow full Builder → Reviewer → Critic loop.

**test:**

**Output to user:**

> ▶️ **Tester** — Running tests...

- description: "Test implementation"
- prompt: "You are the Tester of Claude Crew. Read .crew/plan.md, .crew/tasks.md, .crew/build-result.md. Detect test framework. Run existing tests and generate missing ones. Write results to .crew/tests/test-NNN.md."

**test (FAIL pending):**

**Output to user:**

> 🔄 Resuming test fix loop...

Spawn Planner to analyze → Builder to fix → Tester to re-test (same as crew-test fix loop, with progress messages).

**deploy:**

**Output to user:**

> ▶️ **Deployer** — Deploying...

- description: "Deploy implementation"
- prompt: "You are the Deployer of Claude Crew. Read .crew/state.md, .crew/plan.md, .crew/build-result.md, .crew/log.md. Pre-flight check, create branch if needed, stage and commit, push, create PR, deploy if config exists. Write .crew/deploy-result.md. NEVER force push, NEVER commit secrets or .crew/."

Follow the same gate and loop logic as `/crew-run` for the resumed phase. Use progress emoji consistently (`▶️` before spawn, `✅`/`⚠️` after result).

### Step 5: Log

**Output to user:**

> 📝 Logging pipeline resume...

Spawn the Logger in the background:

- description: "Log pipeline resume"
- prompt: "You are the Logger of Claude Crew. Pipeline was resumed from [stage]. Read relevant .crew/ files. Append a 'Pipeline Resumed' entry to .crew/log.md with: which stage was resumed, current state, what's next. Update .crew/state.md current section."
- run_in_background: true
