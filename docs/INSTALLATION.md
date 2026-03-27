# CCCXDevOps Installation Guide

## Prerequisites

- [Claude Code](https://claude.ai/code) installed and working
- (Optional) [Codex CLI](https://github.com/openai/codex) for external review features

## Quick Install

```bash
# From your project directory (or any directory):
git clone <repo-url> /tmp/CCCXDevOps
bash /tmp/CCCXDevOps/scripts/install.sh
```

This copies all `cccx-*` skills and shared references to `~/.claude/skills/`.

The installer is safe to re-run -- it cleans target directories before copying.

## Install Options

```bash
# Basic: skills only
bash /tmp/CCCXDevOps/scripts/install.sh

# With support scripts (health-check.sh, review-context.sh)
bash /tmp/CCCXDevOps/scripts/install.sh --with-scripts
```

## Activate in Your Project

After installation, add this snippet to your **project's** `CLAUDE.md` (not the CCCXDevOps repo's CLAUDE.md):

```markdown
## CCCXDevOps
When working in this project, check CCCXDevOps skills before taking action.
Invoke /cccx-using-devops at session start to activate workflow discipline.
```

The installer prints this snippet after running. Copy it into each project where you want CCCXDevOps active.

## Set Up Codex MCP (Optional)

Codex provides external review at workflow checkpoints. Without it, CCCXDevOps works but review gates are skipped with a visible warning.

```bash
npm install -g @openai/codex
codex setup                           # Choose model (gpt-5.4 recommended)
claude mcp add codex -s user -- codex mcp-server
```

## Verify Installation

```bash
# Check skills are installed
ls ~/.claude/skills/ | grep cccx

# Optionally run the install verification script
bash /tmp/CCCXDevOps/tests/verify-install.sh

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

**Not installed automatically (user responsibility):**

| Component | Where to Add | Notes |
|---|---|---|
| CLAUDE.md snippet | Your project's `CLAUDE.md` | Activates bootstrap skill |
| Codex MCP | System-wide via `claude mcp add` | Enables external review |
| Templates | Copy from `templates/` if needed | FEATURE_BRIEF, SERVICE_PROFILE, DEPLOYMENT_PLAN |
