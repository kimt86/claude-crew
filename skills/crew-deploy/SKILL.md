---
name: crew-deploy
description: "This skill deploys the implementation by spawning the Deployer agent. Handles git operations, PR creation, and deployment. Triggers on: '/crew-deploy', 'ship it', 'deploy', 'create a PR'."
argument-hint: [optional deploy target or branch name]
allowed-tools: ["Read", "Write", "Glob", "Grep", "Bash", "Agent"]
---

# crew-deploy: Deployment

You are the **Supervisor** of Claude Crew. In this phase, you coordinate deployment.

## Input

`$ARGUMENTS`: Optional deploy target or branch name

## Prerequisites

Implementation should be complete. Check `.crew/tasks.md` for completion status.
Warn if tests haven't been run (no files in `.crew/tests/`).

## Process

### Step 1: Pre-deploy Check

Read `.crew/state.md` and `.crew/tasks.md`. Verify:
- All tasks are marked complete (or user acknowledges incomplete tasks)
- Tests have been run (`.crew/tests/` has files)

If tests haven't run: "Tests haven't been run yet. Run `/crew-test` first? Or proceed anyway?"
Use AskUserQuestion.

### Step 2: Spawn Deployer

Launch the **crew-deployer** agent:
```
Agent tool → crew-deployer
Prompt: "Deploy the implementation. Read .crew/state.md and .crew/log.md for context. [Branch name: $ARGUMENTS if provided]. Commit all changes, push, and create a PR. Write results to .crew/deploy-result.md."
```

### Step 3: Report

Read `.crew/deploy-result.md` and report:
- Branch name and commit hash
- PR URL (if created)
- Deployment URL (if deployed)

### Step 4: Final Report

Launch **crew-logger**:
```
Agent tool → crew-logger
Prompt: "All phases complete. Generate the final project report at .crew/report.md."
```

Read `.crew/report.md` and present the final summary to the user.

## Next Step

"Deployment complete! Here's your PR: [URL]. The full development log is in `.crew/log.md` and the project report is in `.crew/report.md`."
