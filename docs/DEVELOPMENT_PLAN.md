# CCCXDevOps Development Plan

> **Status:** Draft v1 — pending Codex review
> **Date:** 2026-03-27
> **Author:** Claude Code (Opus 4.6)
> **Reviewers:** Codex (for architectural and completeness review)

---

## 1. Executive Summary

CCCXDevOps is a framework for Claude Code and Codex to collaborate on **Development, Operations, and Maintenance** tasks. Claude Code executes workflows; Codex reviews and advises at critical checkpoints. The framework is implemented as **pure Skills (Markdown files) and support scripts** — no framework, no daemon, no database. Installation is `cp -r`.

**Key design decisions:**
- Combine ARIS's `cp -r` skill architecture + Codex MCP review pattern with superpowers' TDD discipline + software dev workflows
- Extend scope from pure-dev (superpowers) and pure-research (ARIS) to full DevOps
- All skills prefixed `cccx-` to coexist with other installed skills
- Codex reviews at every major gate (design, plan, implementation, deployment, maintenance action)

---

## 2. Design Principles

### 2.1 Borrowed from ARIS (Auto-claude-code-research-in-sleep)

| Principle | How We Adopt It |
|-----------|-----------------|
| **Zero Framework** | Skills are Markdown files. Scripts are standalone `.sh`/`.py`. No build step, no daemon |
| **`cp -r` Installation** | Copy `skills/*` to `~/.claude/skills/`. Done |
| **Codex MCP Review** | Claude Code calls `mcp__codex__codex` at checkpoints. Thread continuity via `mcp__codex__codex-reply` |
| **Composable Workflows** | Single skills chain into pipelines. Run `/cccx-pipeline` for everything, or `/cccx-brainstorm` alone |
| **Constants Section** | Configurable parameters (AUTO_PROCEED, MAX_ROUNDS, etc.) in each skill |
| **State Persistence** | JSON state files for long-running operations (review loops, deployments) |
| **Templates** | Structured input templates for complex workflows |
| **Shared References** | Common guidelines referenced by multiple skills |

### 2.2 Borrowed from superpowers

| Principle | How We Adopt It |
|-----------|-----------------|
| **TDD Discipline** | Iron Law: NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST |
| **Systematic Debugging** | Iron Law: NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST |
| **Verification Before Claims** | Iron Law: NO COMPLETION CLAIMS WITHOUT FRESH EVIDENCE |
| **Design Before Code** | Brainstorm -> Plan -> Implement (never skip design) |
| **Subagent-Driven Development** | Fresh agent per task + two-stage review (spec then quality) |
| **Git Worktree Isolation** | Isolated workspaces for feature work |
| **Evidence Over Claims** | Run commands, read output, cite evidence. No "should work" |
| **Rationalization Defense** | Skills explicitly counter common shortcuts and excuses |
| **TDD for Skills** | New skills are tested with pressure scenarios before shipping |

### 2.3 New in CCCXDevOps

| Principle | Description |
|-----------|-------------|
| **DevOps Complete** | Development + Operations + Maintenance in one framework |
| **`cccx-` Prefix** | All skills namespaced to avoid conflicts with user's existing skills |
| **Cross-Model Adversarial Review** | Claude Code executes fast; Codex reviews rigorously. Two-player game beats self-play |
| **Checkpoint-Driven Autonomy** | `AUTO_PROCEED=true` auto-advances; `=false` pauses for human approval |
| **Ops Iron Laws** | NO DEPLOYMENT WITHOUT ROLLBACK PLAN; NO INFRA CHANGE WITHOUT REVIEW |
| **Maintenance Discipline** | NO DEPENDENCY UPDATE WITHOUT TEST VERIFICATION; NO SECURITY FIX WITHOUT REGRESSION CHECK |

---

## 3. Architecture

### 3.1 Directory Structure

