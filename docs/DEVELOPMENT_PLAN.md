# CCCXDevOps Development Plan v2

> **Status:** Draft v2 for Claude Code review
> **Date:** 2026-03-27
> **Author:** Codex
> **Supersedes:** Draft v1 by Claude Code

---

## 1. Executive Summary

CCCXDevOps v1 will focus on one collaboration model only:

- **Claude Code** is the primary executor
- **Codex** is the external reviewer
- **Claude Code skills + small support scripts** are the implementation medium
- **No cross-platform support** is included in v1

The original draft had the right direction, but the first version was too broad, too review-heavy, and too loosely validated. This v2 narrows the work to a validated vertical slice:

1. a complete **development workflow**
2. a small, safety-first **operations pilot** for deploy + monitor
3. a concrete **skill test harness**

The core architectural change is to keep the **generic Codex MCP review framework**, but **centralize all direct MCP transport in one skill**: `cccx-review`.

That gives CCCXDevOps three logical layers without turning v1 into a multi-platform project:

- **Core workflow content**: skill logic, references, templates, workflow rules
- **Claude host adapter**: installation, bootstrap skill, Claude-specific conventions
- **Codex review overlay**: review profiles, prompt assembly, thread handling, escalation rules

This split preserves the simplicity of `cp -r` installation while preventing every skill from embedding transport details.

---

## 2. Constraints and Non-Goals

### 2.1 Constraints

- v1 supports **Claude Code + Codex review only**
- Skills must remain plain Markdown plus a small number of shell scripts
- Installation must stay lightweight: copy skills, optionally copy scripts, configure Codex MCP
- Skills should remain understandable without auxiliary infrastructure

### 2.2 Non-Goals for v1

- No Codex-native skill package
- No Cursor, Gemini, OpenCode, or other host support
- No daemon, service, database, or background scheduler
- No full maintenance suite yet
- No broad infra mutation workflows yet
- No notification integrations yet
- No claim that operations skills are "zero config"

### 2.3 v1 Safety Position

Development skills can be largely workflow-driven.

Operations skills cannot safely be zero-context. For deploy and monitor work, v1 will require an explicit service/environment profile. The system may assist with execution, but it must not pretend to know deployment topology, cluster boundaries, rollback steps, or health endpoints without project-provided configuration.

---

## 3. Reference-Derived Decisions

### 3.1 Adopted from ARIS

| Reference Pattern | v2 Decision |
|------------------|-------------|
| Plain Markdown skills | Keep |
| `cp -r` installation style | Keep |
| Cross-model review | Keep |
| Workflow composition | Keep |
| Constants and inline overrides | Keep, but only where they matter |
| State files for long-running flows | Defer until a concrete workflow needs them |
| Reviewer overlay concept | Keep conceptually via `cccx-review` + review profiles |

### 3.2 Adopted from superpowers

| Reference Pattern | v2 Decision |
|------------------|-------------|
| Process-first workflow | Keep |
| Bootstrap skill that enforces skill usage | Add as `cccx-using-devops` |
| TDD discipline | Keep |
| Systematic debugging | Keep |
| Subagent-driven implementation | Keep |
| Skill testing and trigger testing | Move into Phase 1 |
| Detailed plans with exact tasks | Keep |

### 3.3 Explicit Rejections from v1

The following v1 assumptions are intentionally removed:

- Every major skill directly talks to Codex MCP
- Every review returns a numeric score
- All domains should ship in one initial release
- Ops skills can be installed and used safely with no project configuration
- Testing can wait until after the skill catalog is mostly written

---

## 4. Architecture

### 4.1 Logical Layers

#### A. Core Workflow Content

This is the reusable methodology layer:

- development workflow skills
- ops pilot skills
- shared references
- templates
- prompt fragments used by worker/reviewer skills

This layer contains the "what to do" logic.

#### B. Claude Host Adapter

This is the Claude Code-specific layer:

- install path conventions
- bootstrap skill
- tool usage expectations
- Claude-facing README and installation guide
- test harness that validates Claude skill triggering and compliance

