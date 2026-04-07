# Claude Crew

A multi-agent development pipeline for Claude Code. One command takes your idea from concept to deployment using a crew of specialized AI agents.

## What is Claude Crew?

Claude Crew orchestrates **6 specialized agents** that work in separate contexts — each with independent thinking and focused responsibilities:

| Agent | Role | Superpower |
|-------|------|------------|
| **Planner** | Architect | Designs architecture, creates task breakdown |
| **Builder** | Developer | Writes production-quality code |
| **Reviewer** | Code reviewer | Reviews with fresh eyes (no Write access) |
| **Tester** | QA engineer | Runs and generates tests |
| **Deployer** | DevOps | Commits, pushes, creates PRs |
| **Logger** | Tech writer | Documents everything (runs in background) |

A **Supervisor** (the main session) orchestrates the crew, talks with you, and manages the pipeline.

## The Pipeline

```
/crew-run "build a todo app with React"

  Idea ──→ Plan ──→ Build ⟷ Review ──→ Test ──→ Deploy
   │         │         │        │         │         │
   You    Planner   Builder  Reviewer  Tester   Deployer
   talk    designs   codes    reviews   tests    ships
   with    arch.     it up    with      and      to
   Supervisor              fresh eyes  fixes    production
```

### Gates (you stay in control)

The pipeline pauses for your approval at 3 key points:
1. **After Idea** — "Are these requirements right?"
2. **After Plan** — "Approve this architecture?"
3. **After Tests Pass** — "Ready to deploy?"

Everything else runs automatically, including the Builder↔Reviewer fix loop and the Tester→Planner→Builder fix loop.

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
| Agents (6) | `crew-planner`, `crew-builder`, `crew-reviewer`, `crew-tester`, `crew-deployer`, `crew-logger` | `agents/crew-*.md` |

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
- Agents can run in parallel (Builder + Logger)
- Each agent has restricted tools (Reviewer can't write code)

### File-Based Communication

Agents communicate through `.crew/` files:

```
.crew/
  state.md          ← Pipeline status (all agents read)
  plan.md           ← Architecture (Planner writes, others read)
  tasks.md          ← Task checklist (Planner creates, Builder updates)
  build-result.md   ← Build output (Builder writes, Reviewer reads)
  reviews/          ← Review feedback (Reviewer → Builder)
  tests/            ← Test results (Tester → Planner)
  log.md            ← Full development log (Logger maintains)
  report.md         ← Final project report
```

### Build ↔ Review Loop

```
Builder implements → Reviewer reviews
                          │
            APPROVED? ────┤
            │              │
           Yes          NEEDS_FIX
            │              │
        Next task    Builder fixes → Reviewer re-reviews
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