```
CCCXDevOps/
├── skills/                              # All skill definitions
│   ├── cccx-brainstorm/                 # Design exploration
│   │   └── SKILL.md
│   ├── cccx-plan/                       # Implementation planning
│   │   └── SKILL.md
│   ├── cccx-tdd/                        # TDD discipline enforcement
│   │   ├── SKILL.md
│   │   └── testing-anti-patterns.md     # Common testing mistakes
│   ├── cccx-implement/                  # Subagent-driven implementation
│   │   ├── SKILL.md
│   │   ├── implementer-prompt.md        # Subagent dispatch template
│   │   ├── spec-reviewer-prompt.md      # Spec compliance review template
│   │   └── quality-reviewer-prompt.md   # Code quality review template
│   ├── cccx-review/                     # Codex MCP code review
│   │   └── SKILL.md
│   ├── cccx-debug/                      # Systematic debugging
│   │   ├── SKILL.md
│   │   ├── root-cause-tracing.md        # Trace-back technique
│   │   └── defense-in-depth.md          # Multi-layer validation
│   ├── cccx-verify/                     # Verification before completion
│   │   └── SKILL.md
│   ├── cccx-worktree/                   # Git worktree management
│   │   └── SKILL.md
│   ├── cccx-finish/                     # Branch completion
│   │   └── SKILL.md
│   ├── cccx-dev-pipeline/               # Full development pipeline
│   │   └── SKILL.md
│   ├── cccx-deploy/                     # Deployment management
│   │   └── SKILL.md
│   ├── cccx-monitor/                    # Health monitoring
│   │   └── SKILL.md
│   ├── cccx-incident/                   # Incident response
│   │   └── SKILL.md
│   ├── cccx-ci-cd/                      # CI/CD pipeline management
│   │   └── SKILL.md
│   ├── cccx-infra/                      # Infrastructure management
│   │   └── SKILL.md
│   ├── cccx-ops-pipeline/               # Full operations pipeline
│   │   └── SKILL.md
│   ├── cccx-deps/                       # Dependency management
│   │   └── SKILL.md
│   ├── cccx-security/                   # Security assessment
│   │   └── SKILL.md
│   ├── cccx-perf/                       # Performance audit
│   │   └── SKILL.md
│   ├── cccx-tech-debt/                  # Technical debt management
│   │   └── SKILL.md
│   ├── cccx-docs/                       # Documentation maintenance
│   │   └── SKILL.md
│   ├── cccx-maint-pipeline/             # Full maintenance pipeline
│   │   └── SKILL.md
│   ├── cccx-pipeline/                   # Full DevOps orchestrator
│   │   └── SKILL.md
│   ├── cccx-parallel/                   # Parallel agent dispatch
│   │   └── SKILL.md
│   ├── cccx-writing-skills/             # Skill creation (meta-skill)
│   │   └── SKILL.md
│   └── shared-references/               # Common guidelines
│       ├── codex-review-criteria.md     # Review criteria per skill type
│       ├── code-quality-principles.md   # Code quality standards
│       ├── ops-checklists.md            # Operations safety checklists
│       ├── security-baselines.md        # Security standards
│       └── tdd-principles.md            # TDD guidelines
├── scripts/                             # Support scripts
│   ├── install.sh                       # Installation helper
│   ├── health-check.sh                  # Generic health check runner
│   └── state-manager.sh                 # State file read/write helper
├── templates/                           # Input templates
│   ├── FEATURE_BRIEF.md                 # Feature request template
│   ├── INCIDENT_REPORT.md               # Incident report template
│   ├── DEPLOYMENT_PLAN.md               # Deployment plan template
│   └── MAINTENANCE_REQUEST.md           # Maintenance request template
├── docs/                                # Documentation
│   ├── DEVELOPMENT_PLAN.md              # This file
│   ├── INSTALLATION.md                  # Installation guide
│   └── SKILL_CATALOG.md                 # Full skill reference
├── CLAUDE.md                            # Project instructions
├── AGENTS.md                            # Agent instructions (-> CLAUDE.md)
└── README.md                            # Project overview
```

### 3.2 Skill File Format

Every skill follows this format (unified from ARIS + superpowers):

```markdown
---
name: cccx-skill-name
description: "Use when [specific triggering conditions]. Examples: [trigger phrases]"
argument-hint: [optional-argument]
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob, Agent, Skill, mcp__codex__codex, mcp__codex__codex-reply
---

# Skill Title

## Constants
- PARAM_NAME = value -- description
- AUTO_PROCEED = true -- auto-advance at checkpoints (set false for human gates)

## Overview
[1-2 sentence core principle]

## When to Use
[Bullet list of triggering conditions / symptoms]

## Workflow
[Step-by-step instructions with phases]

## Codex Review Checkpoints
[Where and how Codex is consulted]

## Red Flags
[STOP conditions -- when to halt and escalate]

## Common Mistakes
[What goes wrong + fixes]
```

**Key conventions:**
- `name` always starts with `cccx-`
- `description` starts with "Use when..." and lists triggering conditions only (not workflow summary)
- `allowed-tools` explicitly lists every tool the skill may use, including MCP tools
- `argument-hint` is optional; shows what argument the skill accepts

### 3.3 Codex MCP Integration Pattern

All skills that include Codex review follow this pattern:

```markdown
## Codex Review Checkpoint

### Sending for Review:
Call `mcp__codex__codex` with:
- config: {"model_reasoning_effort": "high"}   # or "xhigh" for critical reviews
- prompt: |
    You are reviewing [CONTEXT] for a DevOps workflow.

    [FULL CONTEXT TO REVIEW]

    Review criteria:
    1. [Criterion specific to this skill type]
    2. [Criterion specific to this skill type]
    ...

    Respond with:
    - VERDICT: APPROVE / REQUEST_CHANGES / BLOCK
    - SCORE: 1-10
    - ISSUES: [list of specific issues]
    - SUGGESTIONS: [list of improvements]

### Handling Response:
- APPROVE (score >= 7): Proceed to next phase
- REQUEST_CHANGES (score 4-6): Address issues, re-submit via mcp__codex__codex-reply
- BLOCK (score < 4): STOP. Present issues to user. Do not proceed without human decision.

### Thread Continuity:
Save threadId from first call. Use mcp__codex__codex-reply for follow-up rounds.
Max 3 review rounds per checkpoint. If still BLOCK after 3 rounds, escalate to human.
```

**Review criteria vary by domain:**

| Domain | Review Focus |
|--------|-------------|
| **Development** | Code quality, test coverage, spec compliance, API design, error handling |
| **Operations** | Safety, rollback plan, monitoring coverage, blast radius, gradual rollout |
| **Maintenance** | Regression risk, backward compatibility, documentation updates, test coverage |

### 3.4 Installation Mechanism

```bash
# Clone repository
git clone <repo-url> CCCXDevOps

# Install skills (the only required step)
cp -r CCCXDevOps/skills/cccx-* ~/.claude/skills/
cp -r CCCXDevOps/skills/shared-references ~/.claude/skills/

# Optional: install support scripts
mkdir -p ~/.claude/scripts
cp CCCXDevOps/scripts/* ~/.claude/scripts/

# Set up Codex MCP (required for review features)
npm install -g @openai/codex
codex setup                           # Choose model: gpt-5.4 recommended
claude mcp add codex -s user -- codex mcp-server
```

