#!/bin/bash
# review-context.sh -- Gather evidence bundles for cccx-review
# Usage: bash review-context.sh <profile> [options]
#
# Profiles:
#   dev-design          Gather design document context
#   dev-plan            Gather implementation plan context
#   dev-implementation  Gather git diff + test results context
#   deploy-safety       Gather deployment plan + service profile context
#
# Output: Writes .cccx/review/REVIEW_REQUEST.md

set -euo pipefail

PROFILE="${1:-}"
SUBJECT="${2:-}"
REVIEW_DIR=".cccx/review"

usage() {
    echo "Usage: bash review-context.sh <profile> [subject]"
    echo ""
    echo "Profiles:"
    echo "  dev-design          Design document review"
    echo "  dev-plan            Implementation plan review"
    echo "  dev-implementation  Code diff + test output review"
    echo "  deploy-safety       Deployment plan + service profile review"
    echo ""
    echo "Options:"
    echo "  --design-doc PATH   Path to design document (dev-design)"
    echo "  --plan-doc PATH     Path to implementation plan (dev-plan)"
    echo "  --base-sha SHA      Base commit for diff (dev-implementation)"
    echo "  --head-sha SHA      Head commit for diff (dev-implementation)"
    echo "  --service-profile PATH  Path to SERVICE_PROFILE.md (deploy-safety)"
    echo "  --deploy-plan PATH  Path to deployment plan (deploy-safety)"
    echo "  --thread-id ID      Thread ID from previous REVIEW_RESPONSE.md (follow-up reviews)"
    echo "  --changes TEXT      Description of changes since last review (follow-up reviews)"
    exit 1
}

if [ -z "$PROFILE" ]; then
    usage
fi

mkdir -p "$REVIEW_DIR"

# Parse optional flags
DESIGN_DOC=""
PLAN_DOC=""
BASE_SHA=""
HEAD_SHA=""
SERVICE_PROFILE=""
DEPLOY_PLAN=""
THREAD_ID=""
CHANGES_DESCRIPTION=""

shift
shift 2>/dev/null || true

while [ $# -gt 0 ]; do
    case "$1" in
        --design-doc) DESIGN_DOC="$2"; shift 2 ;;
        --plan-doc) PLAN_DOC="$2"; shift 2 ;;
        --base-sha) BASE_SHA="$2"; shift 2 ;;
        --head-sha) HEAD_SHA="$2"; shift 2 ;;
        --service-profile) SERVICE_PROFILE="$2"; shift 2 ;;
        --deploy-plan) DEPLOY_PLAN="$2"; shift 2 ;;
        --thread-id) THREAD_ID="$2"; shift 2 ;;
        --changes) CHANGES_DESCRIPTION="$2"; shift 2 ;;
        *) SUBJECT="$1"; shift ;;
    esac
done

write_header() {
    {
        echo "---"
        echo "profile: $PROFILE"
        echo "subject: $SUBJECT"
        if [ -n "$THREAD_ID" ]; then
            echo "threadId: $THREAD_ID"
        fi
        echo "timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
        echo "---"
        echo ""
    } > "$REVIEW_DIR/REVIEW_REQUEST.md"
}

append_changes_section() {
    if [ -n "$CHANGES_DESCRIPTION" ]; then
        {
            echo ""
            echo "## Changes Since Last Review"
            echo "$CHANGES_DESCRIPTION"
        } >> "$REVIEW_DIR/REVIEW_REQUEST.md"
    fi
}

gather_dev_design() {
    write_header
    {
        echo "## Goal"
        echo "Review the design document for completeness, ambiguity, and risks."
        echo ""
        echo "## Context"
        if [ -n "$DESIGN_DOC" ] && [ -f "$DESIGN_DOC" ]; then
            echo "### Design Document: $DESIGN_DOC"
            echo '```'
            cat "$DESIGN_DOC"
            echo '```'
        else
            echo "(No design document path provided. Caller must supply content.)"
        fi
        echo ""
        echo "## Evidence"
        echo "### Recent git log"
        echo '```'
        git log --oneline -10 2>/dev/null || echo "(not a git repo)"
        echo '```'
        echo ""
        echo "## Questions"
        echo "- Is the design complete enough to begin implementation planning?"
        echo "- Are there ambiguous requirements that need clarification?"
        echo "- What risks or missing considerations should be addressed?"
    } >> "$REVIEW_DIR/REVIEW_REQUEST.md"
    append_changes_section
}

