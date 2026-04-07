#!/bin/bash
set -euo pipefail

# Claude Crew Installer
# Multi-agent development pipeline for Claude Code

REPO_BASE="https://raw.githubusercontent.com/kimt86/claude-crew/main"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Defaults
INSTALL_MODE="global"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --project) INSTALL_MODE="project" ;;
    --help|-h)
      echo "Claude Crew Installer"
      echo ""
      echo "Usage: curl -fsSL $REPO_BASE/install.sh | bash [-s -- OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --project    Install to current project (.claude/) instead of global (~/.claude/)"
      echo "  --help       Show this help"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

# Set install paths
if [ "$INSTALL_MODE" = "project" ]; then
  SKILLS_DIR=".claude/skills"
  AGENTS_DIR=".claude/agents"
  echo -e "${CYAN}Installing Claude Crew to current project...${NC}"
else
  SKILLS_DIR="$HOME/.claude/skills"
  AGENTS_DIR="$HOME/.claude/agents"
  echo -e "${CYAN}Installing Claude Crew globally...${NC}"
fi

# Create directories
mkdir -p "$AGENTS_DIR"

SKILLS=(crew-run crew-idea crew-plan crew-build crew-test crew-deploy crew-status crew-continue)
AGENTS=(crew-planner crew-builder crew-reviewer crew-tester crew-deployer crew-logger)

# Download skills
echo -e "${YELLOW}Downloading skills...${NC}"
for skill in "${SKILLS[@]}"; do
  mkdir -p "$SKILLS_DIR/$skill"
  curl -fsSL "$REPO_BASE/skills/$skill/SKILL.md" -o "$SKILLS_DIR/$skill/SKILL.md"
  echo -e "  ${GREEN}+${NC} $skill"
done

# Download agents
echo -e "${YELLOW}Downloading agents...${NC}"
for agent in "${AGENTS[@]}"; do
  curl -fsSL "$REPO_BASE/agents/$agent.md" -o "$AGENTS_DIR/$agent.md"
  echo -e "  ${GREEN}+${NC} $agent"
done

echo ""
echo -e "${GREEN}Claude Crew installed successfully!${NC}"
echo ""
echo "Skills installed: ${#SKILLS[@]}"
echo "Agents installed: ${#AGENTS[@]}"
echo ""
echo -e "Location:"
echo -e "  Skills: $SKILLS_DIR/crew-*"
echo -e "  Agents: $AGENTS_DIR/crew-*"
echo ""
echo -e "${CYAN}Quick start:${NC}"
echo '  /crew-run "describe what you want to build"'
echo ""
echo -e "${CYAN}Individual commands:${NC}"
echo "  /crew-idea     Crystallize an idea"
echo "  /crew-plan     Design architecture"
echo "  /crew-build    Implement with review loop"
echo "  /crew-test     Run tests"
echo "  /crew-deploy   Commit, push, deploy"
echo "  /crew-status   Check progress"
echo "  /crew-continue Resume interrupted work"

# Check for gstack
if [ -d "$HOME/.claude/skills/gstack" ]; then
  echo ""
  echo -e "${GREEN}gstack detected!${NC} Claude Crew will use gstack skills for enhanced reviews, planning, and testing."
fi