Or use the helper script:
```bash
bash CCCXDevOps/scripts/install.sh
```

**Uninstall:**
```bash
rm -rf ~/.claude/skills/cccx-*
rm -rf ~/.claude/skills/shared-references
```

---

## 4. Skill Catalog

### 4.1 Development Skills (10 skills)

#### `cccx-brainstorm` -- Design Exploration
- **Source:** superpowers/brainstorming, adapted
- **Trigger:** Before any creative work -- features, components, architecture changes
- **Input:** User request or `FEATURE_BRIEF.md` template
- **Process:**
  1. Explore project context (files, docs, recent commits)
  2. Ask clarifying questions (one at a time)
  3. Propose 2-3 approaches with trade-offs
  4. Present design in sections
  5. Write design doc to `docs/cccx/specs/YYYY-MM-DD-<topic>-design.md`
  6. **Codex checkpoint:** Review design for completeness, ambiguity, risks
  7. User reviews final spec
- **Output:** Approved design document
- **Chain next:** `cccx-plan`
- **Hard Gate:** NO CODE until design is approved

#### `cccx-plan` -- Implementation Planning
- **Source:** superpowers/writing-plans, adapted
- **Trigger:** After approved design, before touching code
- **Input:** Approved design document
- **Process:**
  1. Scope check (split if multi-system)
  2. Design file structure with clear boundaries
  3. Write tasks at 2-5 minute granularity
  4. Each task: write failing test -> run -> implement -> run -> commit
  5. Include complete code (NO PLACEHOLDERS)
  6. Self-review for gaps
  7. **Codex checkpoint:** Review plan for completeness, task granularity, missing edge cases
- **Output:** Implementation plan at `docs/cccx/plans/YYYY-MM-DD-<feature>.md`
- **Chain next:** `cccx-implement`
- **Hard Gate:** NO PLACEHOLDERS ("TBD", "TODO", "similar to Task N")

#### `cccx-tdd` -- Test-Driven Development Discipline
- **Source:** superpowers/test-driven-development, adapted
- **Trigger:** Always, for new features, bug fixes, refactoring, behavior changes
- **Iron Law:** `NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST`
- **Process:** RED (write failing test) -> verify RED -> GREEN (minimal code) -> verify GREEN -> REFACTOR
- **Not a pipeline skill** -- this is a discipline skill invoked by `cccx-implement` and `cccx-debug`
- **Common Rationalizations (all wrong):**
  - "Too simple to test" -> Simple code breaks
  - "I'll test after" -> Tests-after prove nothing about intent
  - "TDD slows me down" -> TDD is faster than debugging

#### `cccx-implement` -- Subagent-Driven Implementation
- **Source:** superpowers/subagent-driven-development + ARIS review pattern
- **Trigger:** Have implementation plan with tasks to execute
- **Input:** Implementation plan
- **Process:**
  1. Set up worktree (invoke `cccx-worktree`)
  2. For each task:
     a. Dispatch implementer subagent (fresh context, uses `cccx-tdd`)
     b. Handle status: DONE / DONE_WITH_CONCERNS / BLOCKED / NEEDS_CONTEXT
     c. Dispatch spec reviewer subagent (verify code matches spec)
     d. Dispatch quality reviewer subagent (clean, tested, maintainable)
     e. Fix issues if any, re-review until passing
  3. After all tasks: final code review
  4. **Codex checkpoint:** Review entire implementation for architectural coherence
- **Output:** Implemented feature with tests
- **Chain next:** `cccx-verify` -> `cccx-finish`
- **Red Flags:**
  - Never start on main/master without explicit consent
  - Never skip reviews (both spec AND quality)
  - Never dispatch parallel implementers (conflict risk)

#### `cccx-review` -- Codex MCP Code Review
- **Source:** ARIS Codex MCP + superpowers code-reviewer
- **Trigger:** After implementation, before merge. Also on-demand
- **Input:** Git diff (BASE_SHA -> HEAD_SHA)
- **Process:**
  1. Collect diff and context
  2. Format review request with skill-specific criteria
  3. Send to Codex via `mcp__codex__codex`
  4. Parse response: APPROVE / REQUEST_CHANGES / BLOCK
  5. If REQUEST_CHANGES: address issues, re-submit via `mcp__codex__codex-reply`
  6. Max 3 rounds; escalate to human if still blocked
- **Output:** Review verdict with action items
- **Used by:** All pipeline skills at their Codex checkpoints

#### `cccx-debug` -- Systematic Debugging
- **Source:** superpowers/systematic-debugging, adapted
- **Trigger:** Any bug, test failure, unexpected behavior, performance problem
- **Iron Law:** `NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST`
- **Process:**
  1. **Phase 1: Root Cause Investigation** -- read errors, reproduce, check recent changes, trace data flow
  2. **Phase 2: Pattern Analysis** -- find working examples, compare, identify differences
  3. **Phase 3: Hypothesis** -- form single hypothesis, test minimally, one variable at a time
  4. **Phase 4: Implementation** -- failing test (via `cccx-tdd`), single fix, verify
  5. If 3+ fixes fail: **STOP and question architecture**
  6. **Codex checkpoint (optional):** For complex bugs, consult Codex after Phase 2
- **Output:** Root cause identified and fixed with regression test
- **Red Flags:**
  - "Quick fix for now" -- NO
  - "Just try changing X" -- NO
  - "I don't fully understand but this might work" -- NO