This layer contains the "how Claude Code should load and obey the skills" logic.

#### C. Codex Review Overlay

This is the Codex reviewer layer:

- generic Codex MCP interaction pattern
- review profiles by domain
- context collection rules
- verdict parsing
- escalation and retry policy

This layer contains the "how external review is requested and interpreted" logic.

### 4.2 Key Architectural Rule

**Only `cccx-review` owns direct Codex MCP transport.**

Other skills may declare checkpoints such as:

- "request design review"
- "request implementation diff review"
- "request deploy safety review"

But they do so by invoking `cccx-review` with:

- a named review profile
- a subject
- a bounded context bundle
- explicit evidence

This prevents review logic from being duplicated across the repository.

### 4.3 Repository Structure

```text
CCCXDevOps/
├── skills/
│   ├── cccx-using-devops/
│   │   └── SKILL.md
│   ├── cccx-brainstorm/
│   │   └── SKILL.md
│   ├── cccx-plan/
│   │   └── SKILL.md
│   ├── cccx-tdd/
│   │   ├── SKILL.md
│   │   └── testing-anti-patterns.md
│   ├── cccx-implement/
│   │   ├── SKILL.md
│   │   ├── implementer-prompt.md
│   │   ├── spec-reviewer-prompt.md
│   │   └── code-quality-reviewer-prompt.md
│   ├── cccx-review/
│   │   └── SKILL.md
│   ├── cccx-verify/
│   │   └── SKILL.md
│   ├── cccx-debug/
│   │   ├── SKILL.md
│   │   ├── root-cause-tracing.md
│   │   └── defense-in-depth.md
│   ├── cccx-worktree/
│   │   └── SKILL.md
│   ├── cccx-finish/
│   │   └── SKILL.md
│   ├── cccx-dev-pipeline/
│   │   └── SKILL.md
│   ├── cccx-deploy/
│   │   └── SKILL.md
│   ├── cccx-monitor/
│   │   └── SKILL.md
│   └── shared-references/
│       ├── code-quality-principles.md
│       ├── tdd-principles.md
│       ├── deploy-safety-checklist.md
│       └── review-profiles/
│           ├── dev-design.md
│           ├── dev-plan.md
│           ├── dev-implementation.md
│           └── deploy-safety.md
├── scripts/
│   ├── install.sh
│   ├── health-check.sh
│   └── review-context.sh
├── templates/
│   ├── FEATURE_BRIEF.md
│   ├── SERVICE_PROFILE.md
│   └── DEPLOYMENT_PLAN.md
├── tests/
│   ├── claude-code/
│   ├── skill-triggering/
│   ├── fixtures/
│   └── mocks/
├── docs/
│   ├── DEVELOPMENT_PLAN.md
│   ├── DEVELOPMENT_PLAN_V2_REVIEW_BRIEF.md
│   ├── INSTALLATION.md
│   └── SKILL_CATALOG.md
├── CLAUDE.md
└── README.md
```

---

## 5. Skill Authoring Conventions

### 5.1 Frontmatter

Required:

- `name`
- `description`

Optional:

- `argument-hint`
- `allowed-tools`

v1 will not force ARIS-style extended frontmatter on every skill. Use extra fields only when they materially help Claude Code.

### 5.2 Description Rule

Descriptions must describe **triggering conditions only**, not workflow summaries.

Good:

```yaml
description: Use when implementing a multi-step feature after the design is approved
```

Bad:

```yaml
description: Use when implementing a feature by dispatching subagents and reviewing every task
```

### 5.3 Skill Structure

Preferred structure:

```markdown
# Skill Title

## Overview

## When to Use

## Workflow

## Red Flags

## Common Mistakes
```

Add sections only when they serve a real workflow need. Do not force identical section lists into every skill.

### 5.4 Token Discipline

- Frequently loaded skills must stay short
- Heavy references belong in supporting docs under `shared-references/`
- Prompt templates belong in sibling files when they exceed a few dozen lines

---

## 6. Generic Codex MCP Review Framework

### 6.1 Why Keep It Generic

The review framework should work for:

- design review
- implementation plan review
- code diff review
- deploy safety review
- future complex ops reviews such as Kubernetes maintenance

The transport pattern should stay generic even though v1 only ships a few review profiles.

### 6.2 Ownership Model

`cccx-review` owns:

- Codex MCP tool invocation
- review prompt assembly
- thread continuity
- retry rules
- verdict parsing
- escalation rules

All other skills own:

- when review is required
- what evidence must be collected
- which review profile applies

### 6.3 Review Request Contract

Every review request should supply:

- `profile`: named review profile
- `subject`: what is being reviewed
- `goal`: what the actor is trying to accomplish
- `context`: bounded, relevant background only
- `evidence`: commands, diffs, logs, docs, manifests, test output
- `constraints`: rollout limits, no-downtime requirement, branch rules, etc.
- `questions`: optional focal questions for Codex

### 6.4 Review Response Contract

v1 will use a risk-oriented schema instead of a mandatory score:

- `VERDICT`: `APPROVE` | `REQUEST_CHANGES` | `BLOCK`
- `RISK`: `LOW` | `MEDIUM` | `HIGH` | `CRITICAL`
- `BLOCKERS`: concrete issues that prevent proceeding
- `QUESTIONS`: anything unresolved
- `REQUIRED_EVIDENCE`: what must be shown before approval
- `SUGGESTED_NEXT_STEP`: smallest safe next action

Scores may be added by a specific profile if that domain benefits from them, but scores are not part of the universal contract.

### 6.5 Thread Handling

Base behavior:

1. First review request uses `mcp__codex__codex`
2. Follow-up uses `mcp__codex__codex-reply`
3. `cccx-review` stores the thread id in the immediate workflow context
4. No other skill needs to know transport details

### 6.6 Large Review Handling

For long inputs, `cccx-review` must prefer:

1. bounded summaries
2. focused evidence excerpts
3. explicit file lists and diffs
4. iterative follow-up rounds

If async review support is needed later, that change should stay inside `cccx-review`.

### 6.7 Review Profiles in v1

- `dev-design`
- `dev-plan`
- `dev-implementation`
- `deploy-safety`

### 6.8 Future-Proofing for Kubernetes Maintenance

The generic framework is intentionally suitable for future profiles such as `k8s-maintenance`, where the required evidence would include:

- cluster/context/namespace
- current symptoms and impact
- manifests or Helm/Kustomize diffs
- `kubectl` evidence
- rollout and rollback steps
- blast radius
- validation checks

That future profile should be added as a review profile first, not as a full automation skill first.

---

## 7. v1 Scope

### 7.1 In Scope

#### Development Workflow

- bootstrap skill
- brainstorming
- implementation planning
- worktree setup
- TDD discipline
- subagent-driven implementation
- centralized external review
- verification before completion
- systematic debugging
- branch finishing
- end-to-end development pipeline

#### Operations Pilot

- deploy orchestration for projects that already have a known deploy command/process
- health monitoring driven by explicit service profile
- deploy safety review through Codex

#### Validation Infrastructure

- trigger tests
- skill content tests
- mocked review tests
- one fixture project for end-to-end development workflow validation

### 7.2 Out of Scope

- `cccx-incident`
- `cccx-ci-cd`
- `cccx-infra`
- `cccx-deps`
- `cccx-security`
- `cccx-perf`
- `cccx-tech-debt`
- `cccx-docs`
- `cccx-maint-pipeline`
- `cccx-pipeline`
- notifications
- generalized session recovery/state orchestration

These are deferred until the v1 vertical slice is proven.

---

## 8. Skill Catalog for v1

### 8.1 `cccx-using-devops`

Purpose:

- bootstrap skill that enforces skill lookup before action
- process skills first, implementation skills second
- carry the "do not skip workflow discipline" role that `using-superpowers` serves in superpowers

Hard rules:

- skill check before action
- brainstorming before new development
- debugging before speculative fixes
- review checkpoints are mandatory when a workflow declares them

### 8.2 `cccx-brainstorm`

Source:

- superpowers `brainstorming`

Adaptation:

- stays interactive and approval-driven
- writes a design doc
- requests external review through `cccx-review` using `dev-design`

Output:

- approved design doc

### 8.3 `cccx-plan`

Source:

- superpowers `writing-plans`

Adaptation:

- preserve detailed tasks, exact paths, full test steps, no placeholders
- requires an approved design doc
- requests external review through `cccx-review` using `dev-plan`

Output:

- implementation plan

### 8.4 `cccx-worktree`

Source:

- superpowers `using-git-worktrees`

Adaptation:

- lightweight
- no external review by default
- verifies clean baseline before development begins

Output:

- isolated worktree ready for execution

### 8.5 `cccx-tdd`

Source:

- superpowers `test-driven-development`

Adaptation:

- minimal
- rigid skill
- used by implementation and debugging flows

Output:

- enforced RED -> GREEN -> REFACTOR discipline

### 8.6 `cccx-implement`

Source:

- superpowers `subagent-driven-development`

Adaptation:

- requires plan + worktree
- dispatches implementer, spec reviewer, then code-quality reviewer
- uses `cccx-review` once at the end for whole-implementation external review using `dev-implementation`

Important rule:

- do not duplicate Codex review after every tiny task

Output:

- implemented feature with passing tests and completed internal review loops

### 8.7 `cccx-review`

Purpose:

- central review gateway

Responsibilities:

- load named review profile
- collect bounded context
- call Codex
- parse verdict
- report blocking items
- manage follow-up review rounds

Used by:

- `cccx-brainstorm`
- `cccx-plan`
- `cccx-implement`
- `cccx-finish`
- `cccx-deploy`

### 8.8 `cccx-verify`

Source:

- superpowers `verification-before-completion`

Purpose:

- no success claim without fresh evidence

Output:

- evidence-backed completion statement

### 8.9 `cccx-debug`

Source:

- superpowers `systematic-debugging`

Purpose:

- root cause before fix

External review:

- optional, only for complex or stalled debugging

### 8.10 `cccx-finish`

Source:

- superpowers `finishing-a-development-branch`

Adaptation:

- perform final verification
- request final external diff review through `cccx-review`
- present merge/push/keep/discard options

### 8.11 `cccx-dev-pipeline`

Chain:

```text
cccx-using-devops
  -> cccx-brainstorm
  -> cccx-plan
  -> cccx-worktree
  -> cccx-implement
  -> cccx-verify
  -> cccx-finish
```

Mandatory external review gates:

- design
- implementation plan
- final implementation
- final branch diff

### 8.12 `cccx-deploy` (Ops Pilot)

Purpose:

- orchestrate deployment only when the project already has a known deployment command/process

Requirements:

- `SERVICE_PROFILE.md`
- deployment plan or enough information to generate one
- explicit target environment
- rollback steps documented before execution

External review:

- mandatory via `cccx-review` using `deploy-safety`

v1 guardrails:

- no invented infrastructure changes
- no automatic strategy selection
- no silent rollback logic
- no production deploy without explicit user confirmation

Output:

- deployment result with evidence

### 8.13 `cccx-monitor` (Ops Pilot)

Purpose:

- verify service health using explicit configuration from `SERVICE_PROFILE.md`

Inputs:

- health endpoints
- expected process/service names
- relevant checks and thresholds

Implementation:

- backed by `scripts/health-check.sh`

Output:

- health report with evidence and status

---

## 9. Shared References and Templates

### 9.1 Shared References

#### `code-quality-principles.md`

- file boundaries
- interface clarity
- follow existing code patterns
- avoid speculative features

#### `tdd-principles.md`

- RED -> GREEN -> REFACTOR
- anti-patterns
- acceptable mocking guidance

#### `deploy-safety-checklist.md`

- target environment confirmed
- rollback documented
- blast radius understood
- validation checks prepared
- post-deploy monitor window defined

#### `review-profiles/`

Each profile defines:

- review intent
- required evidence
- profile-specific questions
- approval thresholds

### 9.2 Templates

#### `FEATURE_BRIEF.md`

For brainstorming and planning.

#### `SERVICE_PROFILE.md`

