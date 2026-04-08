# Claude Crew

A multi-agent development pipeline for Claude Code. One command takes your idea from concept to deployment using a crew of specialized AI agents.

## What is Claude Crew?

Claude Crew orchestrates **7 specialized agents** that work in separate contexts — each with independent thinking and focused responsibilities:

| Agent | Role | Superpower |
|-------|------|------------|
| **Planner** | Architect | Designs architecture, creates task breakdown |
| **Builder** | Developer | Writes production-quality code |
| **Reviewer** | Code reviewer | Reviews with fresh eyes (no Write access) |
| **Critic** | External feedback | Evaluates against requirements & completeness (no Write access) |
| **Tester** | QA engineer | Runs and generates tests |
| **Deployer** | DevOps | Commits, pushes, creates PRs |
| **Logger** | Tech writer | Documents everything (runs in background) |

A **Supervisor** (the main session) orchestrates the crew, talks with you, and manages the pipeline.

## The Pipeline

```
/crew-run "build a todo app with React"

  Idea ──→ Plan ──→ Build ⟷ Review ⟷ Feedback ──→ Test ──→ Deploy
   │         │         │        │         │           │         │
   You    Planner   Builder  Reviewer   Critic     Tester   Deployer
   talk    designs   codes    reviews   evaluates   tests    ships
   with    arch.     it up    code      against     and      to
   Supervisor              quality   requirements  fixes    production
```

### The Build-Review-Feedback Loop

Every implementation cycle goes through THREE independent agents:

```
Builder (implement) → Reviewer (code review) → Critic (external feedback)
        ↑                                              │
        └──────────── if issues found ─────────────────┘
                     (max 3 cycles)
```

1. **Builder** implements the task
2. **Reviewer** checks code quality, bugs, security (separate context — fresh eyes)
3. **Critic** evaluates against requirements, completeness, and real-world readiness (separate context — external perspective)

Only when BOTH Reviewer AND Critic approve does the task move forward.

### Gates (you stay in control)

The pipeline pauses for your approval at 3 key points:
1. **After Idea** — "Are these requirements right?"
2. **After Plan** — "Approve this architecture?"
3. **After Tests Pass** — "Ready to deploy?"

Everything else runs automatically, including the Builder↔Reviewer↔Critic feedback loop and the Tester→Planner→Builder fix loop.

## Install

### Quick Install (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/kimt86/claude-crew/main/install.sh | bash
```

This installs skills and agents **globally** to `~/.claude/`, making `/crew-*` commands available in all your projects.

### Project-Specific Install

```bash
curl -fsSL https://raw.githubusercontent.com/kimt86/claude-crew/main/install.sh | bash -s -- --project
```

Installs to `.claude/` in the current directory. Useful when you want crew configs scoped to a single project.

### Manual Install

```bash
git clone https://github.com/kimt86/claude-crew.git
cd claude-crew

# Copy to global
cp -r skills/crew-* ~/.claude/skills/
cp agents/crew-*.md ~/.claude/agents/

# Or copy to project
cp -r skills/crew-* .claude/skills/
cp agents/crew-*.md .claude/agents/
```

### What Gets Installed

| Type | Files | Location |
|------|-------|----------|
| Skills (8) | `crew-run`, `crew-idea`, `crew-plan`, `crew-build`, `crew-test`, `crew-deploy`, `crew-status`, `crew-continue` | `skills/crew-*/SKILL.md` |
| Agents (7) | `crew-planner`, `crew-builder`, `crew-reviewer`, `crew-critic`, `crew-tester`, `crew-deployer`, `crew-logger` | `agents/crew-*.md` |

### Uninstall

```bash
# Global
rm -rf ~/.claude/skills/crew-* ~/.claude/agents/crew-*

# Project
rm -rf .claude/skills/crew-* .claude/agents/crew-*
```

## Usage

### One Command (full pipeline)

```
/crew-run "build a REST API for a blog with auth"
```

### Individual Stages

```
/crew-idea "I want to build a CLI tool for..."    # Crystallize idea
/crew-plan                                         # Design architecture
/crew-build                                        # Implement next task
/crew-test                                         # Run tests
/crew-deploy                                       # Ship it
```

### Utilities

```
/crew-status      # Show pipeline progress dashboard
/crew-continue    # Resume interrupted work
```

### Partial Pipeline

```
/crew-run --from build            # Resume from build stage
/crew-run --to plan "my idea"     # Stop after planning
```

## How It Works

### True Multi-Agent (not role-playing)

Each agent runs in a **separate context** via Claude Code's Agent tool. This means:
- The Reviewer has never seen the Builder's thought process — genuinely fresh eyes
- The Critic evaluates independently from both Builder and Reviewer
- Agents can run in parallel (Builder + Logger)
- Each agent has restricted tools (Reviewer and Critic can't write code)

### Explicit Agent Spawning

Every skill file contains explicit instructions for the Supervisor to spawn agents via the Agent tool. The Supervisor NEVER writes code, reviews code, or tests code itself — it always delegates to the appropriate specialized agent. This ensures genuine multi-agent behavior, not single-agent role-playing.

### File-Based Communication

Agents communicate through `.crew/` files:

```
.crew/
  state.md          ← Pipeline status (all agents read)
  plan.md           ← Architecture (Planner writes, others read)
  tasks.md          ← Task checklist (Planner creates, Builder updates)
  build-result.md   ← Build output (Builder writes, Reviewer/Critic reads)
  reviews/          ← Code review feedback (Reviewer → Builder)
  feedback/         ← External feedback (Critic → Builder)
  tests/            ← Test results (Tester → Planner)
  log.md            ← Full development log (Logger maintains)
  report.md         ← Final project report
```

### Build ↔ Review ↔ Feedback Loop

```
Builder implements → Reviewer reviews → Critic evaluates
                                              │
                           BOTH APPROVED? ────┤
                           │                   │
                          Yes              Issues found
                           │                   │
                       Next task        Builder fixes → Reviewer → Critic
                                             (max 3 cycles)
```

### Test → Fix Loop

```
Tester runs tests
       │
    PASS? ────┐
    │          │
   Yes       FAIL
    │          │
  Deploy    Planner analyzes → Builder fixes → Tester re-tests
                                (max 3 cycles)
```

## Optional: gstack Integration

If [gstack](https://github.com/kimt86/gstack) is installed, Claude Crew automatically detects it and enhances agents:

| Agent | gstack Skill | Enhancement |
|-------|-------------|-------------|
| Planner | `/plan-eng-review` | 7-dimension architecture scoring |
| Reviewer | `/review` + `/cso` | Deep security audit |
| Tester | `/qa` | Structured QA scenarios |
| Deployer | `/ship` | Auto PR body generation |

No configuration needed — if gstack is present, it's used. If not, agents work standalone.

## Requirements

- [Claude Code](https://claude.ai/code) (CLI, VS Code, or JetBrains)
- Git (for deployment features)
- `gh` CLI (optional, for automatic PR creation)

## License

MIT
