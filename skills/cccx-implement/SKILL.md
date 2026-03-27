---
name: cccx-implement
description: Use when you have an approved implementation plan with independent tasks to execute. Dispatches fresh subagents per task with two-stage review.
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob, Agent, Skill
---

# Subagent-Driven Implementation

## Overview

Execute an implementation plan by dispatching a fresh subagent for each task, followed by two-stage internal review (spec compliance then code quality), and a single Codex external review at the end.

## When to Use

- Have an approved implementation plan (from `cccx-plan`)
- Tasks are mostly independent
- Want high quality through fresh-context execution and review

## Prerequisites

- Approved implementation plan
- Worktree set up (via `cccx-worktree`)
- Clean baseline (tests passing)

## Workflow

### Phase 1: Setup

1. Read the implementation plan
2. Verify worktree exists and tests pass
3. If no worktree, invoke `cccx-worktree` first

### Phase 2: Execute Tasks (per task)

For each task in the plan:

#### 2a. Dispatch Implementer Subagent

Use the `Agent` tool to dispatch a fresh subagent with:
- Full task text from the plan (do NOT make them read the plan file)
- Scene-setting context: where this task fits in the overall feature
- TDD requirement: follow `cccx-tdd` discipline (RED-GREEN-REFACTOR)
- Answers to anticipated questions

Use the template in `implementer-prompt.md` to structure the dispatch.

#### 2b. Handle Implementer Status

| Status | Action |
|---|---|
| DONE | Proceed to spec review |
| DONE_WITH_CONCERNS | Read concerns. If correctness/scope issue, address before review. |
| NEEDS_CONTEXT | Provide missing info, re-dispatch |
| BLOCKED | Assess: context problem -> provide more context. Task too large -> break it up. Plan wrong -> escalate to user. |

#### 2c. Dispatch Spec Reviewer Subagent

Use the `Agent` tool to dispatch a spec reviewer:
- Provide the task specification from the plan
- Tell the reviewer to read the actual code files (not trust the implementer's report)
- Check: missing requirements? Extra features? Misunderstandings?

Use the template in `spec-reviewer-prompt.md`.

Report: COMPLIANT or ISSUES with specifics.

#### 2d. If Spec Issues Found

Re-dispatch the implementer to fix issues. Re-run spec review. Repeat until COMPLIANT.

#### 2e. Dispatch Code Quality Reviewer Subagent

Only after spec compliance passes:
- Check: clean, tested, maintainable
- Each file has one clear responsibility
- Implementation follows the plan's file structure
- No large files or significant growth of existing files

Use the template in `code-quality-reviewer-prompt.md`.

#### 2f. If Quality Issues Found

Re-dispatch implementer to fix. Re-run quality review. Repeat until PASS.

#### 2g. Mark Task Complete

Move to next task.

### Phase 3: Final Verification

After all tasks are complete:

1. Run the full test suite (invoke `cccx-verify`)
2. Verify all tests pass with fresh output
3. Run linter if applicable

### Phase 4: External Review

Request Codex review through `cccx-review`:

1. Write `.cccx/review/REVIEW_REQUEST.md` with:
   - profile: `dev-implementation`
   - subject: the full implementation
   - goal: validate architectural coherence across all tasks
   - evidence: git diff from worktree base to HEAD, full test output
2. Invoke `cccx-review`
3. Handle the verdict:
   - APPROVE: invoke `cccx-finish`
   - REQUEST_CHANGES: address issues, re-submit
   - BLOCK: present to user for decision
   - SKIPPED (Codex not configured): warn user that external review was not performed, then invoke `cccx-finish`

## Important Rules

- **One task at a time.** Do NOT dispatch parallel implementers (risk of file conflicts).
- **Codex review once at the end,** not after every task. Internal spec+quality review handles per-task quality.
- **Fresh subagent per task.** Don't reuse an agent across tasks -- context accumulation degrades quality.
- **Full task text in dispatch.** Never make a subagent read the plan file. Provide everything inline.

## Red Flags

- Starting on main/master without explicit consent
- Skipping spec review ("implementer said it's done")
- Skipping quality review ("spec passed, good enough")
- Dispatching parallel implementers
- Proceeding with unfixed review issues
- Starting quality review before spec compliance is confirmed

## Model Selection for Subagents

| Task Type | Recommended Model |
|---|---|
| Isolated function, clear spec, 1-2 files | Fast/cheap model |
| Multi-file coordination, pattern matching | Standard model |
| Architecture, design, review | Most capable model |
