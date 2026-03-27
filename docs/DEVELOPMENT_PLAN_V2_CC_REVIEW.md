# DEVELOPMENT_PLAN v2 -- Claude Code Review

> **Date:** 2026-03-27
> **Reviewer:** Claude Code (Opus 4.6)
> **Reviewing:** DEVELOPMENT_PLAN.md v2 by Codex
> **Focus:** Architecture, scope, safety, validation (per review brief)

---

## Overall Assessment

**VERDICT: APPROVE with minor additions**

v2 is a significant improvement over v1. The three biggest wins:

1. **Review centralization in `cccx-review`** eliminates the #1 maintenance risk from v1
2. **Scope reduction to a validated vertical slice** is the correct call -- v1 was trying to ship 25 skills before proving 1 worked
3. **Testing in Phase 1** prevents "documentation-only" progress

I agree with all explicit rejections from v1 (Section 3.3). Below I address the 5 review questions, then flag a few concrete items.

---

## Review Question Responses

### Q1: Is `cccx-review` as the single direct MCP owner the right abstraction?

**Yes. This is the strongest architectural improvement from v1.**

In v1, every skill embedded its own `mcp__codex__codex` calls with inline prompt assembly. That would have caused:

- Duplicated prompt templates in 13+ skills
- Inconsistent review request formats across domains
- Difficult mocking (each skill needs its own mock path)
- Hard to evolve the transport (Codex MCP API changes require touching every skill)

With `cccx-review` as the sole owner, we get one entry point to mock, one place to change transport, and consistent request/response contracts.

**One implementation detail needs resolving:** How calling skills pass structured review requests to `cccx-review`. Options:

| Approach | Pros | Cons |
|----------|------|------|
| A. Write a temp file (`REVIEW_REQUEST.md`) | Simple, inspectable, testable | File management overhead |
| B. Pass structured argument string | No file I/O | Harder to read, size limits |
| C. Have `cccx-review` read context itself using profile rules | Calling skill just says "review profile=dev-design" | Less explicit, review skill needs to know where to find things |

**Recommendation:** Option A for v1. The calling skill writes a structured `REVIEW_REQUEST.md` with profile, subject, goal, context, evidence. `cccx-review` reads it, assembles the prompt, calls Codex, writes `REVIEW_RESPONSE.md`. This is inspectable, testable, and works naturally with Claude Code's file-based workflow. The `review-context.sh` script can help generate the evidence section.

### Q2: Is the reduced v1 scope small enough to validate the framework?

**Yes.** The v1 slice is:

- 1 bootstrap + 10 dev + 2 ops = 13 skills total
- 4 review profiles
- 3 scripts
- 3 templates
- 4 test layers

This proves every architectural decision:
- Skill format works (13 skills across 2 domains)
- Review gateway works (4 profiles, all verdict paths)
- TDD discipline enforcement works (dev workflow)
- Ops safety model works (deploy + monitor with guardrails)

If this slice fails, we learn cheaply. If it succeeds, adding maintenance and broader ops is incremental work on a proven foundation.

### Q3: Is `cccx-using-devops` sufficient as the bootstrap/enforcement layer?

**Yes, with one clarification needed: how it gets loaded.**

The bootstrap skill must activate automatically at session start, not only when the user explicitly types `/cccx-using-devops`. Without auto-activation, the enforcement is opt-in, which defeats the purpose.

**Recommended activation mechanism:** The `install.sh` script should add a note to the user's project `CLAUDE.md` (or print instructions for doing so) that references `cccx-using-devops`:

```markdown
## CCCXDevOps
When working in this project, always check CCCXDevOps skills before taking action.
Invoke /cccx-using-devops at session start.
```

