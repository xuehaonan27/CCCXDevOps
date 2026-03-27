---
name: cccx-verify
description: Use before any success or completion claim. Enforces evidence-based verification -- no "should work" or "probably passes" allowed.
---

# Verification Before Completion

## Overview

No completion claim without fresh verification evidence. This is a discipline skill enforced before any assertion of success.

**Iron Law: NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE**

## When to Use

Before ANY of these:
- "Tests pass"
- "Build succeeds"
- "Bug is fixed"
- "Feature is complete"
- "Deployment succeeded"
- "Service is healthy"
- Any positive status claim

## Workflow

### The Gate Function

```
BEFORE claiming any status:
  1. IDENTIFY: What command proves this claim?
  2. RUN: Execute the full command (fresh, not cached)
  3. READ: Full output. Check exit code. Count failures.
  4. VERIFY: Does output actually confirm the claim?
     - NO  -> State actual status with evidence
     - YES -> State claim WITH evidence
  5. ONLY THEN: Make the claim
```

### Evidence Requirements

| Claim | Requires | NOT Sufficient |
|---|---|---|
| "Tests pass" | Test command output showing 0 failures | Previous run, "should pass", partial run |
| "Build succeeds" | Build command output with exit 0 | "Linter passed" (linter != build) |
| "Bug is fixed" | Test of original symptom passes | "Code changed, should be fixed" |
| "Linter clean" | Linter output showing 0 errors | Partial check, extrapolation |
| "Deploy succeeded" | Health check + validation commands pass | "Deploy command exited 0" |
| "Service healthy" | Health endpoint returns expected status | "It was healthy earlier" |

### Regression Test Verification

For bug fixes, the full cycle must be verified:

```
1. Write test for the bug     -> test FAILS (proves test catches the bug)
2. Fix the bug                -> test PASSES (proves fix works)
3. Revert the fix temporarily -> test FAILS again (proves test is real)
4. Restore the fix            -> test PASSES (proves fix is stable)
```

If step 3 is impractical, at minimum steps 1-2 must be verified with fresh output.

## Forbidden Language

These words in a completion claim indicate missing verification:

- "should"
- "probably"
- "seems to"
- "looks correct"
- "I think"
- "appears to"
- "likely"

**Replace with evidence:**

```
BAD:  "Tests should pass now."
GOOD: "All 47 tests pass (npm test output: 47 passing, 0 failing, exit 0)."

BAD:  "The build looks correct."
GOOD: "Build succeeds (cargo build --release: exit 0, no warnings)."
```

## Red Flags

STOP if you notice yourself:

- Using "should", "probably", or "seems to" before a status claim
- Expressing satisfaction before running verification
- About to commit/push/PR without fresh test output
- Relying on a previous test run (context may have changed)
- Trusting a subagent's success report without independent verification
- Thinking "just this once I can skip verification"
- Feeling tired and wanting the work to be done

## Quick Reference

```
ALWAYS:  [Run command] -> [Read output] -> [Cite evidence] -> [Make claim]
NEVER:   [Make claim] -> [Hope it's true]
```
