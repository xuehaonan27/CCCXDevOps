# Mocked Review Tests

Tests that validate `cccx-review` behavior using mocked Codex responses instead of live MCP calls.

## How to Run (v1)

These tests verify that `cccx-review` correctly handles all verdict paths by reading pre-written REVIEW_RESPONSE.md files.

1. Place a test REVIEW_REQUEST.md in `.cccx/review/`
2. Place the corresponding mock REVIEW_RESPONSE.md (from fixtures below)
3. Invoke `cccx-review` and verify it interprets the response correctly
4. Mark PASS or FAIL

For live Codex smoke tests, set `LIVE_CODEX=1` in environment.

## Mock Fixtures

### M1: APPROVE path

**File:** `mocks/approve-response.md`

```markdown
---
verdict: APPROVE
risk: LOW
---

## Blockers

None.

## Questions

None.

## Required Evidence

None -- all evidence was sufficient.

## Suggested Next Step

Proceed to implementation.
```

**Expected behavior:** `cccx-review` reports approval. Calling skill proceeds to next phase.

---

### M2: REQUEST_CHANGES path

**File:** `mocks/request-changes-response.md`

```markdown
---
verdict: REQUEST_CHANGES
risk: MEDIUM
---

## Blockers

1. Missing error handling for network timeout in `src/api/client.ts:45`
2. Test for edge case (empty input) not present

## Questions

- Is the 30-second timeout intentional or a placeholder?

## Required Evidence

- Test output showing the empty-input edge case is covered
- Confirmation that timeout value is intentional

## Suggested Next Step

Address blockers 1 and 2, then re-submit for review.
```

**Expected behavior:** `cccx-review` reports changes needed. Calling skill addresses blockers and re-submits via `mcp__codex__codex-reply`.

---

### M3: BLOCK path

**File:** `mocks/block-response.md`

```markdown
---
verdict: BLOCK
risk: CRITICAL
---

## Blockers

1. SQL injection vulnerability in `src/db/queries.ts:23` -- user input is interpolated directly into query string
2. No rollback plan documented for production deployment
3. Authentication bypass: admin endpoint has no auth middleware

## Questions

- Was the missing auth middleware intentional for development?

## Required Evidence

- Parameterized query replacing string interpolation
- Complete rollback plan in DEPLOYMENT_PLAN.md
- Auth middleware added to admin routes with test

## Suggested Next Step

STOP. Present blockers to human. Do not proceed without human decision.
```

**Expected behavior:** `cccx-review` reports blocking issues. Calling skill STOPS and presents blockers to user. Does not auto-proceed.

---

### M4: Thread follow-up path

**Scenario:** After M2 (REQUEST_CHANGES), the caller fixes issues and re-submits.

**Expected behavior:**
1. `cccx-review` uses `mcp__codex__codex-reply` with saved `threadId`
2. Follow-up prompt includes what changed since last review
3. Max 3 follow-up rounds before escalating to human

---

### M5: Missing Codex MCP (graceful degradation)

**Scenario:** Codex MCP is not configured. `cccx-review` is invoked.

**Expected behavior:**
- `cccx-review` detects MCP is unavailable
- Reports that external review was skipped (not silently ignored)
- Calling skill notes the skip and proceeds with a warning
- Does NOT pretend review happened
