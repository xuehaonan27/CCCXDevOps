#!/bin/bash
# CCCXDevOps Installer
# Copies skills and optionally scripts to Claude Code directories.
# Usage: bash install.sh [--with-scripts]
#
# Safe to re-run: cleans target directories before copying.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_TARGET="$HOME/.claude/skills"
SCRIPTS_TARGET="$HOME/.claude/scripts"

WITH_SCRIPTS=false

for arg in "$@"; do
    case "$arg" in
        --with-scripts) WITH_SCRIPTS=true ;;
        --help|-h)
            echo "Usage: bash install.sh [--with-scripts]"
            echo ""
            echo "Options:"
            echo "  --with-scripts   Also copy support scripts to ~/.claude/scripts/"
            echo "  --help, -h       Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Run 'bash install.sh --help' for usage."
            exit 1
            ;;
    esac
done

echo "=== CCCXDevOps Installer ==="
echo ""

# Step 1: Copy skills (clean before copy to prevent nesting)
echo "[1/3] Copying skills to $SKILLS_TARGET ..."
mkdir -p "$SKILLS_TARGET"

for skill_dir in "$REPO_DIR"/skills/cccx-*/; do
    if [ -d "$skill_dir" ]; then
        skill_name="$(basename "$skill_dir")"
        # Remove existing to prevent cp -r nesting on re-install
        rm -rf "${SKILLS_TARGET:?}/$skill_name"
        cp -r "$skill_dir" "$SKILLS_TARGET/$skill_name"
        echo "  + $skill_name"
    fi
done

# Copy shared references (clean first)
if [ -d "$REPO_DIR/skills/shared-references" ]; then
    rm -rf "${SKILLS_TARGET:?}/shared-references"
    cp -r "$REPO_DIR/skills/shared-references" "$SKILLS_TARGET/shared-references"
    echo "  + shared-references"
fi

echo "  Done."
echo ""

# Step 2: Copy scripts (optional, clean first)
if [ "$WITH_SCRIPTS" = true ]; then
    echo "[2/3] Copying scripts to $SCRIPTS_TARGET ..."
    mkdir -p "$SCRIPTS_TARGET"
    for script_file in "$REPO_DIR"/scripts/*.sh; do
        if [ -f "$script_file" ] && [ "$(basename "$script_file")" != "install.sh" ]; then
            cp "$script_file" "$SCRIPTS_TARGET/"
            echo "  + $(basename "$script_file")"
        fi
    done
    echo "  Done."
else
    echo "[2/3] Skipping scripts (use --with-scripts to include)."
fi
echo ""

# Step 3: Check Codex MCP
echo "[3/3] Checking Codex MCP setup ..."
if command -v codex &>/dev/null; then
    echo "  codex CLI found."
    echo "  If not already configured, run:"
    echo "    codex setup"
    echo "    claude mcp add codex -s user -- codex mcp-server"
else
    echo "  codex CLI not found."
    echo "  To enable external review, install Codex:"
    echo "    npm install -g @openai/codex"
    echo "    codex setup"
    echo "    claude mcp add codex -s user -- codex mcp-server"
    echo ""
    echo "  CCCXDevOps works without Codex, but review checkpoints will be skipped."
fi
echo ""

echo "=== Installation complete ==="
echo ""
echo "Installed skills:"
ls -1 "$SKILLS_TARGET" | grep '^cccx-' | sed 's/^/  /'
echo ""
echo "IMPORTANT: Add this to your project's CLAUDE.md to activate CCCXDevOps:"
echo ""
echo "  ## CCCXDevOps"
echo "  When working in this project, check CCCXDevOps skills before taking action."
echo "  Invoke /cccx-using-devops at session start to activate workflow discipline."
echo ""
echo "Next steps:"
echo "  1. Add the snippet above to your project's CLAUDE.md"
echo "  2. Configure Codex MCP for external review (optional)"
echo "  3. Start a Claude Code session and try: /cccx-using-devops"
