#!/usr/bin/env bash
# vibe-hardener installer
# Detects AI agents you use and places the skill in every right location.
# Usage: bash install.sh [target-project-dir]
# Default: installs into current directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-$(pwd)}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  🔩 vibe-hardener installer${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Target: ${YELLOW}${PROJECT_DIR}${NC}"
echo ""

# ─────────────────────────────────────────────────────────
# 1. CLAUDE CODE
# ─────────────────────────────────────────────────────────
echo -e "${BLUE}[1/6]${NC} Claude Code..."
CLAUDE_SKILL_DIR="${PROJECT_DIR}/.claude/skills/vibe-hardener"
mkdir -p "$CLAUDE_SKILL_DIR"
cp "${SCRIPT_DIR}/SKILL.md" "${CLAUDE_SKILL_DIR}/SKILL.md"
echo -e "  ${GREEN}✓${NC} .claude/skills/vibe-hardener/SKILL.md"

if [ ! -f "${PROJECT_DIR}/CLAUDE.md" ]; then
  cp "${SCRIPT_DIR}/templates/CLAUDE.md" "${PROJECT_DIR}/CLAUDE.md"
  echo -e "  ${GREEN}✓${NC} CLAUDE.md (from template — customize it)"
else
  echo -e "  ${YELLOW}⚠${NC} CLAUDE.md exists — not overwritten (add skill reference manually)"
fi

# ─────────────────────────────────────────────────────────
# 2. AGENTS.md (Codex CLI, OpenCode, generic)
# ─────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}[2/6]${NC} Codex CLI / Generic (AGENTS.md)..."
if [ ! -f "${PROJECT_DIR}/AGENTS.md" ]; then
  cp "${SCRIPT_DIR}/templates/AGENTS.md" "${PROJECT_DIR}/AGENTS.md"
  echo -e "  ${GREEN}✓${NC} AGENTS.md (from template — customize it)"
else
  echo -e "  ${YELLOW}⚠${NC} AGENTS.md exists — not overwritten"
fi

# ─────────────────────────────────────────────────────────
# 3. CURSOR
# ─────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}[3/6]${NC} Cursor..."
CURSOR_DIR="${PROJECT_DIR}/.cursor/rules"
mkdir -p "$CURSOR_DIR"
cp "${SCRIPT_DIR}/.cursor/rules/vibe-hardener.mdc" "${CURSOR_DIR}/vibe-hardener.mdc"
echo -e "  ${GREEN}✓${NC} .cursor/rules/vibe-hardener.mdc"

# ─────────────────────────────────────────────────────────
# 4. GITHUB COPILOT
# ─────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}[4/6]${NC} GitHub Copilot..."
GITHUB_DIR="${PROJECT_DIR}/.github"
mkdir -p "$GITHUB_DIR"
if [ ! -f "${GITHUB_DIR}/copilot-instructions.md" ]; then
  cp "${SCRIPT_DIR}/templates/copilot-instructions.md" "${GITHUB_DIR}/copilot-instructions.md"
  echo -e "  ${GREEN}✓${NC} .github/copilot-instructions.md"
else
  echo -e "  ${YELLOW}⚠${NC} .github/copilot-instructions.md exists — not overwritten"
fi

# ─────────────────────────────────────────────────────────
# 5. WINDSURF
# ─────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}[5/6]${NC} Windsurf..."
if [ ! -f "${PROJECT_DIR}/.windsurfrules" ]; then
  grep -v "^---$\|^description:\|^globs:\|^alwaysApply:" \
    "${SCRIPT_DIR}/.cursor/rules/vibe-hardener.mdc" \
    > "${PROJECT_DIR}/.windsurfrules"
  echo -e "  ${GREEN}✓${NC} .windsurfrules"
else
  echo -e "  ${YELLOW}⚠${NC} .windsurfrules exists — not overwritten"
fi

# ─────────────────────────────────────────────────────────
# 6. GEMINI CLI
# ─────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}[6/6]${NC} Gemini CLI..."
if [ ! -f "${PROJECT_DIR}/GEMINI.md" ]; then
  cp "${SCRIPT_DIR}/templates/AGENTS.md" "${PROJECT_DIR}/GEMINI.md"
  echo -e "  ${GREEN}✓${NC} GEMINI.md"
else
  echo -e "  ${YELLOW}⚠${NC} GEMINI.md exists — not overwritten"
fi

# ─────────────────────────────────────────────────────────
# EXTRAS
# ─────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}[+]${NC} Checklists and specs directory..."

CHECKLIST_DIR="${PROJECT_DIR}/checklists"
if [ ! -d "$CHECKLIST_DIR" ]; then
  mkdir -p "$CHECKLIST_DIR"
  cp "${SCRIPT_DIR}/checklists/"*.md "$CHECKLIST_DIR/"
  echo -e "  ${GREEN}✓${NC} checklists/ (audit.md, security.md, pre-deploy.md)"
else
  echo -e "  ${YELLOW}⚠${NC} checklists/ exists — not overwritten"
fi

SPECS_DIR="${PROJECT_DIR}/specs"
if [ ! -d "$SPECS_DIR" ]; then
  mkdir -p "$SPECS_DIR"
  cat > "${SPECS_DIR}/.gitkeep" << 'GITKEEP'
# specs/
# Feature specifications live here.
# Format: YYYY-MM-DD-feature-name.md
# Always write a spec before implementing a feature.
# Generate with: /vibe-hardener spec "description"
GITKEEP
  echo -e "  ${GREEN}✓${NC} specs/ directory created"
fi

# ─────────────────────────────────────────────────────────
# SUMMARY
# ─────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✓ Installation complete${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Installed for:"
echo "    Claude Code    → .claude/skills/vibe-hardener/SKILL.md"
echo "    Codex / Any    → AGENTS.md"
echo "    Cursor         → .cursor/rules/vibe-hardener.mdc"
echo "    GitHub Copilot → .github/copilot-instructions.md"
echo "    Windsurf       → .windsurfrules"
echo "    Gemini CLI     → GEMINI.md"
echo ""
echo "  Also created:"
echo "    checklists/    → audit.md, security.md, pre-deploy.md"
echo "    specs/         → for feature specifications"
echo ""
echo -e "${YELLOW}  Next steps:${NC}"
echo "    1. Customize AGENTS.md / CLAUDE.md for your project"
echo "    2. In Claude Code: /vibe-hardener audit"
echo "    3. Before any new feature: /vibe-hardener spec [description]"
echo "    4. Before every deploy: checklists/pre-deploy.md"
echo ""
echo "  Full SOP: SOP.md"
echo "  Ecosystem reference: docs/ecosystem.md"
echo ""