Required for ops pilot. Includes:

- service name
- environments
- health endpoints
- deploy command or deploy script entrypoint
- rollback command or documented rollback steps
- critical dashboards/log locations

#### `DEPLOYMENT_PLAN.md`

Used by `cccx-deploy` when the project does not already provide a suitable plan document.

---

## 10. Support Scripts

### 10.1 `install.sh`

Responsibilities:

- copy `skills/cccx-*` to `~/.claude/skills/`
- copy `skills/shared-references` to `~/.claude/skills/`
- optionally copy scripts to `~/.claude/scripts/`
- print Codex MCP setup steps if not already configured

### 10.2 `health-check.sh`

Responsibilities:

- HTTP probes
- process checks
- basic timeout handling
- consistent output format for `cccx-monitor`

### 10.3 `review-context.sh`

Responsibilities:

- gather the exact evidence bundle for `cccx-review`
- support at least:
  - design doc review context
  - implementation plan review context
  - git diff review context
  - deploy plan review context

This script exists to make review inputs consistent and testable.

---

## 11. Testing Strategy

### 11.1 Principle

Skill testing is part of the product, not an afterthought.

v1 should not be considered complete unless the skills are tested in the same style that made the reference repos reliable.

### 11.2 Test Layers

#### A. Trigger Tests

Directory:

- `tests/skill-triggering/`

Purpose:

- verify that natural prompts trigger the right skills in Claude Code

Examples:

- feature request triggers `cccx-brainstorm`
- bug report triggers `cccx-debug`
- implementation request with approved plan triggers `cccx-implement`

#### B. Skill Content Tests

Directory:

- `tests/claude-code/`

Purpose:

- verify that Claude can describe required workflow ordering and hard rules

Examples:

- brainstorming requires approval before implementation
- implementation review order is spec first, then code quality
- `cccx-review` is the only direct MCP owner

#### C. Mocked Review Tests

Directory:

- `tests/mocks/`

Purpose:

- validate `cccx-review` behavior without requiring live Codex

Examples:

- `APPROVE` path
- `REQUEST_CHANGES` path
- `BLOCK` path
- thread-follow-up path

#### D. Integration Tests

Directory:

- `tests/fixtures/`

Purpose:

- run a small development workflow end-to-end on a fixture project

Minimum fixture:

- one small repo
- failing test to drive implementation
- enough structure to validate worktree, plan, implementation, review, and finish flow

### 11.3 Live Review Smoke Test

Real Codex review should be optional in automation:

- mocked review is required in CI
- live Codex smoke test runs only when an environment flag is present

Suggested flag:

- `LIVE_CODEX=1`

### 11.4 Required v1 Test Deliverables

- at least 3 trigger tests
- at least 5 skill-content tests
- mocked review path tests for all verdict types
- 1 end-to-end dev workflow fixture

---

## 12. Development Phases

### Phase 1: Foundation and Validation Harness

Goal:

- establish the Claude host layer, review foundation, and tests first

Deliverables:

- [ ] `cccx-using-devops/SKILL.md`
- [ ] `scripts/install.sh`
- [ ] `scripts/review-context.sh`
- [ ] `templates/FEATURE_BRIEF.md`
- [ ] `templates/SERVICE_PROFILE.md`
- [ ] `templates/DEPLOYMENT_PLAN.md`
- [ ] `shared-references/code-quality-principles.md`
- [ ] `shared-references/tdd-principles.md`
- [ ] `shared-references/deploy-safety-checklist.md`
- [ ] `shared-references/review-profiles/dev-design.md`
- [ ] `shared-references/review-profiles/dev-plan.md`
- [ ] `shared-references/review-profiles/dev-implementation.md`
- [ ] `shared-references/review-profiles/deploy-safety.md`
- [ ] `tests/skill-triggering/` harness
- [ ] `tests/claude-code/` harness
- [ ] `tests/mocks/` review harness
- [ ] `docs/INSTALLATION.md`
- [ ] `README.md`

Verification:

- install flow works in Claude Code
- bootstrap skill loads and enforces skill-first behavior
- trigger tests can detect missing skill activation

