#!/bin/bash
# workflow-smoke.sh -- Executable smoke test for the review file protocol
#
# Tests that the file-based review contract works end-to-end:
# - REVIEW_REQUEST.md structure and validation
# - REVIEW_RESPONSE.md structure and verdict paths
# - threadId round-trip across follow-up reviews
# - review-context.sh output for all 4 profiles
# - SKIPPED path
#
# Usage: bash tests/workflow-smoke.sh
#
# Does NOT require Claude Code or Codex -- tests the file protocol only.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
WORK_DIR=$(mktemp -d)
PASS=0
FAIL=0

cleanup() {
    rm -rf "$WORK_DIR"
}
trap cleanup EXIT

pass() {
    echo "  PASS  $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "  FAIL  $1"
    FAIL=$((FAIL + 1))
}

check_field() {
    local file="$1"
    local field="$2"
    local label="$3"
    if grep -q "^${field}:" "$file" 2>/dev/null; then
        pass "$label"
    else
        fail "$label (missing field: $field in $file)"
    fi
}

echo "=== CCCXDevOps Workflow Smoke Test ==="
echo "Working directory: $WORK_DIR"
echo ""

# ---------- Setup ----------
cd "$WORK_DIR"
git init -q
echo "test" > README.md
git add README.md
git commit -q -m "init"
mkdir -p .cccx/review

# ---------- Test 1: review-context.sh generates valid request ----------
echo "[1] review-context.sh output"

# Create a dummy design doc
mkdir -p docs/cccx/specs
echo "# Test Design" > docs/cccx/specs/test-design.md

bash "$REPO_DIR/scripts/review-context.sh" dev-design "test design" \
    --design-doc docs/cccx/specs/test-design.md > /dev/null 2>&1

if [ -f ".cccx/review/REVIEW_REQUEST.md" ]; then
    pass "dev-design request file created"
    check_field ".cccx/review/REVIEW_REQUEST.md" "profile" "dev-design has profile field"
    check_field ".cccx/review/REVIEW_REQUEST.md" "subject" "dev-design has subject field"
    check_field ".cccx/review/REVIEW_REQUEST.md" "timestamp" "dev-design has timestamp field"
    if grep -q "## Goal" ".cccx/review/REVIEW_REQUEST.md"; then
        pass "dev-design has Goal section"
    else
        fail "dev-design missing Goal section"
    fi
else
    fail "dev-design request file not created"
fi

# Test all 4 profiles generate valid output
for profile in dev-plan dev-implementation deploy-safety; do
    rm -f .cccx/review/REVIEW_REQUEST.md
    bash "$REPO_DIR/scripts/review-context.sh" "$profile" "test $profile" > /dev/null 2>&1
    if [ -f ".cccx/review/REVIEW_REQUEST.md" ]; then
        pass "$profile request file created"
    else
        fail "$profile request file not created"
    fi
done

# Regression: flags-only call (no subject arg) must not mangle flags
rm -f .cccx/review/REVIEW_REQUEST.md
mkdir -p docs/cccx/plans
echo "# Test Plan" > docs/cccx/plans/test-plan.md
bash "$REPO_DIR/scripts/review-context.sh" dev-plan \
    --plan-doc docs/cccx/plans/test-plan.md > /dev/null 2>&1
if grep -q "# Test Plan" .cccx/review/REVIEW_REQUEST.md 2>/dev/null; then
    pass "flags-only call: --plan-doc content included"
else
    fail "flags-only call: --plan-doc content missing (parser mangled flags)"
fi
echo ""

# ---------- Test 2: APPROVE response structure ----------
echo "[2] APPROVE verdict path"

cat > .cccx/review/REVIEW_RESPONSE.md <<'RESP'
---
verdict: APPROVE
risk: LOW
profile: dev-design
threadId: thread-abc-123
round: 1
timestamp: 2026-03-27T12:00:00Z
---

## Blockers
None.

## Questions
None.

## Required Evidence
None.

## Suggested Next Step
Proceed to implementation planning.

## Raw Reviewer Notes
Looks good.
RESP

check_field ".cccx/review/REVIEW_RESPONSE.md" "verdict" "APPROVE has verdict"
check_field ".cccx/review/REVIEW_RESPONSE.md" "threadId" "APPROVE has threadId"
check_field ".cccx/review/REVIEW_RESPONSE.md" "round" "APPROVE has round"

VERDICT=$(grep "^verdict:" .cccx/review/REVIEW_RESPONSE.md | head -1 | sed 's/verdict: *//')
if [ "$VERDICT" = "APPROVE" ]; then
    pass "APPROVE verdict correctly parsed"
else
    fail "APPROVE verdict incorrect: got '$VERDICT'"
fi
echo ""

# ---------- Test 3: REQUEST_CHANGES -> follow-up threadId round-trip ----------
echo "[3] threadId round-trip"

# Simulate: first review returned REQUEST_CHANGES with threadId
cat > .cccx/review/REVIEW_RESPONSE.md <<'RESP'
---
verdict: REQUEST_CHANGES
risk: MEDIUM
profile: dev-plan
threadId: thread-xyz-456
round: 1
timestamp: 2026-03-27T12:00:00Z
---

## Blockers
1. Missing edge case tests

## Questions
None.