#### `cccx-verify` -- Verification Before Completion
- **Source:** superpowers/verification-before-completion, adapted
- **Trigger:** Before ANY success/completion claim
- **Iron Law:** `NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE`
- **Process:**
  1. IDENTIFY: What command proves this claim?
  2. RUN: Execute full command (fresh)
  3. READ: Full output, check exit code
  4. VERIFY: Does output confirm claim?
  5. Only then: make the claim WITH evidence
- **Forbidden language:** "should", "probably", "seems to", "looks correct"
- **Used by:** All pipeline skills before claiming completion

#### `cccx-worktree` -- Git Worktree Management
- **Source:** superpowers/using-git-worktrees, simplified
- **Trigger:** Starting feature work needing isolation
- **Process:**
  1. Check for existing worktree directory (`.worktrees/` or `worktrees/`)
  2. Verify directory is in `.gitignore`
  3. Create worktree with feature branch
  4. Run project setup (detect: npm/cargo/pip/go)
  5. Verify clean baseline (tests pass)
  6. Report location and status
- **Output:** Isolated worktree ready for development

#### `cccx-finish` -- Branch Completion
- **Source:** superpowers/finishing-a-development-branch, adapted
- **Trigger:** Implementation complete, all tests passing
- **Process:**
  1. Verify all tests pass (via `cccx-verify`)
  2. **Codex checkpoint:** Final review of entire branch diff
  3. Present 4 options: merge locally / push + PR / keep branch / discard
  4. Execute chosen option
  5. Clean up worktree if applicable
- **Output:** Merged code or PR

#### `cccx-dev-pipeline` -- Full Development Pipeline
- **Source:** Original composition
- **Trigger:** "build a feature", "develop", "implement" (large scope tasks)
- **Chain:**
  ```
  cccx-brainstorm -> cccx-plan -> cccx-worktree -> cccx-implement -> cccx-verify -> cccx-finish
       |                |                                  |                              |
   [Codex review]  [Codex review]                   [Codex review]                [Codex review]
  ```
- **Constants:**
  - AUTO_PROCEED = true (auto-advance between phases)
  - Set false for human gates at each checkpoint
- **State Persistence:** `PIPELINE_STATE.json` for session recovery

### 4.2 Operations Skills (6 skills)

#### `cccx-deploy` -- Deployment Management
- **Trigger:** "deploy", "release", "ship", "push to production"
- **Iron Law:** `NO DEPLOYMENT WITHOUT ROLLBACK PLAN`
- **Process:**
  1. **Pre-flight:** Verify tests pass, check environment, confirm target
  2. **Plan:** Generate deployment plan (strategy, order, rollback steps)
  3. **Codex checkpoint:** Review deployment plan for safety, blast radius, rollback coverage
  4. **Execute:** Run deployment steps with verification at each stage
  5. **Verify:** Post-deployment health checks, smoke tests
  6. **Monitor:** Watch for errors in first 15 minutes (configurable)
- **Strategies supported:** Rolling, blue-green, canary (detected from project config)
- **Rollback:** Automatic rollback trigger if health checks fail
- **Output:** Deployment result with verification evidence

#### `cccx-monitor` -- Health Monitoring
- **Trigger:** "check health", "monitor", "is it running", "check status"
- **Process:**
  1. Identify monitoring targets (services, endpoints, resources)
  2. Run health checks (HTTP probes, process checks, resource checks)
  3. Collect metrics (CPU, memory, disk, response times)
  4. Compare against thresholds
  5. Report status with evidence
- **Can be scheduled:** Via CronCreate for periodic checks
- **Output:** Health report with status per target

#### `cccx-incident` -- Incident Response
- **Trigger:** "outage", "incident", "service down", "pages", "alert firing"
- **Process:**
  1. **Classify:** Severity (P0-P3) based on impact
  2. **Investigate:** Adapted from `cccx-debug` Phase 1-2 (root cause investigation, pattern analysis)
  3. **Mitigate:** Immediate actions to restore service
  4. **Communicate:** Status update templates (internal, external)
  5. **Resolve:** Fix root cause, verify resolution
  6. **Post-mortem:** Generate post-mortem document
  7. **Codex checkpoint:** Review post-mortem for completeness, action items
- **Output:** Incident resolved + post-mortem document
- **Templates:** `INCIDENT_REPORT.md`

#### `cccx-ci-cd` -- CI/CD Pipeline Management
- **Trigger:** "set up CI", "fix pipeline", "add deployment step", "CI failing"
- **Process:**
  1. Detect CI/CD platform (GitHub Actions, GitLab CI, Jenkins, etc.)
  2. Analyze current pipeline configuration
  3. Propose changes with rationale
  4. **Codex checkpoint:** Review pipeline changes for security, efficiency, correctness
  5. Implement changes
  6. Verify pipeline runs correctly
- **Output:** Updated CI/CD configuration with verification

#### `cccx-infra` -- Infrastructure Management
- **Trigger:** "provision", "infrastructure", "terraform", "cloudformation", "server setup"
- **Iron Law:** `NO INFRA CHANGE WITHOUT REVIEW`
- **Process:**
  1. Analyze current infrastructure state
  2. Propose changes (IaC when possible)
  3. **Codex checkpoint:** Review infra changes for security, cost, reliability
  4. Apply changes (with dry-run first)
  5. Verify infrastructure state matches intent
- **Output:** Infrastructure changes applied with verification

#### `cccx-ops-pipeline` -- Full Operations Pipeline
- **Trigger:** "deploy and monitor", "release pipeline", "ship it end to end"
- **Chain:**
  ```
  cccx-deploy -> cccx-monitor -> [if issues] -> cccx-incident
       |
   [Codex review]
  ```
- **Constants:** MONITOR_DURATION = 15min, AUTO_ROLLBACK = true

