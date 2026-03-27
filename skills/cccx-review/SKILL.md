---
name: cccx-review
description: Use when a workflow checkpoint requires external Codex review. This is the only skill that directly calls Codex MCP. Other skills invoke this with a review profile name.
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob, mcp__codex__codex, mcp__codex__codex-reply
---

# Codex Review Gateway

## Overview

Central review gateway for all CCCXDevOps workflows. Only this skill directly invokes Codex MCP. Other skills request review by writing a `REVIEW_REQUEST.md` and invoking this skill with a profile name.

## When to Use

- When another cccx skill reaches a review checkpoint
- When explicitly asked to get external review on any artifact
- Never directly by the user for ad-hoc questions (use Codex directly for that)

## Workflow

### Phase 1: Read the Review Request

1. Read `.cccx/review/REVIEW_REQUEST.md`
2. Verify it contains: profile, subject, goal, context, evidence
3. If the file is missing or incomplete, ask the calling workflow to provide it

If no REVIEW_REQUEST.md exists but the caller provided context inline, create one from the provided information.

### Phase 2: Load the Review Profile

Use the matching profile from the **Inlined Review Profiles** section below. Do NOT attempt to read external profile files -- the profiles are embedded in this skill.

### Phase 3: Assemble the Codex Prompt

Combine:

1. Review intent (from profile)
2. Subject and goal (from request)
3. Context and evidence (from request, bounded)
4. Review questions (from profile)
5. Constraints (from request)
6. Focal questions (from request, if any)

End the prompt with:

```
Respond using this structure:
- VERDICT: APPROVE | REQUEST_CHANGES | BLOCK
- RISK: LOW | MEDIUM | HIGH | CRITICAL
- BLOCKERS: concrete issues that prevent proceeding (or "None")
- QUESTIONS: anything unresolved (or "None")
- REQUIRED_EVIDENCE: what must be shown before approval (or "None")
- SUGGESTED_NEXT_STEP: smallest safe next action
```

### Phase 4: Call Codex MCP

**First review in this workflow:**
- Use `mcp__codex__codex` with config `{"model_reasoning_effort": "high"}`
- For deploy-safety or dev-implementation profiles, use `{"model_reasoning_effort": "xhigh"}`
- Save the returned `threadId`

**Follow-up review (after changes):**
- Use `mcp__codex__codex-reply` with the saved `threadId`
- Include what changed since the last review

**If Codex MCP is not available:**
- Write `.cccx/review/REVIEW_RESPONSE.md` with verdict `SKIPPED`
- Report to calling workflow: "External review skipped: Codex MCP not configured."
- Do NOT pretend the review happened
- Do NOT fabricate a review response

### Phase 5: Parse and Write Response

1. Parse the Codex response into the verdict schema
2. Write `.cccx/review/REVIEW_RESPONSE.md` with:

```markdown
---
verdict: APPROVE | REQUEST_CHANGES | BLOCK | SKIPPED
risk: LOW | MEDIUM | HIGH | CRITICAL | UNKNOWN
profile: <profile-name>
timestamp: <ISO 8601>
---

## Blockers
<from Codex response, or "N/A" if SKIPPED>

## Questions
<from Codex response, or "N/A" if SKIPPED>

## Required Evidence
<from Codex response, or "N/A" if SKIPPED>

## Suggested Next Step
<from Codex response, or "Proceed without external review" if SKIPPED>

## Raw Reviewer Notes
<full Codex response for reference, or "Review was skipped: Codex MCP not configured" if SKIPPED>
```

### Phase 6: Report to Calling Workflow

- **APPROVE**: Report approval. Calling workflow proceeds.
- **REQUEST_CHANGES**: Report issues. Calling workflow addresses them, then re-submits (back to Phase 1 with updated request).
- **BLOCK**: Report blockers. STOP. Present to user. Do not auto-proceed.
- **SKIPPED**: Report that external review was not performed. Calling workflow proceeds with a visible warning to the user.

