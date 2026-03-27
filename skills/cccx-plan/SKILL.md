---
name: cccx-plan
description: Use after a design is approved and before implementation begins. Creates a detailed, executable implementation plan with no placeholders.
---

# Implementation Planning

## Overview

Transform an approved design into a step-by-step implementation plan where every task is 2-5 minutes of work with complete code, exact file paths, and runnable commands.

**Hard Gate: NO PLACEHOLDERS. Every file path, command, and code block must be complete.**

## When to Use

- After design document is approved (via `cccx-brainstorm`)
- Before any implementation work begins

## Workflow

### Step 1: Scope Check

If the design covers multiple independent subsystems, break into separate plans. Each plan should be independently implementable and testable.

### Step 2: File Structure

Design the file layout:
- Each file has one clear responsibility
- Prefer smaller focused files over large ones
- Files that change together should live together
- Follow existing codebase conventions

### Step 3: Task Breakdown

Each task must be 2-5 minutes of work:

```markdown
### Task N: <Component Name>

**Files:**
- Create: `exact/path/to/file.ts`
- Modify: `exact/path/to/existing.ts:45-60`
- Test: `tests/exact/path/to/file.test.ts`

- [ ] **Step 1: Write failing test**
\`\`\`typescript
// Complete test code here -- no placeholders
\`\`\`

- [ ] **Step 2: Run test to verify it fails**
Run: `npm test tests/exact/path/to/file.test.ts`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**
\`\`\`typescript
// Complete implementation code here
\`\`\`

- [ ] **Step 4: Run test to verify it passes**
Run: `npm test tests/exact/path/to/file.test.ts`
Expected: PASS

- [ ] **Step 5: Commit**
`git add <files> && git commit -m "<message>"`
```

### Step 4: Plan Header

Every plan must start with:

```markdown
# <Feature Name> Implementation Plan

> **Required skill:** Use cccx-implement to execute this plan

**Goal:** <one sentence>
**Architecture:** <2-3 sentences about approach>
**Tech Stack:** <key technologies>
**Design doc:** <path to approved design>
```

### Step 5: Self-Review

Check the plan for:
- [ ] **Spec coverage:** Every requirement from the design has a corresponding task
- [ ] **Placeholder scan:** Search for "TBD", "TODO", "similar to Task N", "implement later", "add appropriate"
- [ ] **Type consistency:** Names match across tasks
- [ ] **Path accuracy:** All file paths are complete and consistent
- [ ] **Command accuracy:** All test/build commands are runnable
- [ ] **Task order:** Tasks can be executed in sequence without dependency conflicts
- [ ] **Edge cases:** Boundary conditions from the design have corresponding test tasks

### Step 6: External Review

Request Codex review through `cccx-review`:

1. Write `.cccx/review/REVIEW_REQUEST.md` with:
   - profile: `dev-plan`
   - subject: the implementation plan
   - goal: validate plan completeness and executability
   - evidence: the full plan + approved design document
2. Invoke `cccx-review`
3. Handle the verdict:
   - APPROVE: proceed to Step 7
   - REQUEST_CHANGES: address the issues, then re-submit by writing a new `.cccx/review/REVIEW_REQUEST.md` with the `threadId` from the previous `REVIEW_RESPONSE.md` and a "Changes Since Last Review" section describing what was fixed. Invoke `cccx-review` again.
   - BLOCK: present to user for decision
   - SKIPPED (Codex not configured): warn user that external review was not performed, then proceed to Step 7

### Step 7: Save and Handoff

Save plan to: `docs/cccx/plans/YYYY-MM-DD-<feature>.md`

Present to user and offer: invoke `cccx-implement` to begin execution.

## Forbidden in Plans

- "TBD" or "TODO"
- "Implement later"
- "Add appropriate error handling" (show the actual error handling)
- "Write tests for the above" (show the actual tests)
- "Similar to Task N" (repeat the code)
- Any step that describes what to do without showing the code

## Red Flags

- Plan with incomplete code blocks
- Tasks that would take more than 5 minutes
- Missing test tasks for feature tasks
- File paths that don't match the project structure
- Commands that assume tools not in the project

## Quick Reference

| Plan Element | Requirement |
|---|---|
| Task granularity | 2-5 minutes each |
| Code blocks | Complete, runnable |
| File paths | Exact, verified against project |
| Test commands | Full command with expected output |
| Commit messages | Written in the plan |