### 4.3 Maintenance Skills (6 skills)

#### `cccx-deps` -- Dependency Management
- **Trigger:** "update dependencies", "outdated packages", "npm audit", "vulnerability in package"
- **Iron Law:** `NO DEPENDENCY UPDATE WITHOUT TEST VERIFICATION`
- **Process:**
  1. **Audit:** List outdated/vulnerable dependencies
  2. **Assess:** Categorize by risk (major/minor/patch, breaking changes)
  3. **Plan:** Prioritized update order, one at a time for major bumps
  4. **Codex checkpoint:** Review update plan for risk assessment accuracy
  5. **Execute:** Update each dependency, run tests after each
  6. **Verify:** Full test suite passes, no regressions
- **Output:** Updated dependencies with test verification evidence

#### `cccx-security` -- Security Assessment
- **Trigger:** "security scan", "vulnerability check", "audit security", "OWASP"
- **Process:**
  1. **Scan:** Identify potential vulnerabilities (dependencies, code patterns, secrets)
  2. **Classify:** Severity (critical/high/medium/low) per CVSS or similar
  3. **Plan:** Remediation plan prioritized by severity
  4. **Codex checkpoint:** Review security findings and remediation plan
  5. **Fix:** Apply fixes with regression tests
  6. **Verify:** Re-scan confirms vulnerabilities resolved
- **Output:** Security report with remediation evidence

#### `cccx-perf` -- Performance Audit
- **Trigger:** "slow", "performance", "optimize", "bottleneck", "profiling"
- **Process:**
  1. **Baseline:** Establish current performance metrics
  2. **Profile:** Identify bottlenecks (profiler, timing, resource usage)
  3. **Analyze:** Root cause of performance issues
  4. **Plan:** Optimization approach
  5. **Codex checkpoint:** Review optimization for correctness, regression risk
  6. **Implement:** Apply optimization with before/after benchmarks
  7. **Verify:** Measurable improvement without regressions
- **Output:** Performance improvement with benchmark evidence

#### `cccx-tech-debt` -- Technical Debt Management
- **Trigger:** "tech debt", "refactor", "cleanup", "code smell", "complexity"
- **Process:**
  1. **Identify:** Scan for debt indicators (complexity, duplication, outdated patterns)
  2. **Catalog:** List items with impact/effort estimates
  3. **Prioritize:** High impact + low effort first
  4. **Plan:** Refactoring plan using `cccx-plan` format
  5. **Codex checkpoint:** Review refactoring plan for regression risk
  6. **Execute:** Refactor with TDD discipline (via `cccx-tdd`)
  7. **Verify:** Tests pass, no behavior change (unless intended)
- **Output:** Cleaned code with verification evidence

#### `cccx-docs` -- Documentation Maintenance
- **Trigger:** "update docs", "documentation", "API docs", "changelog", "README"
- **Process:**
  1. **Analyze:** Identify documentation gaps (undocumented APIs, stale docs, missing README sections)
  2. **Plan:** Documentation update plan
  3. **Write:** Generate/update documentation
  4. **Codex checkpoint:** Review docs for accuracy, completeness
  5. **Verify:** All documented APIs exist, all examples work
- **Output:** Updated documentation

#### `cccx-maint-pipeline` -- Full Maintenance Pipeline
- **Trigger:** "maintenance sweep", "full audit", "project health check"
- **Chain:**
  ```
  cccx-deps -> cccx-security -> cccx-perf -> cccx-tech-debt -> cccx-docs
      |             |               |              |               |
  [Codex]       [Codex]         [Codex]        [Codex]         [Codex]
  ```
- **Constants:** SKIP_CLEAN = true (skip categories with no issues found)

### 4.4 Cross-Cutting Skills (3 skills)

#### `cccx-pipeline` -- Full DevOps Orchestrator
- **Trigger:** "full pipeline", "end to end", "develop and deploy"
- **Process:**
  1. Classify task type (development / operations / maintenance / mixed)
  2. Route to appropriate pipeline:
     - Development: `cccx-dev-pipeline`
     - Operations: `cccx-ops-pipeline`
     - Maintenance: `cccx-maint-pipeline`
     - Mixed: Chain relevant pipelines in sequence
  3. Cross-domain coordination (e.g., dev -> deploy -> monitor)
- **Output:** Complete DevOps workflow result

#### `cccx-parallel` -- Parallel Agent Dispatch
- **Source:** superpowers/dispatching-parallel-agents
- **Trigger:** 2+ independent tasks that can work concurrently
- **Process:**
  1. Identify independent domains
  2. Create focused agent tasks
  3. Dispatch in parallel
  4. Review and integrate results
  5. Run full verification
- **Guard:** Don't use when tasks share state or have dependencies

#### `cccx-writing-skills` -- Skill Creation (Meta-Skill)
- **Source:** superpowers/writing-skills
- **Trigger:** "create a new skill", "write a skill", extending CCCXDevOps
- **Iron Law:** `NO SKILL WITHOUT A FAILING TEST FIRST` (TDD for documentation)
- **Process:**
  1. RED: Run pressure scenario without skill, document baseline
  2. GREEN: Write minimal skill that addresses observed rationalizations
  3. REFACTOR: Close loopholes, re-test
- **Output:** New `cccx-*` skill directory with SKILL.md

---

## 5. Workflow Chains

### 5.1 Full Development Workflow

