#!/bin/bash
# CCCXDevOps Installer
# Copies skills and optionally scripts to Claude Code directories.
# Usage: bash install.sh [--with-scripts] [--auto-claude-md]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_TARGET="$HOME/.claude/skills"
SCRIPTS_TARGET="$HOME/.claude/scripts"

WITH_SCRIPTS=false
AUTO_CLAUDE_MD=false

for arg in "$@"; do
    case "$arg" in
        --with-scripts) WITH_SCRIPTS=true ;;
        --auto-claude-md) AUTO_CLAUDE_MD=true ;;
        --help|-h)
            echo "Usage: bash install.sh [--with-scripts] [--auto-claude-md]"
            echo ""
            echo "Options:"
            echo "  --with-scripts     Also copy support scripts to ~/.claude/scripts/"
            echo "  --auto-claude-md   Append bootstrap snippet to ./CLAUDE.md in current directory"
            echo "  --help, -h         Show this help"
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

# Step 1: Copy skills
echo "[1/4] Copying skills to $SKILLS_TARGET ..."
mkdir -p "$SKILLS_TARGET"

# Copy all cccx-* skill directories
for skill_dir in "$REPO_DIR"/skills/cccx-*/; do
    if [ -d "$skill_dir" ]; then
        skill_name="$(basename "$skill_dir")"
        cp -r "$skill_dir" "$SKILLS_TARGET/$skill_name"
        echo "  + $skill_name"
    fi
done

# Copy shared references
if [ -d "$REPO_DIR/skills/shared-references" ]; then
    cp -r "$REPO_DIR/skills/shared-references" "$SKILLS_TARGET/shared-references"
    echo "  + shared-references"
fi

echo "  Done."
echo ""

# Step 2: Copy scripts (optional)
if [ "$WITH_SCRIPTS" = true ]; then
    echo "[2/4] Copying scripts to $SCRIPTS_TARGET ..."
    mkdir -p "$SCRIPTS_TARGET"
    for script_file in "$REPO_DIR"/scripts/*.sh; do
        if [ -f "$script_file" ] && [ "$(basename "$script_file")" != "install.sh" ]; then
            cp "$script_file" "$SCRIPTS_TARGET/"
            echo "  + $(basename "$script_file")"
        fi
    done
    echo "  Done."
else
    echo "[2/4] Skipping scripts (use --with-scripts to include)."
fi
echo ""

# Step 3: CLAUDE.md bootstrap snippet
CLAUDE_MD_SNIPPET='## CCCXDevOps
When working in this project, check CCCXDevOps skills before taking action.
Invoke /cccx-using-devops at session start to activate workflow discipline.'

if [ "$AUTO_CLAUDE_MD" = true ]; then
    echo "[3/4] Appending bootstrap snippet to ./CLAUDE.md ..."
    if [ -f "./CLAUDE.md" ]; then
        if grep -q "cccx-using-devops" "./CLAUDE.md" 2>/dev/null; then
            echo "  Already present in CLAUDE.md. Skipping."
        else
            echo "" >> "./CLAUDE.md"
            echo "$CLAUDE_MD_SNIPPET" >> "./CLAUDE.md"
            echo "  Appended."
        fi
    else
        echo "$CLAUDE_MD_SNIPPET" > "./CLAUDE.md"
        echo "  Created ./CLAUDE.md with bootstrap snippet."
    fi
else
    echo "[3/4] Add this to your project's CLAUDE.md to activate CCCXDevOps:"
    echo ""
    echo "  $CLAUDE_MD_SNIPPET"
    echo ""
    echo "  (Use --auto-claude-md to do this automatically.)"
fi
echo ""

# Step 4: Check Codex MCP
echo "[4/4] Checking Codex MCP setup ..."
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
echo "Next steps:"
echo "  1. Add the CLAUDE.md snippet to your project (if not done above)"
echo "  2. Configure Codex MCP (if not done above)"
echo "  3. Start a Claude Code session and try: /cccx-using-devops"