### Retry Policy

- Max 3 review rounds per checkpoint
- If still REQUEST_CHANGES after 3 rounds: escalate to human
- If BLOCK at any round: immediate human escalation
- Each round uses `mcp__codex__codex-reply` to maintain thread context

---

## Inlined Review Profiles

### Profile: dev-design

**Intent:** Evaluate a design document for completeness, clarity, and risk before implementation planning.

**Required evidence:** Design document (full text), feature brief or user request, relevant project context.

**Review questions:**
1. Does the design address all stated requirements?
2. Are there vague or underspecified sections?
3. What risks or failure modes are unaddressed?
4. Is the scope appropriate?
5. Can the design be verified with automated tests?
6. Were trade-offs between approaches considered?

**Thresholds:** APPROVE if clear, complete, reasonable risk handling. REQUEST_CHANGES if gaps/ambiguity would cause planning problems. BLOCK if fundamentally flawed.

### Profile: dev-plan

**Intent:** Evaluate an implementation plan for completeness, task granularity, and executability.

**Required evidence:** Implementation plan (full text), approved design document, project structure listing.

**Review questions:**
1. Are all tasks at 2-5 minute granularity?
2. Does every design requirement have a corresponding task?
3. Are there placeholders (TBD, TODO, "similar to Task N")?
4. Do all file paths exist or are clearly new?
5. Does every feature task have a test task?
6. Can tasks be executed in stated order?
7. Are commands complete and runnable?
8. Are edge cases covered?

**Thresholds:** APPROVE if executable as-is. REQUEST_CHANGES if gaps or ambiguous steps. BLOCK if misaligned with design.

### Profile: dev-implementation

**Intent:** Evaluate a completed implementation for code quality, test coverage, spec compliance, and coherence.

**Required evidence:** Git diff, test output (full suite), implementation plan, commit log.

**Review questions:**
1. Does implementation match the plan? Nothing extra, nothing missing?
2. Does every function have a test? Written test-first?
3. Are files focused (single responsibility)? Interfaces clean?
4. Does code follow existing codebase conventions?
5. Are errors handled at boundaries?
6. Any speculative code not in the plan?
7. Architectural coherence? Circular dependencies?
8. Any security vulnerabilities?

**Thresholds:** APPROVE if clean, tested, matches spec. REQUEST_CHANGES if quality issues or missing tests. BLOCK if architectural problems or security vulnerabilities.

### Profile: deploy-safety

**Intent:** Evaluate a deployment plan for safety, rollback coverage, and blast radius.

**Required evidence:** SERVICE_PROFILE.md, deployment plan, test results, current service health.

**Review questions:**
1. Is rollback documented and verified?
2. Which users/services are affected? Scope contained?
3. Are post-deployment validation commands defined?
4. Is there a monitoring period with escalation path?
5. Do all pre-flight checks pass?
6. For production: staged/canary approach or justified all-at-once?
7. New secrets handled safely?
8. Depends on other service updates?

**Thresholds:** APPROVE if safe, rollback documented, validation defined. REQUEST_CHANGES if missing rollback or unclear blast radius. BLOCK if no rollback, untested code, or production without confirmation. Auto-BLOCK if SERVICE_PROFILE.md is missing.

---

## Red Flags

- Calling a review "passed" without actually invoking Codex
- Fabricating a review response when MCP is unavailable
- Sending unbounded context (entire codebase) instead of focused evidence
- Ignoring BLOCK verdict and proceeding anyway
- Skipping review to "save time"

## Common Mistakes

| Mistake | Fix |
|---|---|
| Sending full repo as context | Send only relevant files, diffs, and test output |
| No thread continuity | Always use `mcp__codex__codex-reply` for follow-ups |
| Ignoring BLOCK | BLOCK means STOP. Present to user immediately |
| Review without evidence | Always include commands run, output received, diffs |