```
User: "Build feature X"
         |
    cccx-brainstorm
    ├─ Explore context
    ├─ Clarify requirements
    ├─ Propose 2-3 approaches
    ├─ Write design doc
    └─ [CODEX REVIEW: design completeness]
         |
    cccx-plan
    ├─ File structure design
    ├─ Task breakdown (2-5 min each)
    ├─ Complete code in every task
    ├─ Self-review
    └─ [CODEX REVIEW: plan completeness]
         |
    cccx-worktree
    ├─ Create isolated branch
    ├─ Install dependencies
    └─ Verify clean baseline
         |
    cccx-implement
    ├─ For each task:
    │   ├─ Dispatch implementer (uses cccx-tdd)
    │   ├─ Spec review (subagent)
    │   └─ Quality review (subagent)
    └─ [CODEX REVIEW: architectural coherence]
         |
    cccx-verify
    ├─ Run full test suite
    ├─ Run linter
    └─ Evidence-based completion claim
         |
    cccx-finish
    ├─ [CODEX REVIEW: final diff review]
    ├─ Present options (merge/PR/keep/discard)
    └─ Execute choice, cleanup
```

### 5.2 Full Operations Workflow

```
User: "Deploy to production"
         |
    cccx-deploy
    ├─ Pre-flight checks
    ├─ Generate deployment plan
    ├─ [CODEX REVIEW: safety, rollback, blast radius]
    ├─ Execute deployment
    └─ Post-deployment verification
         |
    cccx-monitor
    ├─ Health checks (15 min window)
    ├─ Metric collection
    └─ Threshold comparison
         |
    [If issues detected]
         |
    cccx-incident
    ├─ Classify severity
    ├─ Investigate (systematic debugging)
    ├─ Mitigate / rollback
    ├─ Resolve root cause
    └─ [CODEX REVIEW: post-mortem]
```

### 5.3 Full Maintenance Workflow

```
User: "Run maintenance sweep"
         |
    cccx-deps
    ├─ Audit outdated/vulnerable deps
    ├─ [CODEX REVIEW: update risk]
    ├─ Update one at a time
    └─ Test after each update
         |
    cccx-security
    ├─ Vulnerability scan
    ├─ [CODEX REVIEW: remediation plan]
    ├─ Fix vulnerabilities
    └─ Re-scan verification
         |
    cccx-perf
    ├─ Baseline metrics
    ├─ Profile + analyze
    ├─ [CODEX REVIEW: optimization approach]
    └─ Implement with benchmarks
         |
    cccx-tech-debt
    ├─ Identify + catalog
    ├─ [CODEX REVIEW: refactoring plan]
    ├─ Refactor with TDD
    └─ Verify no regressions
         |
    cccx-docs
    ├─ Gap analysis
    ├─ [CODEX REVIEW: doc accuracy]
    └─ Update documentation
```

### 5.4 End-to-End DevOps Pipeline

```
User: "Full pipeline for feature X"
         |
    cccx-pipeline (orchestrator)
    ├─ Phase 1: Development
    │   └─ cccx-dev-pipeline (brainstorm -> plan -> implement -> verify -> finish)
    ├─ Phase 2: Operations
    │   └─ cccx-ops-pipeline (deploy -> monitor)
    └─ Phase 3: Maintenance (optional, if requested)
        └─ cccx-maint-pipeline (deps -> security -> perf -> debt -> docs)
```

---

## 6. Shared References

### 6.1 `codex-review-criteria.md`
Defines what Codex should check for each skill domain:

- **Development reviews:** Code quality, test coverage, spec compliance, API design, error handling, naming conventions
- **Operations reviews:** Safety, rollback plan exists, monitoring in place, blast radius contained, gradual rollout, secret management
- **Maintenance reviews:** Regression risk, backward compatibility, documentation updated, test coverage maintained, no behavior changes unless intended

### 6.2 `code-quality-principles.md`
Standards for code quality across all skills:
- Single responsibility per file/function
- Well-defined interfaces
- Testable independently
- Follow existing codebase patterns
- YAGNI (no speculative features)
- DRY (extract only after 3+ repetitions)

### 6.3 `ops-checklists.md`
Pre-flight checklists for operations:
- Deployment checklist (tests pass, rollback plan, monitoring, communication)
- Incident response checklist (classify, investigate, communicate, resolve, post-mortem)
- Infrastructure change checklist (dry-run, review, apply, verify)

### 6.4 `security-baselines.md`
Security standards:
- OWASP Top 10 awareness
- Secret management (no secrets in code, use env vars or vaults)
- Dependency vulnerability thresholds
- Input validation requirements
- Authentication/authorization patterns

### 6.5 `tdd-principles.md`
TDD guidelines shared by development and maintenance skills:
- RED-GREEN-REFACTOR cycle
- Testing anti-patterns
- When mocks are acceptable (external services only)
- Test naming conventions
- Coverage expectations

---

## 7. Support Scripts

### 7.1 `install.sh`
```bash
#!/bin/bash
# Install CCCXDevOps skills to ~/.claude/skills/
# Usage: bash install.sh [--with-scripts]
```
- Copies `skills/cccx-*` and `skills/shared-references` to `~/.claude/skills/`
- Optionally copies `scripts/*` to `~/.claude/scripts/`
- Checks for Codex MCP setup, prompts if not configured
- Idempotent (safe to run multiple times)

### 7.2 `health-check.sh`
```bash
#!/bin/bash
# Generic health check runner
# Usage: bash health-check.sh <target> [--timeout 30]
```
- HTTP endpoint probing
- Process health checks
- Resource utilization checks
- Used by `cccx-monitor` and `cccx-deploy` (post-deployment verification)

