#!/bin/bash
# health-check.sh -- Generic health check runner for cccx-monitor
# Usage: bash health-check.sh <url> [options]
#
# Options:
#   --timeout SECONDS    Request timeout (default: 10)
#   --expected-status N  Expected HTTP status code (default: 200)
#   --expected-body STR  Expected substring in response body
#   --process NAME       Check if a process with this name is running
#   --quiet              Only output PASS/FAIL, no details

set -euo pipefail

URL="${1:-}"
TIMEOUT=10
EXPECTED_STATUS=200
EXPECTED_BODY=""
PROCESS_NAME=""
QUIET=false

usage() {
    echo "Usage: bash health-check.sh <url> [options]"
    echo ""
    echo "Options:"
    echo "  --timeout SECONDS    Request timeout (default: 10)"
    echo "  --expected-status N  Expected HTTP status (default: 200)"
    echo "  --expected-body STR  Expected substring in response body"
    echo "  --process NAME       Check if named process is running"
    echo "  --quiet              Only output PASS/FAIL"
    exit 1
}

if [ -z "$URL" ] && [ -z "$PROCESS_NAME" ]; then
    # Check if only --process was provided
    shift 0 2>/dev/null || true
    for arg in "$@"; do
        if [ "$arg" = "--process" ]; then
            break
        fi
    done
    if [ -z "$PROCESS_NAME" ] && [ "$#" -eq 0 ]; then
        usage
    fi
fi

shift 2>/dev/null || true

while [ $# -gt 0 ]; do
    case "$1" in
        --timeout) TIMEOUT="$2"; shift 2 ;;
        --expected-status) EXPECTED_STATUS="$2"; shift 2 ;;
        --expected-body) EXPECTED_BODY="$2"; shift 2 ;;
        --process) PROCESS_NAME="$2"; shift 2 ;;
        --quiet) QUIET=true; shift ;;
        *) shift ;;
    esac
done

PASS=true
DETAILS=""

# HTTP health check
if [ -n "$URL" ]; then
    HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$TIMEOUT" "$URL" 2>/dev/null) || HTTP_RESPONSE="000"

    if [ "$HTTP_RESPONSE" = "$EXPECTED_STATUS" ]; then
        DETAILS="${DETAILS}HTTP: PASS (${URL} returned ${HTTP_RESPONSE})\n"
    else
        DETAILS="${DETAILS}HTTP: FAIL (${URL} returned ${HTTP_RESPONSE}, expected ${EXPECTED_STATUS})\n"
        PASS=false
    fi

    # Body check
    if [ -n "$EXPECTED_BODY" ]; then
        BODY=$(curl -s --max-time "$TIMEOUT" "$URL" 2>/dev/null) || BODY=""
        if echo "$BODY" | grep -q "$EXPECTED_BODY"; then
            DETAILS="${DETAILS}BODY: PASS (contains '${EXPECTED_BODY}')\n"
        else
            DETAILS="${DETAILS}BODY: FAIL (does not contain '${EXPECTED_BODY}')\n"
            PASS=false
        fi
    fi
fi

# Process check
if [ -n "$PROCESS_NAME" ]; then
    if pgrep -f "$PROCESS_NAME" > /dev/null 2>&1; then
        DETAILS="${DETAILS}PROCESS: PASS (${PROCESS_NAME} is running)\n"
    else
        DETAILS="${DETAILS}PROCESS: FAIL (${PROCESS_NAME} not found)\n"
        PASS=false
    fi
fi

# Output
if [ "$QUIET" = true ]; then
    if [ "$PASS" = true ]; then
        echo "PASS"
    else
        echo "FAIL"
        exit 1
    fi
else
    echo "=== Health Check Report ==="
    echo -e "$DETAILS"
    if [ "$PASS" = true ]; then
        echo "Overall: PASS"
    else
        echo "Overall: FAIL"
        exit 1
    fi
fi