gather_dev_plan() {
    write_header
    {
        echo "## Goal"
        echo "Review the implementation plan for completeness, task granularity, and missing edge cases."
        echo ""
        echo "## Context"
        if [ -n "$PLAN_DOC" ] && [ -f "$PLAN_DOC" ]; then
            echo "### Implementation Plan: $PLAN_DOC"
            echo '```'
            cat "$PLAN_DOC"
            echo '```'
        else
            echo "(No plan document path provided. Caller must supply content.)"
        fi
        echo ""
        echo "## Evidence"
        echo "### Project structure"
        echo '```'
        find . -maxdepth 3 -type f -not -path './.git/*' -not -path './node_modules/*' | head -50
        echo '```'
        echo ""
        echo "## Questions"
        echo "- Are all tasks at 2-5 minute granularity?"
        echo "- Are there placeholders (TBD, TODO, similar to Task N)?"
        echo "- Are all file paths, commands, and code complete?"
        echo "- Are edge cases covered?"
    } >> "$REVIEW_DIR/REVIEW_REQUEST.md"
    append_changes_section
}

gather_dev_implementation() {
    write_header
    {
        echo "## Goal"
        echo "Review the implementation diff for code quality, test coverage, and architectural coherence."
        echo ""
        echo "## Context"
        if [ -n "$BASE_SHA" ] && [ -n "$HEAD_SHA" ]; then
            echo "### Diff ($BASE_SHA..$HEAD_SHA)"
            echo '```diff'
            git diff "$BASE_SHA".."$HEAD_SHA" 2>/dev/null | head -500
            echo '```'
            echo ""
            echo "### Commit log"
            echo '```'
            git log --oneline "$BASE_SHA".."$HEAD_SHA" 2>/dev/null
            echo '```'
        else
            echo "### Staged + unstaged changes"
            echo '```diff'
            git diff HEAD 2>/dev/null | head -500
            echo '```'
        fi
        echo ""
        echo "## Evidence"
        echo "### Test output"
        echo "(Caller should append test results here.)"
        echo ""
        echo "## Questions"
        echo "- Does the implementation match the approved plan?"
        echo "- Is test coverage adequate?"
        echo "- Are there code quality issues?"
        echo "- Is the implementation architecturally coherent?"
    } >> "$REVIEW_DIR/REVIEW_REQUEST.md"
    append_changes_section
}

gather_deploy_safety() {
    write_header
    {
        echo "## Goal"
        echo "Review the deployment plan for safety, rollback coverage, and blast radius."
        echo ""
        echo "## Context"
        if [ -n "$SERVICE_PROFILE" ] && [ -f "$SERVICE_PROFILE" ]; then
            echo "### Service Profile: $SERVICE_PROFILE"
            echo '```'
            cat "$SERVICE_PROFILE"
            echo '```'
        else
            echo "(No service profile provided. This is required for deploy review.)"
        fi
        echo ""
        if [ -n "$DEPLOY_PLAN" ] && [ -f "$DEPLOY_PLAN" ]; then
            echo "### Deployment Plan: $DEPLOY_PLAN"
            echo '```'
            cat "$DEPLOY_PLAN"
            echo '```'
        else
            echo "(No deployment plan provided. Caller must supply content.)"
        fi
        echo ""
        echo "## Constraints"
        echo "- Rollback steps must be documented before execution"
        echo "- No production deploy without explicit user confirmation"
        echo "- No automatic strategy selection"
        echo ""
        echo "## Questions"
        echo "- Is the rollback plan complete and tested?"
        echo "- Is the blast radius understood and contained?"
        echo "- Are post-deployment validation commands defined?"
        echo "- Is monitoring in place for the deploy window?"
    } >> "$REVIEW_DIR/REVIEW_REQUEST.md"
    append_changes_section
}

case "$PROFILE" in
    dev-design) gather_dev_design ;;
    dev-plan) gather_dev_plan ;;
    dev-implementation) gather_dev_implementation ;;
    deploy-safety) gather_deploy_safety ;;
    *)
        echo "Unknown profile: $PROFILE"
        usage
        ;;
esac

echo "Review request written to $REVIEW_DIR/REVIEW_REQUEST.md"