### 7.3 `state-manager.sh`
```bash
#!/bin/bash
# State file management for long-running workflows
# Usage: bash state-manager.sh read|write|reset <state-file>
```
- Read/write JSON state files
- State files: `PIPELINE_STATE.json`, `REVIEW_STATE.json`, `DEPLOY_STATE.json`
- Supports session recovery for interrupted workflows

---

## 8. Development Phases

### Phase 1: Foundation (skeleton + infrastructure)
**Goal:** Establish directory structure, installation mechanism, shared references, and the Codex integration pattern that all skills will use.

**Deliverables:**
- [ ] Directory structure created
- [ ] `scripts/install.sh` -- installation helper
- [ ] `shared-references/codex-review-criteria.md` -- Codex review criteria
- [ ] `shared-references/code-quality-principles.md` -- quality standards
- [ ] `shared-references/tdd-principles.md` -- TDD guidelines
- [ ] `templates/FEATURE_BRIEF.md` -- feature request template
- [ ] Updated `CLAUDE.md` with CCCXDevOps skill loading instructions
- [ ] `docs/INSTALLATION.md` -- installation guide
- [ ] `README.md` -- project overview

**Verification:** `install.sh` successfully copies skills to `~/.claude/skills/`, Codex MCP connectivity confirmed.

---

### Phase 2: Core Development Skills (the foundation skills)
**Goal:** Build the discipline skills and core development workflow. These are the most well-defined skills (adapted from superpowers) and form the foundation everything else builds on.

**Deliverables (order matters -- dependencies flow downward):**
- [ ] `cccx-tdd/SKILL.md` -- TDD discipline (used by all implementation skills)
- [ ] `cccx-verify/SKILL.md` -- verification discipline (used by all completion claims)
- [ ] `cccx-review/SKILL.md` -- Codex MCP review (used by all Codex checkpoints)
- [ ] `cccx-brainstorm/SKILL.md` -- design exploration
- [ ] `cccx-plan/SKILL.md` -- implementation planning
- [ ] `cccx-worktree/SKILL.md` -- git worktree management
- [ ] `cccx-implement/SKILL.md` + subagent prompts -- subagent-driven implementation
- [ ] `cccx-debug/SKILL.md` + supporting docs -- systematic debugging
- [ ] `cccx-finish/SKILL.md` -- branch completion
- [ ] `cccx-dev-pipeline/SKILL.md` -- full development pipeline

**Verification:** Run a small feature development end-to-end using `cccx-dev-pipeline`. Confirm Codex reviews occur at each gate. Confirm TDD discipline is enforced.

---

### Phase 3: Operations Skills
**Goal:** Build the operations workflow skills for deployment, monitoring, incident response, CI/CD, and infrastructure.

**Deliverables:**
- [ ] `shared-references/ops-checklists.md` -- operations checklists
- [ ] `templates/DEPLOYMENT_PLAN.md` -- deployment plan template
- [ ] `templates/INCIDENT_REPORT.md` -- incident report template
- [ ] `cccx-deploy/SKILL.md` -- deployment management
- [ ] `cccx-monitor/SKILL.md` -- health monitoring
- [ ] `cccx-incident/SKILL.md` -- incident response
- [ ] `cccx-ci-cd/SKILL.md` -- CI/CD pipeline management
- [ ] `cccx-infra/SKILL.md` -- infrastructure management
- [ ] `cccx-ops-pipeline/SKILL.md` -- full operations pipeline
- [ ] `scripts/health-check.sh` -- health check runner

**Verification:** Simulate a deployment + monitoring workflow. Confirm Codex reviews deployment plan before execution. Confirm rollback plan is enforced.

---

### Phase 4: Maintenance Skills
**Goal:** Build the maintenance workflow skills for dependency management, security, performance, tech debt, and documentation.

**Deliverables:**
- [ ] `shared-references/security-baselines.md` -- security standards
- [ ] `templates/MAINTENANCE_REQUEST.md` -- maintenance request template
- [ ] `cccx-deps/SKILL.md` -- dependency management
- [ ] `cccx-security/SKILL.md` -- security assessment
- [ ] `cccx-perf/SKILL.md` -- performance audit
- [ ] `cccx-tech-debt/SKILL.md` -- technical debt management
- [ ] `cccx-docs/SKILL.md` -- documentation maintenance
- [ ] `cccx-maint-pipeline/SKILL.md` -- full maintenance pipeline

**Verification:** Run maintenance sweep on a sample project. Confirm each step produces actionable output. Confirm Codex reviews at each gate.

---

### Phase 5: Integration & Meta Skills
**Goal:** Build the cross-cutting orchestrator, parallel dispatch, and skill-creation meta-skill. End-to-end testing of the full framework.

**Deliverables:**
- [ ] `cccx-pipeline/SKILL.md` -- full DevOps orchestrator
- [ ] `cccx-parallel/SKILL.md` -- parallel agent dispatch
- [ ] `cccx-writing-skills/SKILL.md` -- skill creation meta-skill
- [ ] `scripts/state-manager.sh` -- state file management
- [ ] `docs/SKILL_CATALOG.md` -- full skill reference documentation
- [ ] End-to-end test: `cccx-pipeline` for a feature (dev -> deploy -> maintain)

**Verification:** Full pipeline test across all three domains. Confirm state persistence and session recovery. Confirm all Codex review points function correctly.

---

## 9. Testing Strategy

### 9.1 Skill Testing (TDD for Documentation)

Following superpowers' approach: **test skills with pressure scenarios**.

For each skill:
1. **Baseline (RED):** Run scenario WITHOUT the skill loaded. Document agent behavior -- where does it cut corners?
2. **With Skill (GREEN):** Run same scenario WITH skill. Agent should now follow the discipline.
3. **Loophole Test (REFACTOR):** Try to find rationalizations that bypass the skill. Close them.

