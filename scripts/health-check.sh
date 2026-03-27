#!/bin/bash
# health-check.sh -- Generic health check runner for cccx-monitor
# Usage: bash health-check.sh [url] [options]
#
# Options:
#   --method METHOD      HTTP method (default: GET)
#   --timeout SECONDS    Request timeout (default: 10)
#   --expected-status N  Expected HTTP status code (default: 200)
#   --expected-body STR  Expected substring in response body (literal match)
#   --process NAME       Check if a process with this name is running
#   --quiet              Only output PASS/FAIL, no details

set -euo pipefail

URL=""
METHOD="GET"
TIMEOUT=10
EXPECTED_STATUS=200
EXPECTED_BODY=""
PROCESS_NAME=""
QUIET=false

usage() {
    echo "Usage: bash health-check.sh [url] [options]"
    echo ""
    echo "Options:"
    echo "  --method METHOD      HTTP method (default: GET)"
    echo "  --timeout SECONDS    Request timeout (default: 10)"
    echo "  --expected-status N  Expected HTTP status (default: 200)"
    echo "  --expected-body STR  Expected substring in response body"
    echo "  --process NAME       Check if named process is running"
    echo "  --quiet              Only output PASS/FAIL"
    echo ""
    echo "At least one of url or --process must be provided."
    exit 1
}

# Parse all arguments in a single loop (no eager positional capture)
while [ $# -gt 0 ]; do
    case "$1" in
        --method) METHOD="$2"; shift 2 ;;
        --timeout) TIMEOUT="$2"; shift 2 ;;
        --expected-status) EXPECTED_STATUS="$2"; shift 2 ;;
        --expected-body) EXPECTED_BODY="$2"; shift 2 ;;
        --process) PROCESS_NAME="$2"; shift 2 ;;
        --quiet) QUIET=true; shift ;;
        --help|-h) usage ;;
        --*) echo "Unknown option: $1"; usage ;;
        *) URL="$1"; shift ;;
    esac
done

if [ -z "$URL" ] && [ -z "$PROCESS_NAME" ]; then
    usage
fi

PASS=true
DETAILS=""

# HTTP health check
if [ -n "$URL" ]; then
    CURL_METHOD=$(echo "$METHOD" | tr '[:lower:]' '[:upper:]')
    HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X "$CURL_METHOD" --max-time "$TIMEOUT" "$URL" 2>/dev/null) || HTTP_RESPONSE="000"

    if [ "$HTTP_RESPONSE" = "$EXPECTED_STATUS" ]; then
        DETAILS="${DETAILS}HTTP: PASS (${CURL_METHOD} ${URL} returned ${HTTP_RESPONSE})\n"
    else
        DETAILS="${DETAILS}HTTP: FAIL (${CURL_METHOD} ${URL} returned ${HTTP_RESPONSE}, expected ${EXPECTED_STATUS})\n"
        PASS=false
    fi

    # Body check -- uses grep -F for literal (fixed-string) matching
    if [ -n "$EXPECTED_BODY" ]; then
        BODY=$(curl -s -X "$CURL_METHOD" --max-time "$TIMEOUT" "$URL" 2>/dev/null) || BODY=""
        if echo "$BODY" | grep -qF "$EXPECTED_BODY"; then
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
