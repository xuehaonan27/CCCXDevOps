# CCCXDevOps Installation Guide

## Prerequisites

- [Claude Code](https://claude.ai/code) installed and working
- (Optional) [Codex CLI](https://github.com/openai/codex) for external review features

## Quick Install

```bash
git clone <repo-url> CCCXDevOps
cd CCCXDevOps
bash scripts/install.sh
```

This copies all `cccx-*` skills and shared references to `~/.claude/skills/`.

## Install Options

```bash
# Basic: skills only
bash scripts/install.sh

# With support scripts (health-check.sh, review-context.sh)
bash scripts/install.sh --with-scripts

# Auto-append bootstrap snippet to current project's CLAUDE.md
bash scripts/install.sh --auto-claude-md

# Full install
bash scripts/install.sh --with-scripts --auto-claude-md
```

## Activate in Your Project

Add this to your project's `CLAUDE.md`:

```markdown
## CCCXDevOps
When working in this project, check CCCXDevOps skills before taking action.
Invoke /cccx-using-devops at session start to activate workflow discipline.
```

Or use `--auto-claude-md` during install to do this automatically.

## Set Up Codex MCP (Optional)

Codex provides external review at workflow checkpoints. Without it, CCCXDevOps works but review gates are skipped with a warning.

```bash
npm install -g @openai/codex
codex setup                           # Choose model (gpt-5.4 recommended)
claude mcp add codex -s user -- codex mcp-server
```

## Verify Installation

```bash
# Check skills are installed
ls ~/.claude/skills/ | grep cccx

# Start Claude Code and test
# Type: /cccx-using-devops
```

## Uninstall

```bash
rm -rf ~/.claude/skills/cccx-*
rm -rf ~/.claude/skills/shared-references
rm -rf ~/.claude/scripts/health-check.sh ~/.claude/scripts/review-context.sh
```

## What Gets Installed

| Component | Location | Required |
|---|---|---|
| Skills (cccx-*) | `~/.claude/skills/` | Yes |
| Shared references | `~/.claude/skills/shared-references/` | Yes |
| Support scripts | `~/.claude/scripts/` | No (use `--with-scripts`) |
| CLAUDE.md snippet | `./CLAUDE.md` in project | Recommended |
| Codex MCP | System-wide via `claude mcp add` | No (enables review) |
