---
name: cccx-worktree
description: Use when starting feature work that needs an isolated workspace, or before executing an implementation plan
---

# Git Worktree Management

## Overview

Create an isolated git worktree for feature development. Keeps the main working directory clean and enables easy branch disposal.

## When to Use

- Starting a new feature branch
- Before executing an implementation plan (via `cccx-implement`)
- When you need isolation from the main working directory

## Workflow

### Step 1: Choose Worktree Directory

Check in order:

1. **Existing directory:**
   ```bash
   ls -d .worktrees 2>/dev/null || ls -d worktrees 2>/dev/null
   ```
   If found, use it. If both exist, prefer `.worktrees`.

2. **CLAUDE.md preference:**
   ```bash
   grep -i "worktree" CLAUDE.md 2>/dev/null
   ```
   If specified, use that path.

3. **Default:** Create `.worktrees/` in the project root.

### Step 2: Verify .gitignore

The worktree directory must be in `.gitignore`:

```bash
git check-ignore -q .worktrees 2>/dev/null
```

If NOT ignored:
1. Add `.worktrees/` (or `worktrees/`) to `.gitignore`
2. Commit the change: `git add .gitignore && git commit -m "chore: ignore worktree directory"`
3. Proceed

### Step 3: Create Worktree

```bash
BRANCH_NAME="feature/<descriptive-name>"
WORKTREE_PATH=".worktrees/<descriptive-name>"

git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME"
cd "$WORKTREE_PATH"
```

### Step 4: Run Project Setup

Auto-detect and install dependencies:

```bash
[ -f package.json ] && npm install
[ -f Cargo.toml ] && cargo build
[ -f requirements.txt ] && pip install -r requirements.txt
[ -f go.mod ] && go mod download
[ -f Gemfile ] && bundle install
```

### Step 5: Verify Clean Baseline

Run the project's test suite:

```bash
npm test          # Node.js
cargo test        # Rust
pytest            # Python
go test ./...     # Go
```

- If tests pass: report ready
- If tests fail: report failures, ask user whether to proceed

### Step 6: Report

```
Worktree ready:
  Path:   <full-path>
  Branch: <branch-name>
  Tests:  <N> passing, 0 failing
  Status: Ready for implementation
```

## Cleanup

After work is complete (handled by `cccx-finish`):

```bash
cd <original-directory>
git worktree remove <worktree-path>
```

## Red Flags

- Creating a worktree without verifying .gitignore
- Starting work on main/master without explicit user consent
- Skipping the baseline test verification
- Forgetting to report the worktree location
