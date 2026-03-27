---
name: cccx-monitor
description: Use when checking service health, verifying a deployment is stable, or performing routine health monitoring. Requires SERVICE_PROFILE.md with health endpoints.
allowed-tools: Bash(*), Read, Grep, Glob
---

# Health Monitoring

## Overview

Verify service health using explicit configuration from `SERVICE_PROFILE.md`. Does not guess at endpoints, processes, or thresholds.

## When to Use

- After deployment (called by `cccx-deploy`)
- Routine health check
- Investigating service status
- User asks "is it running?" or "check health"

## Prerequisites

- `SERVICE_PROFILE.md` exists with health endpoints defined
- If missing: report what's needed and ask user to provide it

## Workflow

### Step 1: Read Configuration

Read `SERVICE_PROFILE.md` and extract:
- Health endpoints (URL, method, expected status, expected body)
- Process names (if applicable)
- Validation commands
- Dashboard/log locations

### Step 2: Run Health Checks

For each health endpoint:

```bash
# If health-check.sh was installed (via install.sh --with-scripts):
bash ~/.claude/scripts/health-check.sh <url> \
  --method <method> \
  --expected-status <code> \
  --expected-body "<substring>" \
  --timeout 10
```

If `~/.claude/scripts/health-check.sh` does not exist, use curl directly:

```bash
STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X <METHOD> --max-time 10 "<url>")
echo "Health: <METHOD> <url> returned $STATUS (expected <code>)"
```

### Step 3: Run Validation Commands

Execute each validation command from SERVICE_PROFILE.md and report output.

### Step 4: Check Processes (if applicable)

If SERVICE_PROFILE.md lists process names:

```bash
pgrep -f "<process-name>" && echo "RUNNING" || echo "NOT FOUND"
```

### Step 5: Report

```
=== Health Report ===
Service:     <name>
Environment: <environment>
Timestamp:   <ISO 8601>

Health Endpoints:
  <url>: <status> (expected <expected>) -- PASS/FAIL
  <url>: <status> (expected <expected>) -- PASS/FAIL

Validation Commands:
  <command>: <result> -- PASS/FAIL

Processes:
  <name>: RUNNING/NOT FOUND

Overall: HEALTHY / DEGRADED / UNHEALTHY

Dashboard: <url from SERVICE_PROFILE>
Logs:      <location from SERVICE_PROFILE>
```

### Status Definitions

| Status | Meaning |
|---|---|
| HEALTHY | All health endpoints pass, all validation commands pass |
| DEGRADED | Some checks pass, some fail |
| UNHEALTHY | Critical health endpoints fail |

## Scheduled Monitoring

For periodic health checks, the user can set up a cron:

```bash
# Check every 5 minutes (example)
# CronCreate: */5 * * * * bash ~/.claude/scripts/health-check.sh <url> --quiet
```

This is optional and user-configured, not automatic.

## Red Flags

- Guessing health endpoints that aren't in SERVICE_PROFILE.md
- Reporting "healthy" without running checks
- Ignoring FAIL results
- Not reporting the raw evidence
