#!/bin/bash
# verify-install.sh -- Verify CCCXDevOps installation integrity
# Run after install.sh to confirm all files are in place and paths resolve.
# Usage: bash tests/verify-install.sh [--with-scripts]

set -euo pipefail

SKILLS_DIR="$HOME/.claude/skills"
SCRIPTS_DIR="$HOME/.claude/scripts"
CHECK_SCRIPTS=false
PASS=0
FAIL=0

for arg in "$@"; do
    case "$arg" in
        --with-scripts) CHECK_SCRIPTS=true ;;
    esac
done

check() {
    local label="$1"
    local path="$2"
    if [ -e "$path" ]; then
        echo "  PASS  $label"
        PASS=$((PASS + 1))
    else
        echo "  FAIL  $label  (missing: $path)"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== CCCXDevOps Install Verification ==="
echo ""

echo "[Skills]"
check "cccx-using-devops" "$SKILLS_DIR/cccx-using-devops/SKILL.md"
check "cccx-brainstorm"   "$SKILLS_DIR/cccx-brainstorm/SKILL.md"
check "cccx-plan"         "$SKILLS_DIR/cccx-plan/SKILL.md"
check "cccx-tdd"          "$SKILLS_DIR/cccx-tdd/SKILL.md"
check "cccx-tdd antipatterns" "$SKILLS_DIR/cccx-tdd/testing-anti-patterns.md"
check "cccx-implement"    "$SKILLS_DIR/cccx-implement/SKILL.md"
check "cccx-implement implementer-prompt" "$SKILLS_DIR/cccx-implement/implementer-prompt.md"
check "cccx-implement spec-reviewer"      "$SKILLS_DIR/cccx-implement/spec-reviewer-prompt.md"
check "cccx-implement quality-reviewer"   "$SKILLS_DIR/cccx-implement/code-quality-reviewer-prompt.md"
check "cccx-review"       "$SKILLS_DIR/cccx-review/SKILL.md"
check "cccx-verify"       "$SKILLS_DIR/cccx-verify/SKILL.md"
check "cccx-debug"        "$SKILLS_DIR/cccx-debug/SKILL.md"
check "cccx-debug root-cause" "$SKILLS_DIR/cccx-debug/root-cause-tracing.md"
check "cccx-debug defense"    "$SKILLS_DIR/cccx-debug/defense-in-depth.md"
check "cccx-worktree"     "$SKILLS_DIR/cccx-worktree/SKILL.md"
check "cccx-finish"       "$SKILLS_DIR/cccx-finish/SKILL.md"
check "cccx-dev-pipeline" "$SKILLS_DIR/cccx-dev-pipeline/SKILL.md"
check "cccx-deploy"       "$SKILLS_DIR/cccx-deploy/SKILL.md"
check "cccx-monitor"      "$SKILLS_DIR/cccx-monitor/SKILL.md"
echo ""

echo "[Shared References]"
check "code-quality-principles" "$SKILLS_DIR/shared-references/code-quality-principles.md"
check "tdd-principles"          "$SKILLS_DIR/shared-references/tdd-principles.md"
check "deploy-safety-checklist" "$SKILLS_DIR/shared-references/deploy-safety-checklist.md"
check "review-profile: dev-design"         "$SKILLS_DIR/shared-references/review-profiles/dev-design.md"
check "review-profile: dev-plan"           "$SKILLS_DIR/shared-references/review-profiles/dev-plan.md"
check "review-profile: dev-implementation" "$SKILLS_DIR/shared-references/review-profiles/dev-implementation.md"
check "review-profile: deploy-safety"      "$SKILLS_DIR/shared-references/review-profiles/deploy-safety.md"
echo ""

echo "[No Nesting Check]"
NESTED=false
for skill_dir in "$SKILLS_DIR"/cccx-*/; do
    if [ -d "$skill_dir" ]; then
        skill_name="$(basename "$skill_dir")"
        if [ -d "$skill_dir/$skill_name" ]; then
            echo "  FAIL  $skill_name has nested directory (re-install bug)"
            FAIL=$((FAIL + 1))
            NESTED=true
        fi
    fi
done
if [ "$NESTED" = false ]; then
    echo "  PASS  No nested skill directories found"
    PASS=$((PASS + 1))
fi
echo ""

if [ "$CHECK_SCRIPTS" = true ]; then
    echo "[Scripts]"
    check "health-check.sh"   "$SCRIPTS_DIR/health-check.sh"
    check "review-context.sh" "$SCRIPTS_DIR/review-context.sh"
    echo ""
fi

echo "[Self-Containment Check]"
# Verify cccx-review has inlined profiles (not external file references)
if grep -q "Profile: dev-design" "$SKILLS_DIR/cccx-review/SKILL.md" 2>/dev/null; then
    echo "  PASS  cccx-review has inlined review profiles"
    PASS=$((PASS + 1))
else
    echo "  FAIL  cccx-review missing inlined review profiles"
    FAIL=$((FAIL + 1))
fi
echo ""

echo "=== Results: $PASS passed, $FAIL failed ==="
if [ "$FAIL" -gt 0 ]; then
    echo "Installation has issues. Re-run scripts/install.sh."
    exit 1
else
    echo "Installation verified successfully."
    exit 0
fi
