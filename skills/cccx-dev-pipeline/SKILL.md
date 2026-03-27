---
name: cccx-dev-pipeline
description: Use for end-to-end feature development from design through merge. Chains all development skills in order with review gates.
argument-hint: [feature description or path to FEATURE_BRIEF.md]
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob, Agent, Skill
---

# Full Development Pipeline

## Overview

End-to-end development workflow: design exploration, implementation planning, isolated execution, verification, and branch completion. Each phase has a Codex review gate.

## When to Use

- Building a new feature from scratch
- Large task spanning design through delivery
- When you want the full CCCXDevOps discipline applied

## Constants

- AUTO_PROCEED = true -- auto-advance between phases after presenting results (set false for human gates at every step)

## Workflow

### Phase 1: Design

Invoke `cccx-brainstorm` via the `Skill` tool:

```
Skill: cccx-brainstorm
Args: <feature description or brief path>
```

**Gate:** Design document approved by user + Codex review (dev-design profile).

If AUTO_PROCEED = false, pause and wait for user confirmation before proceeding.

### Phase 2: Plan

Invoke `cccx-plan` via the `Skill` tool:

```
Skill: cccx-plan
Args: <path to approved design document>
```

**Gate:** Implementation plan approved by user + Codex review (dev-plan profile).

If AUTO_PROCEED = false, pause and wait for user confirmation.

### Phase 3: Setup

Invoke `cccx-worktree` via the `Skill` tool:

```
Skill: cccx-worktree
Args: <feature-name>
```

**Gate:** Worktree created, dependencies installed, baseline tests passing.

### Phase 4: Implement

Invoke `cccx-implement` via the `Skill` tool:

```
Skill: cccx-implement
Args: <path to implementation plan>
```

**Gate:** All tasks complete. Internal reviews (spec + quality) passed. Codex review (dev-implementation profile) approved.

### Phase 5: Verify

Invoke `cccx-verify` via the `Skill` tool.

**Gate:** Fresh test output showing all tests pass. Evidence cited.

### Phase 6: Finish

Invoke `cccx-finish` via the `Skill` tool.

**Gate:** Final Codex review (dev-implementation profile) approved. User selects merge/PR/keep/discard.

## Execution Rule

This skill invokes each sub-skill through the `Skill` tool. It MUST NOT inline sub-skill workflows into its own body. Sub-skills are independently updateable.

## Review Gates Summary

| Phase | Review Profile | Mandatory |
|---|---|---|
| Design | dev-design | Yes |
| Plan | dev-plan | Yes |
| Implementation | dev-implementation | Yes |
| Finish | dev-implementation | Yes |

## Red Flags

- Skipping a phase ("design is obvious, skip to plan")
- Inlining sub-skill workflows instead of invoking via Skill tool
- Proceeding past a review gate without addressing issues
- Running phases out of order

## Abort

At any point, the user can abort the pipeline. If aborted:
- Report current state (which phases completed, which pending)
- Preserve worktree and branch
- Do not auto-cleanup
