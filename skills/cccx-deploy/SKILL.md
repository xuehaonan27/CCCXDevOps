---
name: cccx-deploy
description: Use when deploying a service to any environment. Requires SERVICE_PROFILE.md with deploy command, rollback steps, and health endpoints. No production deploy without explicit confirmation.
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob, Skill
---

# Deployment Management

## Overview

Orchestrate deployment for projects with a known deployment process. Requires explicit project configuration -- does not guess at infrastructure, topology, or rollback procedures.

**Iron Law: NO DEPLOYMENT WITHOUT ROLLBACK PLAN**

## When to Use

- Deploying to any environment (dev, staging, production)
- Only when the project has a `SERVICE_PROFILE.md` with deploy and rollback information

## Prerequisites

- `SERVICE_PROFILE.md` exists in the project (see `templates/SERVICE_PROFILE.md`)
- Deploy command is documented
- Rollback command/steps are documented
- Health endpoints are defined
- Validation commands are defined

If any prerequisite is missing: STOP. Ask the user to fill in `SERVICE_PROFILE.md` first. Do not invent deployment procedures.

## Workflow

### Phase 1: Pre-Flight

1. **Read SERVICE_PROFILE.md**
   - Verify it exists
   - Verify deploy command is present
   - Verify rollback command/steps are present
   - Verify health endpoints are defined
   - Verify validation commands are defined
   - If anything is missing: STOP and report what's missing

2. **Verify tests pass** (invoke `cccx-verify`)
   - Run the project's full test suite
   - Do not proceed if tests fail

3. **Confirm target environment**
   - State explicitly which environment is being deployed to
   - For production: require explicit user confirmation ("Deploy to production? [yes/no]")

4. **Generate deployment plan**
   - If `DEPLOYMENT_PLAN.md` exists in the project, use it
   - Otherwise, generate one covering: overview (service, target, version, date), pre-deployment checklist, deployment steps (from SERVICE_PROFILE.md deploy command), post-deployment validation (from SERVICE_PROFILE.md validation commands), rollback plan (from SERVICE_PROFILE.md rollback command), and monitor window

### Phase 2: Safety Review

Request Codex review through `cccx-review`:

1. Write `.cccx/review/REVIEW_REQUEST.md` with:
   - profile: `deploy-safety`
   - subject: "Deploy <service> to <environment>"
   - evidence: SERVICE_PROFILE.md, deployment plan, test output
   - constraints: rollback requirements, no-downtime if applicable

2. Invoke `cccx-review`

3. Handle verdict:
   - APPROVE: proceed to Phase 3
   - REQUEST_CHANGES: address issues, re-submit
   - BLOCK: STOP. Present to user. Do not proceed.
   - SKIPPED (Codex not configured): warn user that deploy safety review was not performed. For **production** deployments, STOP and require explicit user acknowledgment before proceeding without review. For non-production, proceed with warning.

### Phase 3: Execute Deployment

1. **Run the deploy command** from SERVICE_PROFILE.md
   - Use the exact command documented, not an improvised variant
   - Report command output

2. **Immediate health check**
   - Hit health endpoints defined in SERVICE_PROFILE.md
   - Use `scripts/health-check.sh` if available
   - Report status

3. **Run validation commands**
   - Execute each validation command from SERVICE_PROFILE.md
   - Report results

### Phase 4: Post-Deployment Monitoring

1. **Monitor window** (default: 5 minutes, configurable)
   - Watch for errors in output
   - Re-check health endpoints at end of window
   - Re-run validation commands

2. **If any check fails during monitoring:**
   - Report the failure immediately
   - Present rollback option with the exact command from SERVICE_PROFILE.md
   - If user approves rollback: execute it, verify, report
   - If user declines: document the decision

### Phase 5: Report

```
Deployment complete:
  Service:     <name>
  Environment: <target>
  Status:      SUCCESS | PARTIAL | ROLLED_BACK
  Health:      <health check results>
  Validation:  <validation command results>
  Duration:    <time from deploy start to monitoring complete>
```

## v1 Guardrails

- **No invented infrastructure changes.** Only run commands from SERVICE_PROFILE.md.
- **No automatic strategy selection.** Do not assume rolling, blue-green, or canary.
- **No silent rollback logic.** Always ask the user before rolling back.
- **No production deploy without explicit user confirmation.**
- **No deploy if SERVICE_PROFILE.md is missing or incomplete.**

## Red Flags

- Deploying without reading SERVICE_PROFILE.md
- Running commands not documented in the profile
- Skipping safety review
- Proceeding to production without explicit confirmation
- Ignoring health check failures
- Auto-rolling back without asking
- Inventing rollback procedures

## Common Mistakes

| Mistake | Fix |
|---|---|
| "I know how to deploy this" | Read SERVICE_PROFILE.md. Use documented commands only. |
| Skipping health checks | Always check. Report evidence. |
| No rollback plan | STOP. Fill in SERVICE_PROFILE.md first. |
| Deploying untested code | Run full test suite first via cccx-verify. |
