---
name: cccx-finish
description: Use when implementation is complete and all tests pass. Handles final verification, external review, and branch completion (merge, PR, keep, or discard).
---

# Branch Completion

## Overview

Verify, review, and complete a development branch. Presents exactly 4 options: merge locally, push + PR, keep as-is, or discard.

## When to Use

- Implementation complete, all tests passing
- Ready to integrate work into the base branch

## Workflow

### Step 1: Final Verification

Invoke `cccx-verify`:
- Run full test suite
- Run linter if applicable
- Verify clean output

If tests fail: STOP. Fix failures before completing.

### Step 2: External Review

Request final diff review through `cccx-review`:

1. Determine base:
   ```bash
   BASE_SHA=$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null)
   ```

2. Write `.cccx/review/REVIEW_REQUEST.md` with:
   - profile: `dev-implementation`
   - subject: "Final branch review for <feature>"
   - evidence: `git diff $BASE_SHA..HEAD`, test output, commit log

3. Invoke `cccx-review`
4. Handle the verdict:
   - APPROVE: proceed to Step 3
   - REQUEST_CHANGES: address the issues, then re-submit by writing a new `.cccx/review/REVIEW_REQUEST.md` with the `threadId` from the previous `REVIEW_RESPONSE.md` and a "Changes Since Last Review" section describing what was fixed. Invoke `cccx-review` again.
   - BLOCK: present to user, do not offer merge options
   - SKIPPED (Codex not configured): warn user that external review was not performed, then proceed to Step 3

### Step 3: Present Options

After verification and review pass, present exactly 4 options:

```
Implementation complete. All tests pass. Review approved.

Options:
1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work
```

### Step 4: Execute Choice

**Option 1: Merge Locally**
```bash
git checkout <base-branch>
git pull
git merge <feature-branch>
# Run tests again after merge
git branch -d <feature-branch>
```
Then cleanup worktree.

**Option 2: Push and Create PR**
```bash
git push -u origin <feature-branch>
gh pr create --title "<title>" --body "<body>"
```
Report PR URL. Then cleanup worktree.

**Option 3: Keep As-Is**
Report: "Keeping branch `<name>`. Worktree preserved at `<path>`."
Do not cleanup.

**Option 4: Discard**
Require explicit confirmation:
```
This will delete:
- Branch: <name>
- Commits: <list>
- Worktree: <path>

Type 'discard' to confirm.
```
After confirmation:
```bash
cd <original-directory>
git worktree remove <worktree-path>
git branch -D <feature-branch>
```

### Step 5: Cleanup Worktree (Options 1, 2)

```bash
cd <original-directory>
git worktree remove <worktree-path>
```

## Red Flags

- Merging without running tests
- Skipping external review
- Force-pushing without user consent
- Discarding without confirmation
- Cleaning up worktree for Option 3