### 9.2 Integration Testing

For each pipeline skill:
1. Run the full chain on a small sample project
2. Verify each checkpoint is hit
3. Verify Codex reviews occur (mock Codex if needed for CI)
4. Verify state persistence works across session interruptions

### 9.3 Codex Review of This Plan

This plan itself should be reviewed by Codex for:
- **Completeness:** Are all DevOps scenarios covered?
- **Consistency:** Do skills reference each other correctly?
- **Feasibility:** Is the scope realistic? Are phases well-ordered?
- **Gaps:** Any missing skills, shared references, or templates?
- **Naming:** Is the `cccx-` prefix consistently applied?
- **Iron Laws:** Are discipline rules strong enough? Any missing guardrails?

---

## 10. Open Questions for Codex Review

1. **Scope granularity for ops skills:** Should `cccx-deploy` support all deployment strategies (rolling, blue-green, canary) in one skill, or should these be separate skills?

2. **Codex review depth:** Should every skill have a mandatory Codex checkpoint, or should some lightweight skills (e.g., `cccx-worktree`, `cccx-docs`) skip Codex review to reduce latency?

3. **State persistence format:** JSON files (like ARIS) or Markdown files (more human-readable)? Or both (JSON for machine, Markdown summary for humans)?

4. **Notification integration:** Should CCCXDevOps include notification support (Slack, Feishu, email) for long-running operations? ARIS has Feishu integration. Is this in scope?

5. **Multi-platform support:** Should skills support Codex-native versions (like ARIS's `skills-codex/` overlay)? Or keep it Claude Code-only for v1?

6. **Skill dependencies:** Should skills explicitly declare dependencies on other skills (e.g., `cccx-implement` depends on `cccx-tdd`)? Or keep it implicit in the workflow descriptions?

---

## 11. Success Criteria

The framework is successful when:

1. **A user can `cp -r` install and immediately use any skill** -- no configuration beyond Codex MCP setup
2. **Codex catches issues that Claude Code misses** -- demonstrable review value at each checkpoint
3. **TDD discipline is enforced** -- no production code without failing test, verified in practice
4. **All three domains work** -- Development, Operations, and Maintenance workflows produce reliable results
5. **Skills compose naturally** -- Run the full pipeline or any individual skill independently
6. **State survives interruptions** -- Long-running workflows can resume after context window limits or session breaks
7. **New skills are easy to create** -- The `cccx-writing-skills` meta-skill enables framework extension

---

## Appendix A: Skill Count Summary

| Domain | Skills | Pipeline |
|--------|--------|----------|
| Development | 10 | `cccx-dev-pipeline` |
| Operations | 6 | `cccx-ops-pipeline` |
| Maintenance | 6 | `cccx-maint-pipeline` |
| Cross-cutting | 3 | `cccx-pipeline` |
| **Total** | **25** | |

## Appendix B: Codex Review Checkpoints Summary

| Skill | Review Focus | Effort Level |
|-------|-------------|--------------|
| `cccx-brainstorm` | Design completeness, ambiguity, risks | high |
| `cccx-plan` | Plan completeness, task granularity, missing edges | high |
| `cccx-implement` | Architectural coherence across all tasks | xhigh |
| `cccx-finish` | Final diff review, merge readiness | high |
| `cccx-deploy` | Safety, rollback plan, blast radius | xhigh |
| `cccx-incident` | Post-mortem completeness, action items | high |
| `cccx-ci-cd` | Pipeline security, efficiency, correctness | high |
| `cccx-infra` | Security, cost, reliability | xhigh |
| `cccx-deps` | Update risk assessment accuracy | high |
| `cccx-security` | Findings completeness, remediation plan | xhigh |
| `cccx-perf` | Optimization correctness, regression risk | high |
| `cccx-tech-debt` | Refactoring plan regression risk | high |
| `cccx-docs` | Documentation accuracy | medium |

## Appendix C: Reference Mapping

| CCCXDevOps Skill | Primary Source | Adaptation |
|-----------------|----------------|------------|
| `cccx-brainstorm` | superpowers/brainstorming | + Codex checkpoint |
| `cccx-plan` | superpowers/writing-plans | + Codex checkpoint |
| `cccx-tdd` | superpowers/test-driven-development | Minimal changes |
| `cccx-implement` | superpowers/subagent-driven-dev | + Codex MCP review |
| `cccx-review` | ARIS Codex MCP pattern | + superpowers review format |
| `cccx-debug` | superpowers/systematic-debugging | + Codex consultation |
| `cccx-verify` | superpowers/verification-before-completion | Minimal changes |
| `cccx-worktree` | superpowers/using-git-worktrees | Simplified |
| `cccx-finish` | superpowers/finishing-a-dev-branch | + Codex final review |
| `cccx-parallel` | superpowers/dispatching-parallel-agents | Renamed with prefix |
| `cccx-writing-skills` | superpowers/writing-skills | Renamed with prefix |
| `cccx-deploy` | **New** | DevOps-specific |
| `cccx-monitor` | **New** | DevOps-specific |
| `cccx-incident` | **New** | DevOps-specific |
| `cccx-ci-cd` | **New** | DevOps-specific |
| `cccx-infra` | **New** | DevOps-specific |
| `cccx-deps` | **New** | DevOps-specific |
| `cccx-security` | **New** | DevOps-specific |
| `cccx-perf` | **New** | DevOps-specific |
| `cccx-tech-debt` | **New** | DevOps-specific |
| `cccx-docs` | **New** | DevOps-specific |