### Phase 2: Review Layer and Core Discipline Skills

Goal:

- implement the review gateway and the strict workflow skills it depends on

Deliverables:

- [ ] `cccx-review/SKILL.md`
- [ ] `cccx-tdd/SKILL.md`
- [ ] `cccx-verify/SKILL.md`
- [ ] `cccx-debug/SKILL.md`
- [ ] `cccx-worktree/SKILL.md`
- [ ] `scripts/health-check.sh`

Verification:

- mocked review tests cover all verdict paths
- `cccx-review` can assemble context bundles by profile
- discipline skills are testable in isolation

### Phase 3: Development Workflow

Goal:

- ship the full development vertical slice

Deliverables:

- [ ] `cccx-brainstorm/SKILL.md`
- [ ] `cccx-plan/SKILL.md`
- [ ] `cccx-implement/SKILL.md`
- [ ] `cccx-implement/implementer-prompt.md`
- [ ] `cccx-implement/spec-reviewer-prompt.md`
- [ ] `cccx-implement/code-quality-reviewer-prompt.md`
- [ ] `cccx-finish/SKILL.md`
- [ ] `cccx-dev-pipeline/SKILL.md`
- [ ] fixture project + end-to-end development integration test

Verification:

- small feature can be taken from design to finished branch
- review gates fire at the declared checkpoints
- TDD discipline is preserved in actual execution

### Phase 4: Operations Pilot

Goal:

- add one safe, configuration-driven ops slice

Deliverables:

- [ ] `cccx-deploy/SKILL.md`
- [ ] `cccx-monitor/SKILL.md`
- [ ] deploy + monitor fixture or scripted demo target
- [ ] tests for service-profile validation and deploy safety review path

Verification:

- deployment does not proceed without rollback information
- monitor can verify the target using `SERVICE_PROFILE.md`
- deploy safety review blocks unsafe plans

### Phase 5: Review and Expansion Gate

Goal:

- decide whether the v1 slice is strong enough to justify more ops and maintenance work

Exit criteria before adding more skills:

- development workflow is reliable in repeated tests
- review gateway is stable
- ops pilot is useful and does not create false confidence
- Claude Code and Codex roles are clear in practice

Deferred backlog after Phase 5:

- incident response
- CI/CD management
- infrastructure changes
- maintenance pipeline
- session recovery/state files
- notifications
- broader orchestrators

---

## 13. Open Questions for Claude Code Review

1. Is `cccx-review` as the single direct MCP owner the right abstraction, or is there a simpler boundary that still prevents review logic duplication?
2. Is the v1 scope still too large, or is the current vertical slice small enough to validate the framework?
3. Is `review-context.sh` worth keeping as a script, or should evidence collection remain inside skill instructions?
4. Are the mandatory review gates correctly chosen, or should any of them move from mandatory to optional?
5. Are the ops pilot guardrails strict enough for deploy work without making the skill useless?

---

## 14. Success Criteria for v1

CCCXDevOps v1 is successful when:

1. Claude Code can install the skills with a simple documented flow
2. `cccx-using-devops` causes the right process skills to activate before action
3. The development workflow works end-to-end on a fixture project
4. `cccx-review` consistently handles approve, request-changes, and block paths
5. Codex review catches at least one seeded issue in test fixtures
6. `cccx-deploy` refuses to act without explicit rollback and environment context
7. The repository includes real trigger/content/integration tests, not just prose about testing

---

## 15. Summary of What Changed from v1

- Host scope is now explicitly **Claude Code only**
- The plan now has a **logical layer split** without becoming a cross-platform project
- **Generic Codex review framework is kept**, but direct MCP calls are centralized in `cccx-review`
- A bootstrap skill, `cccx-using-devops`, is added
- v1 scope is reduced to **development workflow + deploy/monitor ops pilot**
- Maintenance and broad ops automation are deferred
- Testing is moved into **Phase 1**
- Ops skills now require explicit project configuration instead of implying zero-config safety
- Review output is changed from mandatory numeric scoring to a more generic **verdict + risk** contract

