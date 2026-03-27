---
name: cccx-using-devops
description: Use at the start of every session and before any development, operations, or debugging task to enforce CCCXDevOps workflow discipline
---

# CCCXDevOps Bootstrap

## Overview

This skill enforces the CCCXDevOps workflow discipline: always check for an applicable skill before taking action. Process skills (brainstorming, debugging) determine HOW to work. Implementation skills (TDD, subagent dispatch) guide execution.

## Hard Rules

### 1. Skill Check Before Action

Before writing code, running commands, or making changes, check whether a CCCXDevOps skill applies:

- New feature or creative work? -> `cccx-brainstorm` first
- Have an approved design? -> `cccx-plan` first
- Have an approved plan? -> `cccx-implement`
- Bug, failure, unexpected behavior? -> `cccx-debug` first
- About to claim something is done? -> `cccx-verify`
- Ready to merge or create PR? -> `cccx-finish`
- Deploying? -> `cccx-deploy`
- Checking service health? -> `cccx-monitor`

If you think there is even a 1% chance a skill applies, invoke it.

### 2. Process Skills Before Implementation

When multiple skills could apply, invoke process skills first:

1. **Process skills** (brainstorming, debugging, planning) -- determine the approach
2. **Discipline skills** (TDD, verification) -- enforce quality during execution
3. **Implementation skills** (implement, deploy) -- do the work

### 3. No Skipping Workflow Steps

- No code without design (invoke `cccx-brainstorm` before `cccx-plan`)
- No implementation without plan (invoke `cccx-plan` before `cccx-implement`)
- No completion claims without evidence (invoke `cccx-verify`)
- No merge without review (invoke `cccx-finish`)
- No deploy without safety review (invoke `cccx-deploy`, which uses `cccx-review`)

### 4. Review Checkpoints Are Mandatory

When a workflow skill declares a review checkpoint, that checkpoint must fire. Do not skip external review to save time.

### 5. Full Pipeline Available

For large tasks that span design through deployment, use `cccx-dev-pipeline` which chains all development skills in order.

## Skill Priority

| User Request | First Skill | Why |
|---|---|---|
| "Add feature X" | `cccx-brainstorm` | Design before code |
| "Here's the spec, build it" | `cccx-plan` | Plan before implementation |
| "X is broken" | `cccx-debug` | Root cause before fix |
| "Is this done?" | `cccx-verify` | Evidence before claims |
| "Ship it" | `cccx-deploy` | Safety review before deploy |
| "Is the service healthy?" | `cccx-monitor` | Check with evidence |

## Red Flags

STOP if you notice yourself:

- Writing code before invoking a process skill
- Skipping brainstorming because "it's simple"
- Fixing a bug without systematic investigation
- Claiming completion without running verification
- Deploying without safety review
- Inlining a sub-skill's workflow instead of invoking it via `Skill` tool