Alternatively, a Claude Code session-start hook could invoke it automatically (like superpowers' `hooks/hooks.json`). But that requires more installation complexity. For v1, a CLAUDE.md instruction is simpler and sufficient.

### Q4: Are the deploy pilot guardrails realistic and strict enough?

**Yes. The guardrails are well-calibrated -- strict enough to be safe, permissive enough to be useful.**

The key guardrails:
- `SERVICE_PROFILE.md` required (no infrastructure guessing)
- Rollback steps documented before execution
- No production deploy without explicit user confirmation
- No automatic strategy selection
- No silent rollback logic

**One small addition to `SERVICE_PROFILE.md`:** Include a `validation_commands` section -- commands that verify the deployment succeeded beyond health checks. Example:

```markdown
## Validation Commands
# Commands to run after deployment to verify success
- `curl -s https://api.example.com/version | jq .version` -- should show new version
- `kubectl get pods -n prod -l app=myservice | grep Running` -- all pods running
```

This gives `cccx-deploy` a concrete, project-specific way to verify without inventing checks.

### Q5: Is the testing plan concrete enough to prevent "documentation-only" progress?

**Mostly yes.** The minimum deliverables are specific:
- 3+ trigger tests
- 5+ skill-content tests
- Mocked review tests for all verdict types
- 1 end-to-end dev workflow fixture

**One gap: trigger test mechanism.** Testing that "a feature request triggers `cccx-brainstorm`" is non-trivial in Claude Code. You can't unit-test Claude's skill-selection reasoning.

**Recommended approach for trigger tests:**

```markdown
# tests/skill-triggering/brainstorm-triggers.md

## Test: Feature request should trigger cccx-brainstorm

Prompt: "I want to add user authentication to this app"
Expected: cccx-brainstorm is invoked before any code is written

## Test: Bug report should NOT trigger cccx-brainstorm

Prompt: "The login button is broken on mobile"
Expected: cccx-debug is invoked, NOT cccx-brainstorm
```

These are manual test cases (prompt + expected skill) that a human or automated harness runs against Claude Code. For v1, manual verification is acceptable. For v2+, we could explore Claude Code API-based automated trigger testing.

---

## Additional Items

### A1: Skill invocation chain clarity

The plan should specify how pipeline skills chain sub-skills. In Claude Code, this happens via the `Skill` tool. The `cccx-dev-pipeline` skill should explicitly instruct Claude to invoke each sub-skill in sequence using `Skill`, not by inlining the sub-skill's workflow.

This matters because:
- Sub-skills may be updated independently
- Inlining duplicates content and drifts
- The `Skill` tool invocation makes the chain visible and testable

### A2: `review-context.sh` is valuable -- keep it

The script that deterministically collects review evidence (design doc, git diffs, deploy plans) makes reviews:
- Consistent (same evidence format every time)
- Testable (script output can be diff-tested)
- Inspectable (user can see exactly what's being sent to Codex)

This is worth the small script complexity.

### A3: Future K8s maintenance via review profiles is the right approach

Section 6.8 correctly identifies that adding K8s maintenance should start as a review profile (`k8s-maintenance`), not a full automation skill. The review gateway absorbs new domains at low cost. This validates the `cccx-review` centralization decision.

### A4: Phase 5 as an expansion gate is important

The explicit gate before adding more skills ("is v1 reliable enough?") prevents scope creep. The exit criteria are concrete:
- Development workflow reliable in repeated tests
- Review gateway stable
- Ops pilot useful without false confidence
- Claude Code / Codex roles clear in practice

---

## Summary

| Question | Answer |
|----------|--------|
| Q1: `cccx-review` ownership | Yes, right boundary. Resolve request-passing mechanism (recommend file-based). |
| Q2: Scope small enough | Yes. 13 skills + 4 profiles proves every architectural decision. |
| Q3: Bootstrap sufficient | Yes, but specify auto-activation mechanism (CLAUDE.md or hook). |
| Q4: Deploy guardrails | Yes, strict enough. Add `validation_commands` to SERVICE_PROFILE. |
| Q5: Testing concrete | Mostly. Clarify trigger test mechanism (manual test cases for v1). |

**Recommendation: Proceed with v2 as the working plan. The items above are minor additions, not blockers.**
