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

Determine the worktree base directory. Store the result as `WORKTREE_BASE` -- all subsequent steps use this variable, not a hardcoded path.

Check in order:

1. **Existing directory:**
   ```bash
   if [ -d ".worktrees" ]; then WORKTREE_BASE=".worktrees"
   elif [ -d "worktrees" ]; then WORKTREE_BASE="worktrees"
   fi
   ```
   If found, use it. If both exist, prefer `.worktrees`.

2. **CLAUDE.md preference:**
   ```bash
   grep -i "worktree" CLAUDE.md 2>/dev/null
   ```
   If a custom path is specified, set `WORKTREE_BASE` to that path.

3. **Default:** `WORKTREE_BASE=".worktrees"`

### Step 2: Verify .gitignore

The `WORKTREE_BASE` directory must be in `.gitignore`:

```bash
git check-ignore -q "$WORKTREE_BASE" 2>/dev/null
```

If NOT ignored:
1. Add `$WORKTREE_BASE/` to `.gitignore`
2. Do **NOT** commit this change -- `.gitignore` takes effect from the working tree regardless of commit state. Committing would mutate the current branch (likely main) before isolation exists.
3. Proceed to Step 3.
4. Note for the user: "Added $WORKTREE_BASE/ to .gitignore (uncommitted). You may want to commit this separately."

### Step 3: Create Worktree

Use `WORKTREE_BASE` from Step 1:

```bash
BRANCH_NAME="feature/<descriptive-name>"
WORKTREE_PATH="$WORKTREE_BASE/<descriptive-name>"

mkdir -p "$WORKTREE_BASE"
git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME"
cd "$WORKTREE_PATH"
```

### Step 4: Run Project Setup

Auto-detect and install dependencies. Prefer lockfile-respecting commands when available:

```bash
if [ -f package-lock.json ]; then npm ci
elif [ -f package.json ]; then npm install
fi
[ -f Cargo.toml ] && cargo build
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
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

- Using a hardcoded path instead of `WORKTREE_BASE` from Step 1
- Creating a worktree without verifying .gitignore
- Committing .gitignore changes to main/master before the feature branch exists
- Starting work on main/master without explicit user consent
- Skipping the baseline test verification
- Forgetting to report the worktree location
