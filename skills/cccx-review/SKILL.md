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

Read the matching profile from `shared-references/review-profiles/`:

- `dev-design` -> `review-profiles/dev-design.md`
- `dev-plan` -> `review-profiles/dev-plan.md`
- `dev-implementation` -> `review-profiles/dev-implementation.md`
- `deploy-safety` -> `review-profiles/deploy-safety.md`

The profile defines: review intent, required evidence, review questions, and approval thresholds.

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
- Report: "External review skipped: Codex MCP not configured."
- Do NOT pretend the review happened
- Do NOT fabricate a review response
- The calling workflow must note the skip and decide whether to proceed with a warning

### Phase 5: Parse and Write Response

1. Parse the Codex response into the verdict schema
2. Write `.cccx/review/REVIEW_RESPONSE.md` with:

```markdown
---
verdict: APPROVE | REQUEST_CHANGES | BLOCK
risk: LOW | MEDIUM | HIGH | CRITICAL
profile: <profile-name>
timestamp: <ISO 8601>
---

## Blockers
<from Codex response>

## Questions
<from Codex response>

## Required Evidence
<from Codex response>

## Suggested Next Step
<from Codex response>

## Raw Reviewer Notes
<full Codex response for reference>
```

### Phase 6: Report to Calling Workflow

- **APPROVE**: Report approval. Calling workflow proceeds.
- **REQUEST_CHANGES**: Report issues. Calling workflow addresses them, then re-submits (back to Phase 1 with updated request).
- **BLOCK**: Report blockers. STOP. Present to user. Do not auto-proceed.

### Retry Policy

- Max 3 review rounds per checkpoint
- If still REQUEST_CHANGES after 3 rounds: escalate to human
- If BLOCK at any round: immediate human escalation
- Each round uses `mcp__codex__codex-reply` to maintain thread context

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