## Required Evidence
Test output for empty input case.

## Suggested Next Step
Add the missing test, re-submit.

## Raw Reviewer Notes
Plan is mostly good but missing edge cases.
RESP

# Extract threadId from response
THREAD_ID=$(grep "^threadId:" .cccx/review/REVIEW_RESPONSE.md | head -1 | sed 's/threadId: *//')
if [ "$THREAD_ID" = "thread-xyz-456" ]; then
    pass "threadId extracted from response"
else
    fail "threadId extraction failed: got '$THREAD_ID'"
fi

# Simulate: caller uses review-context.sh with --thread-id for follow-up
bash "$REPO_DIR/scripts/review-context.sh" dev-plan "test plan follow-up" \
    --thread-id "$THREAD_ID" \
    --changes "Added edge case test for empty input (tests/empty.test.js). Test output: 5 passing, 0 failing." \
    > /dev/null 2>&1

# Verify threadId survived the round-trip through the helper script
ROUNDTRIP_ID=$(grep "^threadId:" .cccx/review/REVIEW_REQUEST.md | head -1 | sed 's/threadId: *//')
if [ "$ROUNDTRIP_ID" = "thread-xyz-456" ]; then
    pass "threadId round-trip via review-context.sh"
else
    fail "threadId round-trip broken: got '$ROUNDTRIP_ID'"
fi

# Verify follow-up has Changes section (generated by helper)
if grep -q "## Changes Since Last Review" .cccx/review/REVIEW_REQUEST.md; then
    pass "follow-up has Changes Since Last Review section (via helper)"
else
    fail "follow-up missing Changes Since Last Review section"
fi

# Verify first-round request does NOT have threadId
rm -f .cccx/review/REVIEW_REQUEST.md
bash "$REPO_DIR/scripts/review-context.sh" dev-design "first review" > /dev/null 2>&1
if grep -q "^threadId:" .cccx/review/REVIEW_REQUEST.md 2>/dev/null; then
    fail "first-round request should NOT have threadId"
else
    pass "first-round request correctly omits threadId"
fi
echo ""

# ---------- Test 4: BLOCK response ----------
echo "[4] BLOCK verdict path"

cat > .cccx/review/REVIEW_RESPONSE.md <<'RESP'
---
verdict: BLOCK
risk: CRITICAL
profile: deploy-safety
threadId: thread-block-789
round: 1
timestamp: 2026-03-27T13:00:00Z
---

## Blockers
1. No rollback plan documented
2. SQL injection vulnerability

## Questions
None.

## Required Evidence
Rollback steps and parameterized queries.

## Suggested Next Step
STOP. Present to user.

## Raw Reviewer Notes
Critical issues found.
RESP

VERDICT=$(grep "^verdict:" .cccx/review/REVIEW_RESPONSE.md | head -1 | sed 's/verdict: *//')
RISK=$(grep "^risk:" .cccx/review/REVIEW_RESPONSE.md | head -1 | sed 's/risk: *//')
if [ "$VERDICT" = "BLOCK" ] && [ "$RISK" = "CRITICAL" ]; then
    pass "BLOCK verdict with CRITICAL risk"
else
    fail "BLOCK verdict incorrect: verdict='$VERDICT' risk='$RISK'"
fi
echo ""

# ---------- Test 5: SKIPPED response ----------
echo "[5] SKIPPED verdict path"

cat > .cccx/review/REVIEW_RESPONSE.md <<'RESP'
---
verdict: SKIPPED
risk: UNKNOWN
profile: dev-design
threadId: none
round: 0
timestamp: 2026-03-27T14:00:00Z
---

## Blockers
N/A

## Questions
N/A

## Required Evidence
N/A

## Suggested Next Step
Proceed without external review.

## Raw Reviewer Notes
Review was skipped: Codex MCP not configured.
RESP

VERDICT=$(grep "^verdict:" .cccx/review/REVIEW_RESPONSE.md | head -1 | sed 's/verdict: *//')
THREAD_ID=$(grep "^threadId:" .cccx/review/REVIEW_RESPONSE.md | head -1 | sed 's/threadId: *//')
if [ "$VERDICT" = "SKIPPED" ] && [ "$THREAD_ID" = "none" ]; then
    pass "SKIPPED verdict with no threadId"
else
    fail "SKIPPED verdict incorrect: verdict='$VERDICT' threadId='$THREAD_ID'"
fi
echo ""

# ---------- Test 6: mini-calculator fixture ----------
echo "[6] Fixture project"

if [ -f "$REPO_DIR/tests/fixtures/mini-calculator/package.json" ]; then
    cd "$REPO_DIR/tests/fixtures/mini-calculator"
    OUTPUT=$(node --test tests/*.test.js 2>&1)
    if echo "$OUTPUT" | grep -q "pass 2"; then
        pass "mini-calculator: 2 tests passing"
    else
        fail "mini-calculator: unexpected test output"
    fi
    cd "$WORK_DIR"
else
    fail "mini-calculator fixture not found"
fi
echo ""

# ---------- Summary ----------
echo "=== Results: $PASS passed, $FAIL failed ==="
if [ "$FAIL" -gt 0 ]; then
    echo "Workflow smoke test has failures."
    exit 1
else
    echo "Workflow smoke test passed."
    exit 0
fi
